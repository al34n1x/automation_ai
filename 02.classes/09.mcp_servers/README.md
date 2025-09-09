# 🤖 N8N y MCP Servers: Automatización Inteligente para el Futuro

¡Bienvenidos a una de las clases más emocionantes del curso! 🎉 Hoy vamos a explorar cómo N8N y los MCP (Model Context Protocol) Servers pueden revolucionar la forma en que automatizamos tareas con inteligencia artificial.


## 📋 Tabla de Contenidos

1. [¿Qué son los MCP Servers?](#qué-son-los-mcp-servers)
2. [Instalación y Configuración](#instalación-y-configuración)
3. [Tu Primer Workflow en N8N](#tu-primer-workflow-en-n8n)
4. [Integrando MCP Servers](#integrando-mcp-servers)
5. [Ejemplos Prácticos](#ejemplos-prácticos)
6. [Mejores Prácticas](#mejores-prácticas)
7. [Recursos Adicionales](#recursos-adicionales)

---


## 🔌 ¿Qué son los MCP Servers?

Los **MCP (Model Context Protocol) Servers** son la nueva frontera en la automatización con IA. Piensa en ellos como "traductores universales" que permiten que los modelos de IA interactúen directamente con tus herramientas y servicios.

### ¿Cómo funcionan?

```
┌─────────────┐    ┌─────────────┐    ┌─────────────────┐
│ Modelo de IA│───▶│ MCP Server  │───▶│  Tu Aplicación  │
└─────────────┘    └─────────────┘    └─────────────────┘
                          │
                          ├───▶┌─────────────────┐
                          │    │  Base de Datos  │
                          │    └─────────────────┘
                          │
                          └───▶┌─────────────────┐
                               │   API Externa   │
                               └─────────────────┘
```

### Ventajas de los MCP Servers:

- 🎯 **Contexto en tiempo real**: Los modelos de IA acceden a información actualizada
- 🔧 **Acciones directas**: Pueden realizar tareas, no solo responder preguntas
- 🌐 **Interoperabilidad**: Un protocolo estándar para todas las herramientas
- 🛡️ **Seguridad**: Control granular sobre qué puede hacer la IA

---

### Configurando tu primer MCP Server

```javascript
// Ejemplo básico de MCP Server en Node.js
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const server = new Server(
  {
    name: "mi-primer-mcp-server",
    version: "0.1.0",
  },
  {
    capabilities: {
      resources: {},
      tools: {},
    },
  }
);

// Configurar herramientas disponibles
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "get_weather",
        description: "Obtener el clima actual",
        inputSchema: {
          type: "object",
          properties: {
            city: {
              type: "string",
              description: "Ciudad para consultar el clima"
            }
          },
          required: ["city"]
        }
      }
    ]
  };
});
```

---

## 🎯 Tu Primer Workflow en N8N

Vamos a crear un workflow simple pero poderoso que automatice el procesamiento de emails con IA.

### Paso 1: Configurar el Trigger

1. Abre N8N en `http://<tuinstancia>.n8n.io` o `http://localhost:5678`
2. Crea un nuevo workflow
3. Arrastra el nodo **Gmail Trigger**
2. Crea un nuevo workflow
3. Arrastra el nodo **Gmail Trigger**
4. Configura tus credenciales de Gmail

### Paso 2: Procesar con IA

```json
{
  "nodes": [
    {
      "parameters": {
        "pollTimes": {
          "item": [
            {
              "mode": "everyMinute"
            }
          ]
        }
      },
      "type": "n8n-nodes-base.gmailTrigger",
      "name": "Gmail Trigger",
      "position": [250, 300]
    },
    {
      "parameters": {
        "model": "gpt-3.5-turbo",
        "messages": {
          "messageValues": [
            {
              "role": "system",
              "content": "Analiza este email y clasifícalo como: urgente, importante, spam, o normal"
            },
            {
              "role": "user", 
              "content": "={{ $json.snippet }}"
            }
          ]
        }
      },
      "type": "n8n-nodes-base.openAi",
      "name": "Clasificar Email",
      "position": [450, 300]
    }
  ]
}
```

### Paso 3: Automatizar Respuestas

Agrega nodos condicionales para responder automáticamente según la clasificación:

```
📧 Email Urgente → Notificación Slack
📝 Email Normal → Archivar automáticamente  
🚨 Spam → Mover a carpeta spam
```

---

## 🔗 Integrando MCP Servers

### Ejemplo: MCP Server para Gestión de Tareas

```python
# task_manager_mcp.py
from mcp.server.models import InitializationOptions
from mcp.server import NotificationOptions, Server
import json

app = Server("task-manager")

# Base de datos simple en memoria
tasks = []

@app.list_tools()
async def handle_list_tools() -> list[Tool]:
    return [
        Tool(
            name="create_task",
            description="Crear nueva tarea",
            inputSchema={
                "type": "object",
                "properties": {
                    "title": {"type": "string"},
                    "priority": {"type": "string", "enum": ["low", "medium", "high"]},
                    "due_date": {"type": "string"}
                },
                "required": ["title"]
            }
        ),
        Tool(
            name="list_tasks",
            description="Listar todas las tareas",
            inputSchema={"type": "object", "properties": {}}
        )
    ]

@app.call_tool()
async def handle_call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "create_task":
        task = {
            "id": len(tasks) + 1,
            "title": arguments["title"],
            "priority": arguments.get("priority", "medium"),
            "due_date": arguments.get("due_date"),
            "status": "pending"
        }
        tasks.append(task)
        return [TextContent(type="text", text=f"Tarea creada: {json.dumps(task)}")]
    
    elif name == "list_tasks":
        return [TextContent(type="text", text=json.dumps(tasks, indent=2))]
```

### Conectando MCP con N8N

```javascript
// Nodo personalizado para N8N que usa MCP
{
  "parameters": {
    "mcp_server_url": "http://localhost:8000",
    "tool": "create_task",
    "arguments": {
      "title": "={{ $json.email_subject }}",
      "priority": "={{ $json.ai_classification === 'urgent' ? 'high' : 'medium' }}",
      "due_date": "={{ $now.plus({days: 3}).toISO() }}"
    }
  },
  "type": "n8n-nodes-base.httpRequest",
  "name": "Crear Tarea MCP"
}
```

---

## 💡 Ejemplos Prácticos

### 1. 📊 Automatización de Reportes de Ventas

**Flujo**: Google Sheets → Análisis con IA → Reporte PDF → Envío por Email

```json
{
  "workflow": {
    "name": "Reporte Ventas Automatizado",
    "nodes": [
      {
        "type": "googleSheets",
        "operation": "read",
        "parameters": {
          "range": "A1:Z100"
        }
      },
      {
        "type": "openAi",
        "parameters": {
          "prompt": "Analiza estos datos de ventas y crea un resumen ejecutivo con insights clave y recomendaciones"
        }
      },
      {
        "type": "pdf",
        "operation": "create",
        "parameters": {
          "template": "reporte_ventas"
        }
      },
      {
        "type": "gmail",
        "operation": "send",
        "parameters": {
          "to": "gerencia@empresa.com",
          "subject": "Reporte Semanal de Ventas"
        }
      }
    ]
  }
}
```

### 2. 🎧 Procesamiento Inteligente de Tickets de Soporte

**Flujo**: Zendesk → Análisis de Sentimiento → Priorización → Asignación Automática

```python
# MCP Server para análisis de tickets
@app.call_tool()
async def analyze_ticket(ticket_content: str) -> dict:
    # Análisis de sentimiento
    sentiment = analyze_sentiment(ticket_content)
    
    # Clasificación automática
    category = classify_issue(ticket_content)
    
    # Nivel de urgencia
    urgency = calculate_urgency(sentiment, category)
    
    return {
        "sentiment": sentiment,
        "category": category,
        "urgency": urgency,
        "suggested_agent": assign_best_agent(category, urgency)
    }
```

### 3. 🛒 E-commerce: Gestión Inteligente de Inventario

**Características**:
- Predicción de demanda con IA
- Alertas automáticas de stock bajo
- Reordenamiento automático de productos

```yaml
workflow:
  name: "Gestión Inteligente de Inventario"
  trigger: 
    type: "schedule"
    interval: "daily"
  
  steps:
    1: 
      node: "shopify-inventory"
      action: "get-current-stock"
    
    2:
      node: "ai-predictor" 
      action: "predict-demand"
      input: "historical_sales + current_stock"
    
    3:
      node: "conditional"
      condition: "predicted_stockout < 7_days"
      
    4:
      node: "supplier-api"
      action: "create-purchase-order"
```

---

## 📚 Mejores Prácticas

### 🏗️ Estructura de Workflows

```
1. **Modularidad**: Crear workflows pequeños y reutilizables
2. **Manejo de Errores**: Siempre incluir nodos de error handling
3. **Logging**: Registrar todas las acciones importantes
4. **Testing**: Probar workflows en ambiente de desarrollo primero
```

### 🔒 Seguridad

- **Credenciales**: Usar el sistema de credenciales de N8N, nunca hardcodear
- **Permisos MCP**: Limitar las capacidades de los MCP servers
- **Validación**: Validar todos los inputs antes de procesarlos
- **Monitoring**: Monitorear la ejecución de workflows críticos

### ⚡ Optimización

```javascript
// Ejemplo: Procesamiento en lotes para mejor performance
{
  "parameters": {
    "batchSize": 50,
    "continueOnFail": true,
    "alwaysOutputData": false
  },
  "type": "n8n-nodes-base.code"
}
```

---

## 🎓 Ejercicios Prácticos

### Ejercicio 1: Mi Primer Bot de Productividad
**Objetivo**: Crear un workflow que convierta emails en tareas de Todoist

**Pasos**:
1. Configurar Gmail trigger
2. Usar IA para extraer tareas del contenido
3. Crear tareas en Todoist automáticamente
4. Enviar confirmación

### Ejercicio 2: Análisis de Redes Sociales
**Objetivo**: Monitorear menciones de marca en Twitter y responder automáticamente

**Desafío extra**: Integrar análisis de sentimiento y respuestas personalizadas

### Ejercicio 3: MCP Server Personalizado
**Objetivo**: Crear tu propio MCP server para una funcionalidad específica

**Ideas**:
- Gestión de gastos
- Seguimiento de hábitos
- Análisis de código

---

## 🔧 Troubleshooting Común

### Problemas Frecuentes y Soluciones

| Problema | Causa Común | Solución |
|----------|-------------|----------|
| Workflow no se ejecuta | Credenciales incorrectas | Verificar y reconfigurar credenciales |
| Error de timeout | Procesamiento muy lento | Optimizar consultas y usar paginación |
| MCP server no responde | Puerto ocupado | Verificar puertos y reiniciar servicios |
| Datos corruptos | Formato inesperado | Agregar validación de datos |

### Debug Tips 🐛

```javascript
// Añadir logging detallado
console.log('Input data:', JSON.stringify($input.all(), null, 2));
console.log('Current node:', $node.name);
console.log('Execution ID:', $executionId);
```

---

## 🌐 Recursos Adicionales

### 📖 Documentación Oficial

- **N8N Docs**: [https://docs.n8n.io/](https://docs.n8n.io/)
- **MCP Protocol Spec**: [https://modelcontextprotocol.io/](https://modelcontextprotocol.io/)
- **N8N Community**: [https://community.n8n.io/](https://community.n8n.io/)

### 🎥 Videos Recomendados

- [N8N Complete Tutorial 2024](https://youtube.com/watch?v=example1) - Canal: AutomationAcademy
- [Building MCP Servers from Scratch](https://youtube.com/watch?v=example2) - Canal: AIDevs
- [Advanced N8N Workflows](https://youtube.com/watch?v=example3) - Canal: TechAutomation

### 🛠️ Herramientas Útiles

- **N8N Templates**: [https://n8n.io/workflows](https://n8n.io/workflows)
- **MCP Examples**: [https://github.com/modelcontextprotocol/examples](https://github.com/modelcontextprotocol/examples)
- **Postman for APIs**: Testing de endpoints antes de integrar

### 📚 Lecturas Complementarias

- "Automation First" - Principios de automatización empresarial
- "The Future of Work: Automation and AI" - Harvard Business Review
- "Building Intelligent Systems" - Microsoft AI Engineering

### 🎯 Próximos Pasos

1. **Practica los ejercicios** - La práctica hace al maestro
2. **Únete a la comunidad** - Comparte tus workflows y aprende de otros
3. **Experimenta** - No tengas miedo de probar nuevas integraciones
4. **Contribuye** - Crea y comparte tus propios nodos personalizados

---

## 🎉 Conclusión

¡Felicitaciones! Has dado tus primeros pasos en el mundo de la automatización inteligente con N8N y MCP Servers. Estas herramientas están cambiando la forma en que trabajamos, haciendo que las tareas repetitivas sean cosa del pasado.

### Recuerda:

- **Empieza pequeño**: Automatiza una tarea simple primero
- **Itera y mejora**: Los workflows evolucionan con el tiempo  
- **Comparte conocimiento**: La comunidad de automatización es increíblemente generosa
- **Mantente curioso**: La tecnología avanza rápido, sigue aprendiendo

---
[⬅ Back to Course Overview](../../README.md)