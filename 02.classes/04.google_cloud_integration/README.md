# 🚀 Clase: Integración de Google Cloud con n8n y OpenAI


Este workshop enseña a integrar **Google Cloud (Gmail, Sheets, Drive)** con **OpenAI** usando **n8n**.  
Los participantes aprenderán teoría y práctica para crear automatizaciones inteligentes con IA aplicada a datos y comunicaciones.  



## 🔹 Módulo 1 — Introducción

- **n8n**: plataforma de automatización low-code (open source).  
- **Google Cloud + n8n**: orquesta datos y comunicación.  
- **OpenAI**: procesamiento de lenguaje natural (resúmenes, clasificación, respuestas automáticas).  

**Patrón típico de integración:**

```
Trigger (evento) → Proceso IA (OpenAI) → Almacenamiento (Sheets/Drive) → Comunicación (Gmail)
```

---

## 🔹 Módulo 2 — Teoría de Integración con Google Cloud en n8n

### Autenticación
- **OAuth2:** usado en Gmail, Google Sheets, Google Drive.  
- **Service Accounts:** para APIs como BigQuery.  

### Nodos principales
- **Google Sheets Node:** CRUD de filas.  
- **Gmail Node:** leer y enviar correos.  
- **Google Drive Node:** subir, descargar, buscar archivos.  
- **OpenAI Node:** resúmenes, clasificación, generación de respuestas.  

### Ejemplo de uso
- Gmail recibe correo → OpenAI lo resume → Sheets guarda resumen → Gmail responde con template.

---

## 🔹 Módulo 3 — Ejercicio práctico 1  
### 🎯 Mini CRM con Google Sheets + OpenAI

**Objetivo:** consultar datos de clientes y generar respuestas inteligentes.  

1. Crear Google Sheet con columnas:  
   ```
   Email | Nombre | Estado | Plan
   ```

2. Workflow en n8n:  
   - **Webhook Trigger** → recibe email.  
   - **Google Sheets (Lookup)** → busca cliente.  
   - **If Node** → existe o no existe.  
   - **OpenAI Node** → genera mensaje de respuesta.  
   - **Webhook Response** → devuelve JSON con información.  

**Ejemplo de salida:**  

```json
{
  "respuesta": "✅ Cliente encontrado: María González - Activo - Plan Premium"
}
```

---

## 🔹 Módulo 4 - Patrones de integración en proyectos reales

La lógica típica es:

```
Trigger (evento de Google)  
   ↓  
Procesamiento (IA con OpenAI)  
   ↓  
Almacenamiento (Sheets, Drive, BigQuery)  
   ↓  
Comunicación (Gmail, Slack, API externa)

```
### 🔹 Ejemplo 1: Soporte al cliente
- Trigger: Gmail detecta correo nuevo.
- IA (OpenAI): Resumen + clasificación del correo.
- Almacenamiento: Google Sheets guarda remitente, resumen y sentimiento.
- Comunicación: Gmail responde con template automático.

### 🔹 Ejemplo 2: Ventas y marketing
- Trigger: Google Sheets recibe nuevo lead.
- IA (OpenAI): Genera perfil y evalúa intención de compra.
- Almacenamiento: Actualiza Google Sheets con etiqueta “Alto interés / Bajo interés”.
- Comunicación: Gmail envía propuesta personalizada.

### 🔹 Ejemplo 3: Gestión documental
- Trigger: Nuevo documento en Google Drive.
- IA (OpenAI): Lee el texto y lo resume.
- Almacenamiento: Guarda resumen en Sheets.
- Comunicación: Slack notifica al equipo con el resumen.

## 5. Beneficios de usar n8n + Google Cloud + OpenAI
- Automatización completa: entrada de datos (Gmail/Sheets) → procesamiento IA (OpenAI) → salida (Drive, Gmail, Slack).
- Velocidad: fácil de implementar, sin código complejo.
- Escalabilidad: empezar con Gmail/Sheets, luego conectar BigQuery o APIs propias.
- Flexibilidad: OpenAI se adapta a resúmenes, clasificaciones o generación de respuestas.



## 🛠️ Requisitos técnicos

- Cuenta de Google Cloud con acceso a Gmail, Sheets y Drive.  
- Cuenta en [OpenAI](https://platform.openai.com/).  
- Instancia de [n8n](https://n8n.io/) (local o en la nube).  

---

## 📎 Recursos útiles

- [Docs n8n](https://docs.n8n.io/)  
- [Google Cloud APIs](https://cloud.google.com/apis)  
- [OpenAI API](https://platform.openai.com/docs/)  

---

## 🎯 Resultado esperado

Al finalizar la clase, los participantes podrán:  
✅ Conectar n8n con Gmail, Sheets y Drive.  
✅ Usar OpenAI para resumir, clasificar y generar respuestas.  
✅ Construir workflows reales combinando Google Cloud + OpenAI.  
✅ Aplicar el patrón Trigger → IA → Almacenamiento → Comunicación.  

---
