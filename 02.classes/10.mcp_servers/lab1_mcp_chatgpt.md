# Guía de Integración: Claude Desktop con MCP Server en n8n

Esta guía explica paso a paso cómo integrar con un MCP Client y con **ChatGPT** con un **MCP Server** expuesto desde n8n, de modo que puedas enviar queries directamente a tu flujo de automatización.

---

## 📋 Requisitos Previos

- Tener instalado [n8n](https://n8n.io) y acceso al **dashboard**.
- Contar con un flujo en n8n que tenga configurado un **MCP Server Trigger**.
- Acceso a [ChatGPT](https://chatgpt.com/).
- Conocimientos básicos de edición de archivos de configuración JSON.

---

## 🔧 Pasos de Configuración

### 1. Crear un nuevo Workflow en n8n
- Ingresa al dashboard de n8n.
- Haz clic en **"New Workflow"**.
- Nombra el flujo, por ejemplo: `MCP Server Workflow`.
- Importa el siguiente Flujo [MCP Server](./MCP%20Server.json)

---

### 2. Copiar la URL del MCP Server
- Una vez configurado el nodo, copia la URL que aparece en el panel del nodo o en la pestaña de ejecución.
- Ejemplo de URL:  
  ```
  https://geekbydefault.co/mcp/agent
  ```

---

### 3. Activar el Workflow
- Haz clic en **Activate** para poner en marcha el flujo.
- Verifica que el workflow quede marcado como activo (ícono verde).

---

### 4. Importar el cliente
- Crea un nuevo flujo en n8n.
- Importa el siguiente Flujo [MCP Client](./MCP%20Client_Demo.json)

---

### 5. Realiza una consulta
- Verifica en ambos flujos que las credenciales de las herramientas como OpenAI y Google, al igual que el Vector Store sean las correctas.
- Desdel el flujo del MCP Client abre la ventana de chat y realiza una consulta como por ejemplo:

```
Dame la lista de clientes
```

```
Creame una página web en HTML que muestre la lista de clientes
```

```
Dame los últimos correos
```
---

### 6. Integrar con ChatGPT
- Abre un nuevo Chat en ChatGPT.
- Agrega nuevas fuentes de información
- Haz Click en **Add** y selecciona **Connect more**
- Desplazate al final y selecciona **Advanced Settings**
- Habilita el modo **Developer**
- Haz click en **Crear**
- Completa los siguientes datos:
  - Name
  - Description
  - MCP Server URL: La copias desde el flujo de MCP Server. La Production URL
  - Authentication: Sin Authentication
  - Acepta las condiciones de uso
  - Click en crear
  - Refresca la página

### 7. Realiza una consulta desde ChatGPT
- Abre el Chat en ChatGPT.
- Verifica que tengas el MCP server listado como herramienta/fuente
- Haz una consulta

```
Dame la lista de clientes
```

```
Creame una página web en HTML que muestre la lista de clientes
```

```
Dame los últimos correos
```

---
[⬅ Back to Course Overview](../../README.md)