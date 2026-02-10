
# 🚀 Agente de WhatsApp con Evolution API en Railway

Este documento explica paso a paso cómo desplegar **Evolution API** en **Railway** y dejarlo listo para integrarlo con WhatsApp.  

---

## 📌 Requisitos previos
- Cuenta en [Railway](https://railway.app) (puedes registrarte con **GitHub** o **Google**).
- Conocimientos básicos de APIs y autenticación.
- Un número de WhatsApp para conectar.

---

## 🛠️ Pasos de configuración

### 1. Ingresar a Railway
- Ve a [https://railway.app](https://railway.app).
- Railway es una plataforma serverless que permite desplegar APIs en cuestión de segundos.
- Inicia sesión o crea una cuenta gratuita.

---

### 2. Crear un nuevo proyecto
- Entra a la siguiente [URL](https://railway.com/deploy/evolution-api-3) 
- Configura to Authorization key.
- Haz clic en deploy
- En el dashboard, haz clic en **“New Project”**.
- Railway permite crear proyectos desde cero, desde GitHub o usando **plantillas**.
- Seleccionaremos la plantilla oficial de Evolution API.

---

### 3. Seleccionar el template de **Evolution API**
- Busca la plantilla **“Evolution API”** en la galería de Railway o utiliza el siguiente [Template](https://railway.com/deploy/pAiAj7?referralCode=btdEUY&utm_medium=integration&utm_source=template&utm_campaign=generic)
- Esta plantilla ya está configurada como **gateway de WhatsApp** mediante WebSockets y REST API.
- Haz clic en **Use Template** para crear el proyecto.

---

### 4. Desplegar el proyecto
- Railway construirá y desplegará el contenedor automáticamente.
- En los logs podrás ver el proceso de build.
- Cuando el estado cambie a **“Deployed”**, tendrás una instancia de Evolution API corriendo en Railway.

---

### 5. Seleccionar la instancia principal
- Haz clic en tu nuevo proyecto dentro del dashboard de Railway.
- Si hay más de un servicio (ejemplo: base de datos, workers), selecciona la instancia llamada **Evolution API**.
- Esta será tu API principal.

---

### 6. Obtener la `AUTHENTICATION_API_KEY`
- Dentro del proyecto, ve a **Settings → Variables**.
- Localiza la variable `AUTHENTICATION_API_KEY`.
- Copia el valor y guárdalo en un lugar seguro.

⚠️ Esta clave funciona como tu credencial de acceso a la API.

---

### 7. Acceder a Evolution API desde Railway
- En **Settings → Domains**, Railway genera un **URL público** para tu servicio.
  - Ejemplo: `https://evolution-api.up.railway.app` 
- Abre un nuevo tab en tu navegato, copia la URL generada por Railway y grega `/manager` al final (https://evolution-api.up.railway.app/manager)

---

### 8. Iniciar sesión en Evolution API
- En la pantalla de login, introduce la `AUTHENTICATION_API_KEY`.
- Una vez autenticado, accederás al **dashboard de Evolution API**, donde podrás:
  - Vincular tu número de WhatsApp.
  - Administrar sesiones.
  - Configurar Webhooks y endpoints para tu agente.

---

## ✅ Resultado esperado
Al completar estos pasos tendrás:
- Un servidor de **Evolution API corriendo en Railway**.
- Acceso autenticado al dashboard de Evolution API.
- Tu entorno listo para vincular un número de WhatsApp y comenzar a construir un **agente conversacional**.

---

## 🚀 Próximos pasos
- Vincular tu número de WhatsApp con Evolution API.
- Integrar Evolution API con **n8n**, Zapier u otras herramientas de automatización.
- Crear flujos de conversación personalizados para tu agente.

> Ahora sigue con el módulo de configuración de la instancia de Evolution API.

---

[⬅ Evolution API Configuration](./02.instance_configuration.md)

[⬅ Back to Course Overview](../../README.md)


