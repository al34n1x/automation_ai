# Orquestación de Agentes en n8n — Guía Paso a Paso

> **Objetivo:** Implementar una automatización multi‑agente en n8n con un **Supervisor (Max)** que orquesta sub‑agentes de **Email**, **Contactos**, **Calendario** y **Contenido**, además de una **Knowledge Base** (RAG) y herramientas auxiliares (Google Search, Calculator).  
> **Audiencia:** Personas con conocimientos básicos de automatización en n8n.  
> **Tiempo estimado:** 90–150 min (con pruebas incluidas).

---

## 1) Arquitectura General

El flujo principal es el **🤖 Supervisor Agent** (Max), que recibe mensajes de chat, usa memoria de ventana, consulta primero la **Knowledge Base** (Pinecone + embeddings de OpenAI) cuando corresponde y **delegará** en sub‑agentes especializados vía `Tool Workflow`:

```
+-----------+       +--------------+       +---------------------------+
| Usuario   | ----> | Chat Trigger | ----> | Supervisor Agent (Max)    |
+-----------+       +--------------+       +---------------------------+
                                                |
                                                |--> [Google Search]
                                                |--> [Calculator]
                                                |--> [Knowledge Base (Pinecone)]
                                                |--> [Email Agent]
                                                |--> [Contact Agent]
                                                |--> [Calendar Agent]
                                                `--> [Content Creator]

```

**Componentes principales:**  
- **Supervisor Agent**: orquestación, herramientas y RAG.  
- **Email Agent**: leer/enviar/responder/buscar emails (Gmail).  
- **Contact Agent**: consultar/crear/actualizar contactos (Google Contacts).  
- **Calendar Agent**: crear/consultar eventos (Google Calendar).  
- **Content Creator**: redacción bajo demanda (SEO/marketing).

> La lógica de ruteo se apoya en prompts y en los `toolWorkflow` que exponen cada sub‑agente como **herramienta invocable**.

---

## 2) Requisitos Previos

1. **n8n** (Cloud o self‑hosted) con acceso a **n8n AI** (nodos de Agentes/LLM).  
2. Credenciales en **n8n**:
   - **OpenAI API** (modelos tipo `gpt-4o` / `gpt-4o-mini`).  
   - **Pinecone** (índice para Knowledge Base).  
   - **Google**:
     - **Gmail OAuth2** (Email Agent).  
     - **Google Contacts OAuth2** (Contact Agent).  
     - **Google Calendar OAuth2** (Calendar Agent).  
   - **SerpAPI** (para Google Search, opcional).
3. (Opcional) Dataset propio para poblar el índice de Pinecone (FAQs, documentación).

---

## 3) Importar los Workflows

Importá en n8n (**Workflows → Import**) los siguientes archivos JSON que compartiste:

- `___Supervisor_Agent.json` — **🤖 Supervisor Agent**  
- `___Email_Agent.json` — **🤖 Email Agent**  
- `___Content_Creator.json` — **🤖 Content Creator**  
- `___Contact_Agent.json` — **🤖 Contact Agent**  
- `___Calendar_Agent.json` — **🤖 Calendar Agent**

> Tras importar, **no actives** aún los workflows. Primero completá credenciales y enlaces entre agentes.

---

## 4) Configurar el **Supervisor Agent**

1. **Entrada**: **When chat message received** (`chatTrigger`) captura el mensaje del usuario.  
2. **LLM**: **OpenAI** como `languageModel` del Agente (recomendado `gpt-4o`).  
3. **Memoria**: **Window Buffer Memory** con `contextWindowLength` (p. ej., 20).  
4. **Herramientas nativas**:  
   - **GoogleSearch** (SerpAPI) para web.  
   - **Calculator** para operaciones aritméticas.  
5. **RAG**:  
   - **Embeddings OpenAI** → **KnowledgeBase (Pinecone)**.  
   - Configurá `toolName: "KnowledgeBase"` para invocarlo como herramienta.  
6. **Sub‑agentes como herramientas** (`Tool Workflow`):  
   - **Email** → Workflow **🤖 Email Agent**.  
   - **Contacts** → Workflow **🤖 Contact Agent**.  
   - **Calendar** → Workflow **🤖 Calendar Agent**.  
   - **Writer** → Workflow **🤖 Content Creator**.  
7. **System Prompt del Supervisor (Max)**: Recordá usar la versión extendida donde **prioriza Knowledge Base** para temas de **SENPAI** y **pide permiso** antes de usar búsqueda web.

**Consejo:** Personalizá el nombre del usuario (Ale) y agregá reglas de formato (JSON estricto cuando una herramienta lo requiera).

---

## 5) Configurar **Email Agent**

**Estructura**  
- Trigger: **When Executed by Another Workflow** (invocado por Supervisor).  
- **AI Agent** con `promptType: define` y `text: {{$json.query}}`.  
- **OpenAI Chat Model** (p. ej., `gpt-4o-mini`).  
- **Gmail Tool** con operaciones típicas:
  - **Send**: `To`, `Subject`, `Message`.  
  - **Search (Get All)**: `Limit`, `Simplify`, filtros.  
  - **Get**: por `Message_ID`.  
  - **Reply**: por `Message_ID` + `Message`.

**Mapeo desde el Agente** (usando `$fromAI`):  
- `To`: `{{$fromAI('To','', 'string')}}`  
- `Subject`: `{{$fromAI('Subject','', 'string')}}`  
- `Message`: `{{$fromAI('Message','', 'string')}}`  
- `Message_ID`: `{{$fromAI('Message_ID','', 'string')}}`  
- `Limit`: `{{$fromAI('Limit','', 'number')}}`  
- `Simplify`: `{{$fromAI('Simplify','', 'boolean')}}`

**Pruebas**  
- “Enviá un correo a `juan@acme.com` con asunto *Reunión* y cuerpo *Nos vemos el viernes*.”  
- “Buscá mis emails no leídos (máximo 5) y mostralos.”

---

## 6) Configurar **Contact Agent**

**Estructura**  
- Trigger: **When Executed by Another Workflow**.  
- **AI Agent** (`promptType: define`, `text: {{$json.query}}`).  
- **OpenAI Chat Model**.  
- **Google Contacts Tool**:
  - **Get All** con `useQuery` y `Query` desde `$fromAI('Query', ...)`.  
  - **Create Contact** con `Given_Name`, `Family_Name`, `Email -> Value`.  
  - **Update contacts** con `Contact_ID` y nuevos `Value` (mails/nombres).

**Ejemplos**  
- “Buscá contactos con mail `@acme.com` (máx. 5).”  
- “Creá un contacto: *María Pérez*, `maria@ejemplo.com`.”  
- “Actualizá el email de *Mary* a `mary.test@test.com`.”

---

## 7) Configurar **Calendar Agent**

**Estructura**  
- Trigger: **When Executed by Another Workflow**.  
- **AI Agent** con contexto de fecha: “Current date and time is `{{ $now.toString() }}`”.  
- **OpenAI Chat Model**.  
- **Google Calendar Tool**:
  - **Create Event**: `Start`, `End`, `Summary` desde `$fromAI(...)`.  
  - **Get Events**: `Limit`, `After (timeMin)`, `Before (timeMax)`.

**Ajustes**  
- Definí la **zona horaria** del workflow.  
- Verificá `callerPolicy` para llamadas del Supervisor.

**Pruebas**  
- “Agendá mañana de 10:00 a 10:30: *Revisión sprint*.”  
- “Listá mis eventos del 1 al 7 del mes próximo (máx. 10).”

---

## 8) Configurar **Content Creator** (opcional)

**Estructura**  
- Trigger: **When Executed by Another Workflow**.  
- **AI Agent** con `systemMessage` de redacción (SEO/marketing).  
- **OpenAI Chat Model**.

**Uso**  
- “Escribí un post corto para LinkedIn sobre orquestación de agentes en n8n.”  
> Recordá: el **Supervisor** no escribe; delega en **Content Creator**.

---

## 9) Conectar todo en el **Supervisor**

1. Abrí el workflow del **Supervisor**.  
2. Verificá conexiones **ai_tool** del nodo **AI Agent** hacia:
   - **Email**, **Contacts**, **Calendar**, **Writer**, **GoogleSearch**, **Calculator**, **KnowledgeBase**.
3. Confirmá **ai_languageModel** (OpenAI) y **ai_memory** (Window Buffer).  
4. En **KnowledgeBase**, revisá **ai_embedding** con **OpenAI Embeddings** y el **índice** de Pinecone.  
5. Ajustá el **System Prompt** del Supervisor (prioridad a **Knowledge base** y consentimiento para búsqueda web).

---

## 10) Pruebas de Extremo a Extremo (E2E)

Ejecutá el **Supervisor** y probá:

- **Contactos**: “Actualizá el email de Ana Pérez a `ana@acme.com` y confirmame el cambio.”  
- **Calendario**: “Creá un evento mañana de 14:00 a 15:00: *Demo con cliente*.”  
- **Email**: “Buscá los últimos 3 emails no leídos y respondé al de *Propuesta* con ‘de acuerdo, avancemos’.”  
- **Contenido**: “Redactá un post SEO sobre orquestación de agentes en n8n para LinkedIn.”  
- **RAG (KB)**: “¿Qué incluye el plan Premium de SENPAI?” → debe responder desde **Knowledge Base**.  
  - Si no hay contexto, Max debe **pedir permiso** para buscar en Internet antes de usar **GoogleSearch**.

---

## 11) Buenas Prácticas y Seguridad

- **Mínimo privilegio** en OAuths de Google y claves de Pinecone/OpenAI.  
- **No** loguees secretos.  
- **Forzá formatos** (JSON estricto) cuando las herramientas lo requieran.  
- **Límites**: establecé `limit` en consultas (emails/eventos/contactos).  
- **Observabilidad**: logs por paso y `Error Trigger` para alertas.  
- **Pruebas**: prompts de regresión canónicos antes de cambios.

---

## 12) Troubleshooting

- **El Supervisor no ve un sub‑agente** → revisá conexiones `ai_tool` y `workflowId` del `Tool Workflow`.  
- **Campos vacíos en Gmail/Calendar/Contacts** → faltan mapeos `$fromAI(...)` o datos del usuario.  
- **RAG sin resultados** → validá índice/documentos en Pinecone y embeddings conectados.  
- **Husos horarios** → ajustá `timezone` en Calendar y normalizá horarios.  
- **Búsqueda web** → requiere **SerpAPI Key** válida.

---

## 13) Extensiones Sugeridas

- Router explícito por intención (FAQ/CRM/SQL/Canales).  
- Validadores de JSON (Code Node) antes de acciones sensibles.  
- Memoria por usuario (Data Store) para preferencias.  
- Guardrails: whitelists de dominios, límites de fecha/hora en Calendar, dominios permitidos para Email en modo demo.



---
[⬅ Back to Course Overview](../../README.md)