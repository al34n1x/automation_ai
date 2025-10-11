# 🧪 Lab “Hello Agent” — n8n en 10 minutos (versión Chat Trigger)

## 🎯 Objetivo
Crear un flujo mínimo en **n8n** que:
1. Reciba un mensaje mediante el **Chat Trigger** integrado  
2. Lo procese con un **Agente/LLM**  
3. Responda usando el **Chat Response Node**  

> **Opcional (extra 5 min):** guardar un log en **Google Sheets**.

---

## ✅ Prerrequisitos
- Cuenta en **n8n** (self-hosted o cloud)  
- Credencial de **OpenAI** configurada  
- (Opcional) Cuenta Google para Google Sheets (OAuth)

---

## 🧱 Estructura del flujo

```
[Chat Trigger] → [Agente (OpenAI Chat / Conversational Agent)]
                         ↓
              [Respond to Chat Message]
                         ↓
              (Opcional) [Google Sheets: Append Log]
```

---

## 🧩 Paso a paso

### 1) Chat Trigger
- **Nodo:** `Chat Trigger`  
- Este nodo activa el flujo cada vez que el usuario envía un mensaje a través del chat público del workflow (o del widget embebido).  
- Guardá el **Chat URL** que aparece al activar el flujo: esa será la dirección donde podrás enviar mensajes.

> Tip: Podés abrir el enlace del chat en una nueva pestaña y probar mensajes como “Hola” o “¿qué podés hacer?”.

---

### 2) Agente (OpenAI Chat o Conversational Agent)

#### **Opción A – OpenAI Chat (simple)**
- **Nodo:** OpenAI (resource: `chat`)  
- **Modelo:** `gpt-4o-mini`, `gpt-4-turbo`, o similar  
- **System message:**
  ```
  Sos un asistente breve y claro. 
  Respondé en la misma lengua del usuario.
  Mantené la respuesta en 1–2 oraciones, sin emojis.
  ```
- **User message:**  
  `={{$json.chat.message}}`

#### **Opción B – Conversational Agent**
- **System message:**
  ```
  Sos un asistente breve y claro. 
  Respondé en la misma lengua del usuario.
  Si no entendés la consulta, pedí amablemente que la reformule en una sola frase.
  ```
- **Entrada:**  
  `={{$json.chat.message}}`

---

### 3) Responder al mensaje
- **Nodo:** `Respond to Chat Message`  
- **Message:**  
  - Para OpenAI Chat: `={{$json.data || $json.response || $json.text}}`  
  - Para Conversational Agent: `={{$json.text}}`

> Este nodo responde directamente en el mismo chat que activó el trigger.

---

## 🧪 Probar
1. Activá el workflow.  
2. Abrí el **Chat URL** desde el Chat Trigger.  
3. Escribí mensajes como:  
   - “Hola, ¿qué podés hacer?”  
   - “Dame un tip de productividad.”  
4. El agente debe contestar en **1–2 oraciones**, claro y sin emojis.

---

## 🧰 (Opcional) Logging en Google Sheets (5 min extra)

### Preparar hoja
- Google Sheet con pestaña `Logs` y columnas:
  | timestamp | chat_id | username | mensaje | respuesta |
  |-----------|---------|----------|---------|-----------|

### Nodo: Set (armar fila)
- **Valores:**
  - `timestamp` → `={{$now}}`
  - `chat_id` → `={{$json.chat.id}}`
  - `username` → `={{$json.chat.user.name || ""}}`
  - `mensaje` → `={{$json.chat.message}}`
  - `respuesta` → `={{$json.data || $json.response || $json.text}}`

### Nodo: Google Sheets (Append)
- **Operation:** `Append`  
- **Sheet:** `Logs`  
- **Spreadsheet:** tu Google Sheet  
- Conectar después del **Respond to Chat Message**.

---

## 🛡️ Buenas prácticas express
- **Costo bajo:** prompt breve, temperatura baja.  
- **Respuestas predecibles:** limitar a 1–2 oraciones.  
- **Fallback:** si el agente falla, enviar un mensaje fijo como:  
  - “Tuve un problema para responder. ¿Podés repetir en una frase?”

---

## 🧷 Troubleshooting rápido
- **No llegan mensajes:** asegurate de que el workflow esté activo y usás el **Chat URL correcto**.  
- **Mensaje vacío:** revisá el output del agente y ajustá el campo (`data`, `response`, `text`).  
- **Error de credenciales:** reautorizar OpenAI/Google.

---

## ⏱️ Resultado esperado
En 10–15 minutos vas a tener:
- Un chat embebido que recibe mensajes directamente desde n8n.  
- Un agente que procesa y responde de forma breve y útil.  
- (Opcional) Un log de interacciones en Google Sheets.

---

[⬅ Volver al Inicio del Curso](../../README.md)
