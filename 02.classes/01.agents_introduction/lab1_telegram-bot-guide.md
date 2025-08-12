# 🤖 Cómo crear un Bot de Telegram (paso a paso)

Guía práctica para crear, configurar y desplegar un **bot de Telegram**, con ejemplos de **Webhook**, **Polling** y un **flujo en n8n** listo para usar.

---

## 📋 Prerrequisitos

- Cuenta de Telegram (app instalada).
- (Opcional) Servidor con **HTTPS** público si vas a usar **webhooks** (dominio + certificado TLS válido).
- (Opcional) Un entorno para correr scripts (Node.js o Python) si usás **polling**.
- (Opcional) Un servidor n8n (local o cloud).

---

## 1️⃣ Crear el bot con BotFather

1. En Telegram, buscá **@BotFather**.
2. Escribí `/start` y luego `/newbot`.
3. Poné un **nombre** (ej.: `Mi Soporte Bot`) y un **username** único que termine en `bot` (ej.: `mi_soporte_bot`).
4. BotFather te dará el **TOKEN** del bot, con este formato:
   ```
   123456789:AAH-xxxxx_yyyyyZZZZZ
   ```
5. **Guardá** ese token de forma segura (variables de entorno, secret manager, etc.).

> 🔒 **Seguridad:** nunca publiques el token en repos públicos. Usá variables de entorno:  
> `TELEGRAM_BOT_TOKEN="123:ABC..."`

---

## 2️⃣ Ajustes básicos en BotFather (opcional)

- **Privacidad (grupos):** `/setprivacy` → elegí tu bot → `Enable`.
- **Descripción y comandos:**
  - `/setdescription` → breve descripción.
  - `/setabouttext` → texto de “about”.
  - `/setcommands` → por ejemplo:
    ```
    start - Iniciar
    help - Ayuda
    info - Información del bot
    ```

---

## 3️⃣ Elegir integración: Webhook vs Polling

### 🔹 Opción A — Webhook (recomendado para producción)
- Telegram **envía** actualizaciones a tu URL HTTPS.
- Menor latencia y consumo.

**Comandos útiles:**
```bash
# Setear webhook
curl -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/setWebhook"   -d "url=https://tu-dominio.com/telegram/webhook"

# Ver estado del webhook
curl "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/getWebhookInfo"

# Borrar webhook
curl "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/deleteWebhook"
```

---

### 🔹 Opción B — Polling (rápido para desarrollo)

**Ejemplo mínimo en Node.js:**
```bash
npm i node-telegram-bot-api
```

```js
const TelegramBot = require('node-telegram-bot-api');
const bot = new TelegramBot(process.env.TELEGRAM_BOT_TOKEN, { polling: true });

bot.onText(/\/start/, (msg) => {
  bot.sendMessage(msg.chat.id, '¡Hola! Soy tu bot 🧠');
});

bot.on('message', (msg) => {
  if (msg.text.toLowerCase().includes('hola')) {
    bot.sendMessage(msg.chat.id, '¡Hola! ¿En qué puedo ayudarte?');
  }
});
```

**Ejemplo mínimo en Python:**
```bash
pip install python-telegram-bot --upgrade
```

```python
import os
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, MessageHandler, filters, ContextTypes

TOKEN = os.environ["TELEGRAM_BOT_TOKEN"]

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text("¡Hola! Soy tu bot 🧠")

app = ApplicationBuilder().token(TOKEN).build()
app.add_handler(CommandHandler("start", start))
app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, start))
app.run_polling()
```

---

## 4️⃣ Flujo listo en n8n (sin código) - Opción preferida

### Paso a paso

1. **Credencial:**
   - En n8n: *Credentials* → **Telegram** → pegá tu token.

2. **Trigger:**
   - Agregá **Telegram Trigger** → `Updates = message`.
   - Activá el workflow (n8n registrará el webhook automáticamente).

3. **Ruteo:**
   - Usar **IF** o **Switch** node para comandos.
   - Ejemplo: `/start` → bienvenida, “precio” → info, else → default.

4. **Respuesta:**
   - **Telegram Send Message**:
     - `Chat ID` = `={{$json.message.chat.id}}`
     - `Text` = tu respuesta.

5. **Integraciones extra:**
   - Google Sheets, HTTP Request, OpenAI, Gmail.

**Ejemplo de teclado inline:**
```json
{
  "inline_keyboard": [
    [
      { "text": "Ver precios", "callback_data": "PRECIOS" },
      { "text": "Hablar con humano", "callback_data": "HUMANO" }
    ]
  ]
}
```

---

## 5️⃣ Enviar mensajes por API

```bash
curl -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage"   -d "chat_id=123456789"   -d "text=¡Hola desde cURL!"
```

---

## 6️⃣ Despliegue y buenas prácticas

- Producción → usar **webhooks**.
- HTTPS estable (n8n Cloud ya incluye).
- Logs de interacciones.
- Validar y sanitizar entradas.
- No exponer el token.
- Backups si guardás datos.

---

## 7️⃣ Problemas comunes

- **No llegan mensajes:** Revisar `getWebhookInfo` y TLS.
- **Doble entrega:** No usar webhook y polling juntos.
- **Error 429:** Respetar rate limits.
- **n8n no responde:** Revisar logs y credenciales.

---

## 📂 Estructura recomendada del repo

```
telegram-bot-starter/
├─ README.md
├─ examples/
│  ├─ node-polling/index.js
│  └─ python-polling/bot.py
└─ n8n/
   └─ workflow-example.json
```

---

## 📚 Recursos útiles

- **Telegram Bot API:** https://core.telegram.org/bots/api  
- **BotFather:** https://core.telegram.org/bots/features#botfather  
- **node-telegram-bot-api:** https://github.com/yagop/node-telegram-bot-api  
- **python-telegram-bot:** https://docs.python-telegram-bot.org/  
- **n8n + Telegram:** https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.telegram/  
- **n8n AI & Agents:** https://docs.n8n.io/integrations/builtin/ai  

---

✅ Con esta guía podés:
- Crear un bot y probarlo rápido con **polling**.
- Subirlo a producción con **webhook**.
- Orquestar lógica y herramientas con **n8n**.

---

[⬅ Back to Course Overview](../../README.md)