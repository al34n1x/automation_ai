import express from "express";
import path from "path";
import dotenv from "dotenv";
import { fileSearchTool, Agent, Runner, withTrace } from "@openai/agents";
import type { AgentInputItem } from "@openai/agents";
import { z } from "zod";

dotenv.config();

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

// --- Agent definitions (adapted from user's OpenAI Agent Builder SDK code) ---

const fileSearch = fileSearchTool([
  "vs_6906a7c120c081918cee430d22eab78f",
]);

const ClassifierSchema = z.object({
  consulta: z.enum(["comercial", "soporte"]),
});

const classifier = new Agent({
  name: "classifier",
  instructions: `Clasifica con precisión la intención del usuario de acuerdo con las siguientes categorías: \"Consulta de producto\", \"Soporte\" o \"Queja de servicio\". Antes de seleccionar la categoría final, analiza brevemente el contenido de la consulta del usuario para justificar tu clasificación. Respeta estrictamente el esquema de respuesta que se indica a continuación y asegúrate de que tu clasificación es eficiente y precisa.

# Esquema de Respuesta

- **Análisis**: Explica brevemente tu razonamiento sobre la intención del usuario, basándote únicamente en el texto proporcionado.
- **Clasificación**: Escribe únicamente una de estas opciones, la que mejor describa la intención detectada (exactamente): \"Consulta de producto\", \"Soporte\" o \"Queja de servicio\".

# Formato de salida

Responde siguiendo exactamente este formato, sin agregar información extra:

Análisis: [tu análisis aquí]

Clasificación: [una de: Consulta de producto / Soporte / Queja de servicio]

# Ejemplos

Ejemplo 1:
Usuario: \"¿Cuáles son las características del nuevo teléfono?\"
Análisis: El usuario solicita información específica sobre un producto, en este caso, un teléfono.
Clasificación: Consulta de producto

Ejemplo 2:
Usuario: \"No puedo acceder a mi cuenta desde ayer.\"
Análisis: El usuario reporta una dificultad técnica relacionada con el acceso a su cuenta, lo que es un problema de soporte.
Clasificación: Soporte

Ejemplo 3:
Usuario: \"El servicio de entrega fue muy deficiente y llegó tarde.\"
Análisis: El usuario expresa su insatisfacción respecto al servicio recibido, lo que constituye una queja formal.
Clasificación: Queja de servicio

# Notas

- Sé breve, directo y claro.
- No incluyas ningún texto que no esté en el esquema especificado.
- Si la intención del usuario no encaja claramente en una única categoría, selecciona la más relevante según el contexto presentado.

# Recordatorio de instrucciones principales
Clasifica la intención del usuario según el esquema indicado, asegurando precisión y eficiencia. Antepón siempre tu razonamiento antes de decidir la categoría final.`,
  model: "gpt-4o",
  outputType: ClassifierSchema,
  modelSettings: {
    store: true,
  },
});

const comercial = new Agent({
  name: "comercial",
  instructions:
    "Eres un agente comercial y debes de proveer información de productos.",
  model: "gpt-4o",
  tools: [fileSearch],
  modelSettings: {
    store: true,
  },
});

const soporte = new Agent({
  name: "Soporte",
  instructions: `Actúa como un agente de soporte al cliente que mantiene conversaciones interactivas con clientes que solicitan asistencia sobre productos de la lista disponible en la herramienta de productos.
Tus objetivos:
Interactuar de manera amigable, útil e interactiva, realizando preguntas aclaratorias cuando sea necesario.
Antes de responder consultas o solicitudes de soporte relacionadas con productos, consulta siempre la lista de productos proporcionada en la herramienta de productos para asegurar información precisa y actualizada.
Si el cliente menciona un producto que no está en la lista, infórmalo amablemente y guíalo hacia productos relevantes si es posible.
Realiza preguntas de seguimiento pertinentes para comprender completamente el problema del cliente, a menos que ya esté claro.
Proporciona soluciones paso a paso o dirige al cliente a recursos adicionales si es necesario.
Pasos
Saluda al cliente y pregúntale cómo puedes asistirlo.
Cuando el cliente mencione un producto, verifica su disponibilidad en la herramienta de productos antes de responder.
Si necesitas más información del cliente, haz preguntas aclaratorias de manera educada.
Proporciona respuestas precisas, concisas y útiles basadas en la información verificada del producto.
Cierra la conversación de forma cortés una vez que las necesidades del cliente hayan sido satisfechas.`,
  model: "gpt-4o",
  tools: [fileSearch],
  modelSettings: {
    store: true,
  },
});

// --- In-memory session store ---

interface Session {
  history: AgentInputItem[];
}

const sessions = new Map<string, Session>();

// --- Chat API route ---

app.post("/api/chat", async (req, res) => {
  try {
    const { message, sessionId } = req.body;

    if (!message || !sessionId) {
      res.status(400).json({ error: "message and sessionId are required" });
      return;
    }

    let session = sessions.get(sessionId);
    if (!session) {
      session = { history: [] };
      sessions.set(sessionId, session);
    }

    const conversationHistory: AgentInputItem[] = [
      ...session.history,
      {
        role: "user",
        content: [{ type: "input_text", text: message }],
      },
    ];

    const result = await withTrace("Agente comercial", async () => {
      const runner = new Runner({
        traceMetadata: {
          __trace_source__: "agent-builder",
          workflow_id:
            "wf_6906a67700e48190b078fa608b3c127e00106c12c7a3aa7c",
        },
      });

      // Step 1: Classify
      const classifierResult = await runner.run(classifier, [
        ...conversationHistory,
      ]);
      conversationHistory.push(
        ...classifierResult.newItems.map((item) => item.rawItem)
      );

      if (!classifierResult.finalOutput) {
        throw new Error("Classifier result is undefined");
      }

      const parsed = classifierResult.finalOutput as { consulta: string };
      let replyText = "";
      let agentName = "classifier";

      // Step 2: Route to the appropriate agent
      if (parsed.consulta === "comercial") {
        const comercialResult = await runner.run(comercial, [
          ...conversationHistory,
        ]);
        conversationHistory.push(
          ...comercialResult.newItems.map((item) => item.rawItem)
        );
        replyText = (comercialResult.finalOutput as string) ?? "";
        agentName = "comercial";
      } else {
        const soporteResult = await runner.run(soporte, [
          ...conversationHistory,
        ]);
        conversationHistory.push(
          ...soporteResult.newItems.map((item) => item.rawItem)
        );
        replyText = (soporteResult.finalOutput as string) ?? "";
        agentName = "soporte";
      }

      return { replyText, agentName, conversationHistory };
    });

    // Update session history
    if (result) {
      session.history = result.conversationHistory;
      res.json({ reply: result.replyText, agent: result.agentName });
    } else {
      res.json({ reply: "Lo siento, no pude procesar tu mensaje.", agent: "unknown" });
    }
  } catch (error) {
    console.error("Chat error:", error);
    res.status(500).json({ error: "Internal server error. Please try again." });
  }
});

app.post("/api/chat/reset", (req, res) => {
  const { sessionId } = req.body;
  if (sessionId) {
    sessions.delete(sessionId);
  }
  res.json({ ok: true });
});

// --- Start server ---

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
