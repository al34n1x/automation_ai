# 🧠 Proyecto n8n – CRM Intelligent Agent

## 📋 Descripción general

Este proyecto implementa un **agente inteligente de CRM** dentro de n8n que permite:
- Consultar datos de clientes individuales (por nombre, email o ID).
- Obtener métricas analíticas del CRM (totales, clientes activos, planes, etc.).
- Interactuar de forma natural a través de **Telegram**.

El flujo se compone de dos workflows principales:

| Workflow | Función | Nombre interno |
|-----------|----------|----------------|
| 🤖 **G_CRM** | Orquestador principal, maneja consultas de usuarios y coordina sub-flujos | `G_CRM` |
| 📊 **Sub_WF_CRM** | Subworkflow que conecta con Google Sheets (base CRM) y responde con datos exactos | `Sub_WF_CRM` |

---

## ⚙️ Requisitos previos

Antes de comenzar, asegurate de tener:

- Una cuenta activa en **n8n.cloud** o **instancia local**.
- Credenciales configuradas:
  - **OpenAI API Key**
  - **Telegram Bot Token**
  - **Google Sheets OAuth2** con acceso al documento del CRM.
- Un documento de Google Sheets con los campos:

| CustomerID | Name | Email | Phone | City | Status | Plan | TotalSpentUSD |
|-------------|------|--------|--------|--------|--------|--------|---------------|

---

## 🧩 Estructura de Workflows

### 1. **Sub_WF_CRM** — Base de datos CRM

📁 Archivo: `Sub_WF_CRM.json`

Este subworkflow actúa como un **buscador inteligente** que recibe una consulta y devuelve un **objeto JSON exacto** con la información del cliente.

#### 🧠 Componentes principales

| Nodo | Tipo | Descripción |
|------|------|--------------|
| **When Executed by Another Workflow** | Trigger | Recibe las peticiones del workflow principal |
| **AI Agent** | LangChain Agent | Interpreta la consulta (nombre, email o ID) |
| **OpenAI Chat Model** | LLM | Modelo GPT (versión mini) para interpretar la intención |
| **Google Sheets Tool** | Data Connector | Accede a la hoja del CRM para buscar coincidencias |

#### ⚙️ System Prompt (AI Agent)

El agente está configurado para devolver **solo un JSON válido** con los campos:

```json
{
  "CustomerID": "",
  "Name": "",
  "Email": "",
  "Phone": "",
  "City": "",
  "Status": "",
  "Plan": "",
  "TotalSpentUSD": ""
}
```

No genera texto adicional, solo el resultado puro.  
Esto asegura compatibilidad total con el flujo principal.

#### 🔗 Conexiones

- `Execute Workflow Trigger → AI Agent`
- `AI Agent → OpenAI Chat Model (ai_languageModel)`
- `AI Agent → Google Sheets Tool (ai_tool)`

---

### 2. **G_CRM** — Coordinador principal

📁 Archivo: `G_CRM.json`

Este flujo recibe mensajes desde **Telegram**, detecta la intención del usuario y:
- Si pide un cliente → llama a `Sub_WF_CRM`.
- Si pide métricas (como cantidad de clientes o activos) → obtiene valores exactos del CRM.
- Si la consulta no pertenece al dominio CRM → responde amablemente.

#### 🧠 Componentes principales

| Nodo | Tipo | Descripción |
|------|------|--------------|
| **Telegram Trigger** | Trigger | Escucha mensajes entrantes del bot |
| **AI Agent** | LangChain Agent | Analiza la intención y decide acción |
| **Sub_WF_CRM** | Tool Workflow | Llama al subworkflow del CRM |
| **OpenAI Chat Model** | LLM | Modelo GPT-5 para razonamiento del agente |
| **Simple Memory** | Memory Buffer | Mantiene el contexto de la conversación |
| **Send a Text Message** | Telegram | Envía la respuesta procesada al usuario |

---

## 🧠 Lógica del Agente Coordinador

El **AI Agent** en `G_CRM` utiliza el siguiente prompt (recortado para claridad):

> You are the Master Coordinator Agent.  
> When the user asks for customer information, call Sub_WF_CRM.  
> When the user asks for analytics (totals, counts, or active customers), use CRM data to give the **exact values**.  
> When unrelated, respond politely.

### 🔍 Ejemplos de interacción

| Consulta del usuario | Acción ejecutada | Respuesta esperada |
|----------------------|------------------|--------------------|
| “Show me info for alice@mail.com” | Llama a `Sub_WF_CRM` con el email | “Customer Alice Johnson (ID: CUST001) from New York is active on the Premium plan…” |
| “How many customers do we have?” | Calcula el total desde CRM | “We currently have 245 customers registered.” |
| “How many active customers?” | Filtra por `Status = Active` | “There are 192 active customers in total.” |
| “What promotions are available?” | No CRM → respuesta educada | “My focus is on CRM records and analytics.” |

---

## 🚀 Instrucciones paso a paso

### 1. Subir los workflows

1. Guardá ambos archivos JSON en tu computador:
   
   - [G_CRM.json](./G_CRM.json)
   - [Sub_WF_CRM.json](./Sub_WF_CRM.json)


### 2. Importar en n8n

En tu instancia de n8n:
1. Clic en **Import Workflow**.
2. Subí `Sub_WF_CRM.json` → activalo.
3. Subí `G_CRM.json` → activalo.
4. Verificá que los IDs de conexión coincidan (nodos de modelo, credenciales, etc.).

### 3. Configurar credenciales

- **Telegram API:** crear un bot con [@BotFather](https://t.me/botfather) y guardar el token en n8n.  
- **Google Sheets OAuth2:** conectar tu cuenta de Google y permitir acceso al archivo.  
- **OpenAI API:** usar tu clave personal o la provista en clase.

### 4. Probar el flujo completo

1. Abrí Telegram y enviá un mensaje al bot:
   - “Show me information for alice@mail.com”
   - “How many active customers?”
2. Revisá el output directo en el chat y en el panel de ejecuciones de n8n.


---
[⬅ Back to Course Overview](../../README.md)
