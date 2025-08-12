# 🧠 Clase: Introducción a Agentes con LLMs, n8n y LangChain

Este archivo contiene todo el material para una clase intensiva de **2 horas** sobre el uso de **agentes** en entornos de automatización y LLMs, orientada a personas con nociones básicas de modelos de lenguaje y herramientas low-code/no-code.

---

## 🎯 Objetivos de la clase

Al finalizar la clase, podrás:
1. Explicar qué es un **agente** y cómo se diferencia de un chatbot tradicional.
2. Conocer los **patrones y arquitecturas** más usados (ReAct, Toolformer, AutoGPT, BabyAGI, RAG).
3. Crear un **agente en n8n** que use herramientas como Google Sheets, Gmail y Telegram.
4. Construir un **agente en LangChain** con herramientas y RAG.
5. Aplicar **buenas prácticas** de observabilidad, seguridad, límites y control de costos.


---

## 📘 Módulo 1 — Fundamentos de Agentes

### 🎯 Objetivo del módulo
Que el alumno comprenda **qué es un agente**, sus **componentes esenciales**, en qué se diferencia de un chatbot tradicional, y cómo encaja en un ecosistema de automatización con LLMs.

---

### 1. ¿Qué es un agente?
Un **agente** es un sistema que combina **razonamiento** con **capacidad de acción**, y que puede tomar decisiones de forma autónoma para alcanzar un objetivo definido por un usuario o por otro sistema.  

A diferencia de un simple modelo de lenguaje que responde a un prompt estático, un agente:

- **Recibe un objetivo o tarea** (por ejemplo: “Planifica mi viaje a Madrid en noviembre”).
- **Evalúa opciones y planifica pasos** (por ejemplo: buscar vuelos, verificar clima, listar hoteles).
- **Selecciona y usa herramientas** (APIs, bases de datos, buscadores, hojas de cálculo, etc.).
- **Ejecuta acciones** y **adapta el plan** según los resultados intermedios.

**💡 Analogía:**  
Piensa en un agente como un **asistente humano** que no sólo responde a preguntas, sino que también sabe **a quién llamar, dónde buscar y cómo actuar** para resolver tu necesidad.

---

## 📘 Módulo 2 — Patrones y Arquitecturas de Agentes

### 🎯 Objetivo del módulo
Que el alumno conozca los **patrones más comunes** en el diseño de agentes, entienda sus diferencias y aplicaciones, y se familiarice con las arquitecturas que permiten que un agente combine razonamiento, herramientas y memoria.

---

### 1. Introducción a patrones de agentes
Los patrones definen **cómo** un agente decide, actúa y utiliza herramientas para cumplir un objetivo.  
Cada patrón tiene ventajas y limitaciones según el contexto.

---

### 2. Patrones más usados

#### 🔹 ReAct (Reason + Act)
- **Idea:** El agente alterna entre “pensar” (Reasoning) y “actuar” (Action).
- **Ciclo:**
  1. Thought: analiza el objetivo.
  2. Action: usa una herramienta.
  3. Observation: analiza el resultado.
  4. Repite hasta llegar a la respuesta final.
- **Uso típico:** Búsquedas complejas, consultas multi-paso, razonamiento sobre datos.

---

#### 🔹 Toolformer
- **Idea:** LLM entrenado para decidir cuándo y cómo usar herramientas externas.
- **Ventaja:** Reduce uso innecesario de herramientas → menor costo y latencia.
- **Uso típico:** Aplicaciones que deben ser eficientes y con control de API calls.

---

#### 🔹 AutoGPT
- **Idea:** Un agente autónomo que recibe un objetivo general y lo divide en tareas que ejecuta sin intervención humana.
- **Ventaja:** Alto nivel de autonomía.
- **Riesgo:** Difícil de controlar en contextos críticos, mayor uso de recursos.

---

#### 🔹 BabyAGI
- **Idea:** Agente que mantiene y prioriza una lista de tareas dinámicamente.
- **Uso típico:** Gestión de proyectos o procesos largos con dependencias.

---

#### 🔹 RAG (Retrieval-Augmented Generation)
- **Idea:** El agente recupera información de una base vectorial y usa esa información como contexto para responder.
- **Ventaja:** Reduce alucinaciones, garantiza respuestas basadas en datos reales.
- **Uso típico:** Chatbots corporativos, asistentes con documentación interna.

---

### 3. Componentes en la arquitectura de un agente

| Componente            | Descripción                                         | Ejemplo                              |
|-----------------------|-----------------------------------------------------|---------------------------------------|
| **LLM (motor de razonamiento)** | Procesa lenguaje y planifica acciones           | GPT-4, Claude                         |
| **Gestor de herramientas**     | Lista y coordina APIs o funciones disponibles    | Google Search API, CRM API            |
| **Memoria**                    | Guarda contexto y hechos relevantes             | Conversación, estado de la tarea      |
| **Controlador**                | Decide el flujo de ejecución y maneja excepciones| LangChain Agent Executor              |
| **Observabilidad**              | Registro de pasos, métricas y costos             | LangSmith, logs en n8n                 |

---

### 4. Flujo típico de un agente

```
[Objetivo del usuario]
↓
[Planificación del agente]
↓
[Selección de herramienta]
↓
[Ejecución de acción]
↓
[Observación y análisis]
↺ (Si es necesario, repetir)
↓
[Respuesta final al usuario]
```

---

### 5. Consideraciones para elegir un patrón

- **Tareas simples y determinísticas:** No siempre es necesario un agente; puede bastar una función o workflow fijo.
- **Consultas con múltiples pasos y herramientas:** Patrón ReAct.
- **Procesos de largo plazo con múltiples tareas:** BabyAGI o AutoGPT (con supervisión).
- **Necesidad de datos precisos y actualizados:** Integrar RAG.

---

### 6. Recursos recomendados

- **ReAct Paper:** [https://arxiv.org/abs/2210.03629](https://arxiv.org/abs/2210.03629)  
- **AutoGPT GitHub:** [https://github.com/Torantulino/Auto-GPT](https://github.com/Torantulino/Auto-GPT)  
- **BabyAGI GitHub:** [https://github.com/yoheinakajima/babyagi](https://github.com/yoheinakajima/babyagi)  
- **RAG Conceptos — Pinecone:** [https://www.pinecone.io/learn/series/rag/](https://www.pinecone.io/learn/series/rag/)  
- **Toolformer Paper:** [https://arxiv.org/abs/2302.04761](https://arxiv.org/abs/2302.04761)


---
### 2. Componentes esenciales de un agente

| Componente | Descripción | Ejemplo en uso |
|------------|-------------|----------------|
| **Razón / Planificación** | Capacidad de decidir qué pasos seguir y en qué orden | Determinar si primero buscar hoteles o vuelos |
| **Herramientas (Tools)** | Funciones o APIs que el agente puede invocar | API de clima, Google Sheets, CRM |
| **Memoria** | Contexto persistente para mantener coherencia y recordar datos | Recordar que el usuario viaja del 5 al 10 de noviembre |
| **Estado** | Registro de objetivos, pasos completados y próximos | Lista de tareas: “buscar vuelos” ✅, “reservar hotel” ❌ |
| **Políticas y límites** | Reglas para acotar su comportamiento | No hacer compras, no enviar emails sin confirmación |

---

### 3. Diferencia entre un chatbot y un agente

| Chatbot tradicional | Agente |
|---------------------|--------|
| Responde a un prompt | Planifica, decide y ejecuta múltiples pasos |
| No usa herramientas externas (o muy limitadas) | Usa múltiples herramientas y APIs |
| No mantiene contexto complejo | Memoria y estado persistente |
| Respuestas estáticas y basadas en texto | Puede devolver acciones, datos procesados, reportes |

**Ejemplo:**
- **Chatbot:** “¿Cuál es el clima en Madrid?” → Responde “21°C soleado”.
- **Agente:** “Planea mi viaje a Madrid” → Busca clima, compara vuelos, crea itinerario, envía PDF con recomendaciones.

---

### 4. Patrones básicos de funcionamiento

- **Razonamiento + Acción (ReAct)**: alterna entre pensar (“Thought”) y actuar (“Action”) usando herramientas, luego observa resultados (“Observation”).
- **Planificación + Ejecución**: divide la tarea en subtareas y las ejecuta en secuencia.
- **Uso condicional de herramientas**: elige herramientas sólo cuando son necesarias.

---

### 5. Ejemplo narrativo

**Objetivo:** “Envíame un informe con las ventas del último mes y el top 3 de clientes por facturación.”  

1. **Razonamiento:** Necesita conectarse al CRM y a la hoja de cálculo de facturación.
2. **Acción 1:** Consultar API de ventas.
3. **Observación 1:** Recibe dataset.
4. **Acción 2:** Filtrar y ordenar clientes por facturación.
5. **Acción 3:** Generar informe PDF y enviarlo por email.
6. **Resultado:** Informe enviado con detalles y gráficos.

---

### 6. Recursos recomendados

- **OpenAI — Function Calling y Agentes:** [https://openai.com/blog/function-calling-and-agents](https://openai.com/blog/function-calling-and-agents)  
- **ReAct Paper:** [https://arxiv.org/abs/2210.03629](https://arxiv.org/abs/2210.03629)  
- **LangChain — Agentes:** [https://python.langchain.com/docs/concepts/agents](https://python.langchain.com/docs/concepts/agents)


---
## 📘 Módulo 3 — Agentes en n8n

### 🎯 Objetivo del módulo
Que el alumno aprenda cómo implementar agentes dentro de **n8n**, comprendiendo qué nodos y configuraciones utilizar, cómo integrar herramientas, y cómo estructurar flujos que combinen razonamiento con automatización.

---

### 1. ¿Por qué usar n8n para agentes?
n8n es una plataforma de automatización **low-code** que permite:
- Conectar agentes con múltiples APIs y servicios sin programación avanzada.
- Definir flujos visuales que integran LLMs, herramientas y datos empresariales.
- Mantener control sobre el flujo de ejecución y la seguridad.

---

### 2. Nodos clave para trabajar con agentes en n8n

| Nodo | Función | Ejemplo de uso |
|------|---------|----------------|
| **Conversational Agent** | Mantiene contexto de la conversación y usa herramientas definidas | Soporte al cliente que recuerda interacciones anteriores |
| **Tool Agent** | Ejecuta acciones específicas invocando APIs o funciones predefinidas | Llamar a API de clima o CRM |
| **OpenAI** | Conecta con modelos GPT y permite function-calling | Analizar texto, clasificar datos |
| **HTTP Request** | Integrar cualquier API externa no soportada nativamente | Llamar a endpoint REST propio |
| **Google Sheets** | Leer/escribir datos estructurados | Consultar base de clientes o registrar logs |
| **Gmail** | Enviar correos generados por el agente | Confirmaciones, notificaciones |
| **Webhook / Chat Trigger** | Iniciar flujo al recibir mensaje o petición | Integración con Telegram, Slack o webhooks |

---

### 3. Arquitectura típica de un agente en n8n

```
[Trigger: Chat / Webhook / Evento]
↓
[Conversational Agent / Tool Agent]
↓
[Selección de herramienta y ejecución]
↓
[Procesamiento adicional (opcional)]
↓
[Salida: Email / Mensaje / Actualización de base de datos]
```

---

### 4. Ejemplo práctico: Agente de soporte

**Objetivo:** Crear un asistente que responda consultas de clientes en Telegram, verificando su estado en una base de datos y enviando confirmaciones.

**Flujo:**
1. **Trigger:** `On Chat Message` (Telegram).
2. **Conversational Agent:** Prompt inicial con rol (ej. “Sos un asistente de soporte de la empresa…”).
3. **Google Sheets:** Buscar cliente por ID/email recibido.
4. **Condicional:** Si el cliente está activo → respuesta normal, si no → mensaje de renovación.
5. **Gmail:** Enviar resumen de la conversación al cliente.
6. **Registro:** Guardar datos en Google Sheets o DB.

---

### 5. Buenas prácticas en n8n para agentes

- **Separar lógica del agente de la lógica de integración**: El agente decide y genera instrucciones, n8n ejecuta las acciones concretas.
- **Definir herramientas con parámetros claros**: Inputs y outputs bien especificados.
- **Usar Set Nodes para formatear datos** antes de entregarlos al agente.
- **Controlar errores**: Añadir manejo de fallos en llamadas a APIs.
- **Monitorear costos y uso de tokens** cuando se usan LLMs.

---

### 6. Recursos recomendados

- **Documentación de AI en n8n:** [https://docs.n8n.io/integrations/builtin/ai](https://docs.n8n.io/integrations/builtin/ai)  
- **Galería de workflows AI:** [https://n8n.io/workflows?category=ai](https://n8n.io/workflows?category=ai)  
- **Ejemplo de Conversational Agent Node:** [https://docs.n8n.io/integrations/builtin/ai/nodes/agent-node/](https://docs.n8n.io/integrations/builtin/ai/nodes/agent-node/)  
- **Guía de integración con Google Sheets:** [https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googlesheets/](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googlesheets/)

---
## 📘 Módulo 4 — Agentes en LangChain

### 🎯 Objetivo del módulo
Que el alumno aprenda a crear y ejecutar agentes con **LangChain**, entendiendo su arquitectura, los tipos disponibles, y cómo integrar herramientas y memoria, incluyendo un flujo básico con **RAG**.

---

### 1. ¿Por qué usar LangChain para agentes?
LangChain es un framework que facilita:
- Conectar LLMs con múltiples **herramientas**.
- Integrar **memoria** y manejo de contexto a largo plazo.
- Orquestar **cadenas** de pasos y decisiones.
- Implementar patrones como **ReAct** y **Tool-Calling**.
- Integrar **RAG** con bases vectoriales.

---

### 2. Componentes clave en LangChain para agentes

| Componente | Descripción | Ejemplo |
|------------|-------------|---------|
| **LLM** | Motor de razonamiento y generación de texto | GPT-4, Claude, LLaMA |
| **Tools** | Funciones externas disponibles para el agente | Buscador web, calculadora, API de clima |
| **Toolkits** | Conjuntos de herramientas para un dominio | SQLDatabaseToolkit, PythonREPLToolkit |
| **Memory** | Mantiene contexto entre pasos o conversaciones | ConversationBufferMemory |
| **Agent Executor** | Controla la ejecución y manejo de herramientas | `initialize_agent()` |
| **Callbacks** | Registro y depuración de pasos | LangSmith, consola |

---

### 3. Tipos de agentes en LangChain

#### 🔹 Zero-Shot ReAct
- **Descripción:** El agente decide qué herramienta usar sin ejemplos previos, basándose en instrucciones.
- **Uso típico:** Consultas generales con varias herramientas.

#### 🔹 Conversational Agent
- **Descripción:** Diseñado para mantener un diálogo natural, recordando interacciones previas.
- **Uso típico:** Asistentes virtuales, soporte al cliente.

#### 🔹 Structured Tool-Calling Agent
- **Descripción:** El agente llama a herramientas con parámetros bien definidos.
- **Uso típico:** Integraciones críticas con APIs que requieren formatos estrictos.

---

### 4. Ejemplo básico: Agente con herramientas

```python
from langchain.agents import initialize_agent, Tool
from langchain.llms import OpenAI
from langchain.memory import ConversationBufferMemory

# Definir herramientas
def buscar_clima(ciudad: str) -> str:
    return f"Clima en {ciudad}: 22°C soleado"

tools = [
    Tool(
        name="Buscar Clima",
        func=buscar_clima,
        description="Devuelve el clima actual de una ciudad"
    )
]

# Configurar LLM y memoria
llm = OpenAI(temperature=0)
memory = ConversationBufferMemory(memory_key="chat_history")

# Inicializar agente
agent = initialize_agent(
    tools,
    llm,
    agent="conversational-react-description",
    memory=memory,
    verbose=True
)

# Ejecutar consulta
agent.run("¿Cuál es el clima en Madrid?")

---

## 📚 Recursos

- **n8n Docs:** [https://docs.n8n.io/integrations/builtin/ai](https://docs.n8n.io/integrations/builtin/ai)  
- **n8n Workflows:** [https://n8n.io/workflows](https://n8n.io/workflows)  
- **LangChain Docs:** [https://python.langchain.com/docs](https://python.langchain.com/docs)  
- **OpenAI Function Calling:** [https://platform.openai.com/docs/guides/function-calling](https://platform.openai.com/docs/guides/function-calling)  
- **ReAct Paper:** [https://arxiv.org/abs/2210.03629](https://arxiv.org/abs/2210.03629)  
- **RAG Conceptos:** [https://www.pinecone.io/learn/series/rag/](https://www.pinecone.io/learn/series/rag/)  

---


## 🙋‍♀️ Contribuir
Si querés mejorar el material, enviar ejemplos o reportar errores, abrí un PR o creá un issue en este repo.

💡 **Tip:** Si vas a dar esta clase, tené listos los entornos (n8n y Python/LangChain) para ahorrar tiempo de instalación.

---

[⬅ Back to Course Overview](../../README.md)