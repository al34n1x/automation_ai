# 🧪 Lab “Hello Agent” — n8n en 10 minutos

## 🎯 Objetivo
Crear un flujo mínimo en **n8n** que:
1. Reciba un mensaje por **Telegram**  
2. Lo procese con un **Agente/LLM**  
3. Responda en **Telegram**  

> **Opcional (extra 5 min):** guardar un log en **Google Sheets**.

---

## ✅ Prerrequisitos
- Cuenta en **n8n** (self-hosted o cloud)
- Bot de **Telegram** creado con **@BotFather** (`BOT_TOKEN`)
- (Opcional) Cuenta Google para Google Sheets (OAuth)

---

## 🧱 Estructura del flujo

```
[Telegram Trigger] → [Agente (OpenAI Chat / Conversational Agent)]
                         ↓
                  [Telegram: Send Message]
                         ↓
              (Opcional) [Google Sheets: Append Log]
```

---

## 🧩 Paso a paso

### 1) Telegram Trigger
- **Nodo**: `Telegram Trigger`  
- **Credencial**: tu bot de Telegram  
- **Updates**: `message`  
- Activá el workflow (n8n registra el webhook automáticamente).

> Tip: Mandá “/start” a tu bot en Telegram para confirmar que está activo.

---

### 2) Agente (OpenAI Chat o Conversational Agent)

#### **Opción A – OpenAI Chat (simple)**
- **Nodo**: OpenAI (resource: `chat`)  
- **Modelo**: `gpt-4o-mini`, `gpt-4-turbo`, o similar  
- **System message:**
  ```
  Sos un asistente breve y claro. 
  Respondé en la misma lengua del usuario.
  Mantené la respuesta en 1–2 oraciones, sin emojis.
  ```
- **User message**:  
  `={{$json.message.text}}`

#### **Opción B – Conversational Agent**
- **System message:**
  ```
  Sos un asistente breve y claro. 
  Respondé en la misma lengua del usuario.
  Si no entendés la consulta, pedí amablemente que la reformule en una sola frase.
  ```
- **Entrada**:  
  `={{$json.message.text}}`

---

### 3) Enviar respuesta por Telegram
- **Nodo**: Telegram (Send Message)  
- **Chat ID**:  
  `={{$json.message.chat.id}}`  
- **Text**:  
  - Para OpenAI Chat: `={{$json.data || $json.response || $json.text}}`  
  - Para Conversational Agent: `={{$json.text}}`

---

## 🧪 Probar
- En Telegram, hablale a tu bot:  
  - “Hola, ¿qué podés hacer?”  
  - “Dame un tip de productividad”  
- Debe contestar en **1–2 oraciones**, claro y sin emojis.

---

## 🧰 (Opcional) Logging en Google Sheets (5 min extra)

### Preparar hoja
- Google Sheet con pestaña `Logs` y columnas:
  | timestamp | chat_id | username | mensaje | respuesta |
  |-----------|---------|----------|---------|-----------|

### Nodo: Set (armar fila)
- **Valores**:
  - `timestamp` → `={{$now}}`
  - `chat_id` → `={{$json.message.chat.id}}`
  - `username` → `={{$json.message.from.username || ""}}`
  - `mensaje` → `={{$json.message.text}}`
  - `respuesta` → `={{$json.data || $json.response || $json.text}}`

### Nodo: Google Sheets (Append)
- **Operation**: `Append`
- **Sheet**: `Logs`
- **Spreadsheet**: tu Google Sheet
- Conectar después del **Telegram: Send Message**.

---

## 🛡️ Buenas prácticas express
- **Costo bajo**: prompt breve, temperatura baja.
- **Respuestas predecibles**: limitar a 1–2 oraciones.
- **Fallback**: si el agente falla, enviar un mensaje fijo como:
  - “Tuve un problema para responder. ¿Podés repetir en una frase?”

---

## 🧷 Troubleshooting rápido
- **No llegan mensajes**: workflow activado + `getWebhookInfo` (Telegram) OK.
- **Mensaje vacío**: revisá el output del agente y ajustá el campo (`data`, `response`, `text`).
- **Error de credenciales**: re-autorizar OpenAI/Telegram/Google.

---

## ⏱️ Resultado esperado
En 10–15 minutos vas a tener:
- Un bot que recibe mensajes por Telegram.
- Un agente que procesa y responde de forma breve y útil.
- (Opcional) Un log de interacciones en Google Sheets.

---

[⬅ Back to Course Overview](../../README.md)