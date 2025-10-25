# 🤖 Agentes de Análisis en n8n

Los **Agentes de Análisis en n8n** permiten procesar, interpretar y extraer información de **datos no estructurados** (emails, documentos, chats, PDFs, etc.) utilizando **modelos de lenguaje (LLMs)** dentro de un flujo automatizado.

---

## 🔎 ¿Qué es un Agente de Análisis?

Un **Agente de Análisis** es un nodo de IA en n8n configurado con un **rol de analista**.  
Su función es **recibir datos, analizarlos y devolver un resultado estructurado** (ej. JSON, clasificación, resumen o insights).

Se integra con otras herramientas en el flujo para **automatizar decisiones y acciones** según el análisis.

---

## ⚙️ Cómo funciona

1. **Trigger** → Entrada de datos (Webhook, Gmail, Slack, Drive).  
2. **AI Agent Node** → LLM configurado como analista con un **System Prompt**.  
3. **Procesamiento** →  
   - Uso de bases vectoriales (Pinecone, Qdrant, Weaviate).  
   - Extracción de entidades y clasificación.  
4. **Acciones posteriores** →  
   - Guardar resultados en Google Sheets o base de datos.  
   - Enviar alertas en Slack/Telegram.  
   - Actualizar CRM o ERP.

---

## 📊 Casos de uso

- **Análisis de tickets de soporte**: detectar urgencia y sentimiento de clientes.  
- **Revisión de facturas**: extraer número, fecha, IVA y total de documentos.  
- **Monitor de riesgos**: evaluar noticias o redes sociales para alertas reputacionales.  
- **Insights en ventas**: identificar necesidades y oportunidades en transcripciones de reuniones.

---

## 🧩 Ejemplo práctico: Clasificación de correos

Este flujo de ejemplo **clasifica emails según urgencia y sentimiento**:

### Flujo
1. **Trigger Gmail** → recibe nuevo correo.  
2. **Set Node** → extrae `subject` y `body`.  
3. **AI Agent (Analysis)** → analiza el correo con prompt:  

   ```text
   Eres un analista de soporte. Lee el correo y devuelve un JSON con:
   {
     "cliente": string,
     "tema": string,
     "sentimiento": "positivo" | "neutral" | "negativo",
     "urgencia": "alta" | "media" | "baja"
   }
   ```

4. **If Node** → si `urgencia = alta`, envía alerta en Slack.  
5. **Google Sheets** → guarda el análisis para seguimiento.

---

## 🚀 Beneficios

- Automatiza procesos que requieren **interpretación humana**.  
- Escala el análisis de datos en tiempo real.  
- Mejora la toma de decisiones (alertas, clasificación, insights).  
- Integra **IA + lógica de negocio** sin necesidad de programar.  

---

## 📝 Notas

- Podés adaptar el **System Prompt** según el tipo de análisis.  
- El flujo se puede extender con más nodos: bases vectoriales, condicionales o dashboards.  
- Recomendación: siempre devolver el output en **JSON limpio** para integraciones posteriores.

---

## 📚 Recursos adicionales

- [Documentación oficial de n8n](https://docs.n8n.io)  
- [Nodos de AI en n8n](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.aiAgent/)  
- [Guía de Google Sheets + n8n](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.googleSheets/)  

---
