# Guía de Integración: Claude Desktop con MCP Server en n8n

Esta guía explica paso a paso cómo integrar **Claude Desktop** con un **MCP Server** expuesto desde n8n, de modo que puedas enviar queries directamente a tu flujo de automatización.

---

## 📋 Requisitos Previos

- Tener instalado [n8n](https://n8n.io) y acceso al **dashboard**.
- Contar con un flujo en n8n que tenga configurado un **MCP Server Trigger**.
- Acceso a [Claude Desktop](https://claude.ai/download).
- Conocimientos básicos de edición de archivos de configuración JSON.

---

## 🔧 Pasos de Configuración

### 1. Descargar Claude Desktop
- Descarga Claude Desktop desde la [página oficial](https://claude.ai/download).
- Instálalo en tu sistema operativo (Windows, macOS o Linux).

---

### 2. Crear un nuevo Workflow en n8n
- Ingresa al dashboard de n8n.
- Haz clic en **"New Workflow"**.
- Nombra el flujo, por ejemplo: `MCP Server Workflow`.

---

### 3. Agregar un nodo MCP Server Trigger
- Dentro del workflow, selecciona **Add Node**.
- Busca y selecciona **MCP Server Trigger**.
- Este nodo se encargará de recibir las solicitudes desde Claude Desktop.

---

### 4. Copiar la URL del MCP Server
- Una vez configurado el nodo, copia la URL que aparece en el panel del nodo o en la pestaña de ejecución.
- Ejemplo de URL:  
  ```
  https://geekbydefault.co/mcp/agent
  ```

---

### 5. Activar el Workflow
- Haz clic en **Activate** para poner en marcha el flujo.
- Verifica que el workflow quede marcado como activo (ícono verde).

---

### 6. Abrir Claude Desktop
- Inicia la aplicación Claude Desktop.

---

### 7. Acceder a Settings
- Haz clic en **Settings** en la barra lateral.

---

### 8. Activar opciones de desarrollador
- Dentro de Settings, habilita la opción **Developer Mode** para poder editar la configuración avanzada.

---

### 9. Editar el archivo de configuración
- Abre el archivo `config.json` de Claude Desktop.
- Inserta el siguiente bloque de código dentro del objeto `"mcpServers"`:

```json
{
  "mcpServers": {
    "n8n": {
      "command": "npx",
      "args": [
        "-y",
        "supergateway",
        "--sse",
        "https://geekbydefault.co/mcp/agent",
        "--header",
        "Authorization: Bearer a7b8c9d1e2f3g4h5i6j7k8l9m0n1o2p3q4r5s6t7u83"
      ]
    }
  }
}
```

⚠️ **Importante:**  
- Reemplaza la URL y el token de autorización con los generados en tu instancia de n8n.  
- Guarda los cambios en el archivo `config.json`.

---

### 10. Reabrir Claude Desktop
- Cierra y vuelve a abrir Claude Desktop para aplicar la nueva configuración.

---

### 11. Verificar la conexión
- Dentro de Claude Desktop, revisa que el **MCP Server `n8n`** aparezca como disponible.
- Si todo está bien configurado, Claude podrá enviar queries al workflow en n8n.

---

### 12. Probar una Query
Envía el siguiente prompt en Claude Desktop:

```
Dame la lista de clientes que más han consumido
```

- El request será recibido por n8n a través del MCP Server Trigger.
- Tu workflow procesará la consulta y responderá con los datos solicitados.

---

## ✅ Resultado esperado
- Claude Desktop se conecta exitosamente a tu MCP Server.
- Puedes enviar queries en lenguaje natural a través de Claude y obtener resultados desde tu flujo en n8n.

---

## 🛠️ Solución de problemas

- **Claude no detecta el MCP Server:**  
  Verifica la ruta del archivo `config.json` y que la sintaxis JSON esté correcta.  

- **Error de autorización:**  
  Revisa que el token `Bearer` coincida con el configurado en n8n.  

- **El workflow no recibe nada:**  
  Asegúrate de que el nodo **MCP Server Trigger** esté activo en n8n y que la URL sea accesible públicamente.

---
[⬅ Back to Course Overview](../../README.md)