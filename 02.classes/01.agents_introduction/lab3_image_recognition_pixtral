# 🧪 Laboratorio — Conexión n8n con Mistral (Pixtral) para Interpretar Imágenes

En este laboratorio aprenderás a usar **n8n** para conectarte a la API de **Mistral**, enviando una imagen a **Pixtral** para que sea interpretada.

---

## 🎯 Objetivo
- Usar **n8n** para hacer una llamada HTTP a la API de Mistral.
- Enviar una imagen a **Pixtral**.
- Recibir y mostrar la interpretación generada por el modelo.

---

## 📋 Requisitos Previos
1. **Cuenta en [Mistral AI](https://console.mistral.ai/api-keys)** con acceso a la API.
2. **API Key** de Mistral.
3. Instalación de **n8n** (local o en la nube).
4. Una imagen para probar (JPG o PNG).

---

## 🛠 Paso 1 — Crear las Credenciales en n8n
1. En n8n, ir a **Credentials**.
2. Crear un nuevo **Mistral Cloud API**.
3. Completar con la API Key de Mistral.
4. Guardar.

---

## 🛠 Paso 2 — Crear el Workflow
1. En n8n, crear un **nuevo workflow**.
2. **Nodo inicial**: `Manual Trigger` para pruebas.
3. **Nodo siguiente**: `HTTP Request`
   - **Method**: `POST`
   - **URL**: `https://api.mistral.ai/v1/chat/completions`
   - **Authentication**: seleccionar las credenciales `Mistral Cloud API`.
   - **Body Content**: seleccionar **JSON** y pegar:

```json
{
    "model": "pixtral-12b-2409",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "What’s in this image?"
          },
          {
            "type": "image_url",
            "image_url": "https://static.wikia.nocookie.net/lotr/images/0/0d/The_One_Ring_on_a_map_of_Middle-earth.jpg"
          }
        ]
      }
    ],
    "max_tokens": 300
  }
```

## 🛠 Paso 3 — Agregar nodo chat

1. Remueve el trigger manual
2. Agrega un nodo ***Chat*** como disparador. El Nodo recibirá como input solo la url de una imagen
3. Reemplaza en el nodo HTTP Request anteriormente creado, la url por la variable de entrada del chat.
4. Prueba el workflow enviandole una url de imagen por el chat y observa la salida. 

## 🛠 Paso 4 (Opcional) — Parsear los datos de salida

1. Agrega un nodo **Code** luego del nodo HTTP Request.
2. Utilizando un LLM (GPT, Claude, etc) crea un código para que pueda parsear los datos de salida del nodo HTTP Request.
3. Vuelve a ejecutar el workflow y observa los resultados. 
