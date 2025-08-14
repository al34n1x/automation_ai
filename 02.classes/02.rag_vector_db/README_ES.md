# 🧠 Generación Aumentada por Recuperación (RAG) y Bases de Datos Vectoriales — Para Automatización con IA (con n8n)

> **Audiencia**: Desde principiantes hasta nivel intermedio
> **Objetivo**: Entender RAG de punta a punta e implementar un flujo RAG funcional en n8n usando una base de datos vectorial.
> **Qué obtendrás**: Explicaciones en lenguaje sencillo, diagramas ASCII, laboratorios paso a paso, prompts listos para copiar y pegar, ejemplos de cargas API y resolución de problemas.

## 📚 Temario (Leé en orden)
1) **Visión general**: Qué problema resuelve RAG (en palabras simples)
2) **Conceptos**: Embeddings, vectores, similitud, fragmentación (chunking)
3) **Arquitectura**: Cómo fluye un sistema RAG (diagramas ASCII)
4) **Herramientas**: Opciones de bases de datos vectoriales y cuándo usarlas
5) **Implementación en n8n**: Paso a paso
6) **Ejemplos para copiar y pegar**: Prompts, cuerpos, curl
7) **Pruebas y evaluación**: ¿Funciona?
8) **Resolución de problemas y FAQs**
9) **Seguridad, costos y buenas prácticas**
10) **Glosario**


## 1) Visión general — ¿Qué problema resuelve RAG?
Los Modelos de Lenguaje Grande (LLM) son excelentes para escribir, explicar y resumir, pero pueden adivinar cuando no saben algo o cuando las políticas, precios o documentación de tu empresa no estaban en sus datos de entrenamiento. Esto puede producir respuestas muy seguras pero equivocadas.

RAG = Retrieval-Augmented Generation (Generación aumentada por recuperación)
En lugar de pedirle a la IA que “recuerde todo”, recuperamos los pasajes correctos de tus datos (documentos, wikis, hojas de cálculo, correos, PDFs) en el momento de la pregunta y se los damos al modelo para fundamentar su respuesta.

Pensalo como un examen con libro abierto:

- **Sin RAG:** El alumno responde solo de memoria.
- **Con RAG:** El alumno busca rápidamente la página relevante en el libro y luego responde.

**Resultados**: respuestas más precisas, actualizadas y explicables—sin reentrenar el modelo.


## 2) Conceptos básicos (en lenguaje claro)

### 2.1 Embeddings (convertir texto en números)
Transformamos texto como “política de reembolso” en una lista de números llamada vector. Este vector captura el significado del texto. Significados similares → vectores similares.

```
"política de reembolso"  →  [0.12, -0.45, 0.88, ...]  
"política de devoluciones" → [0.11, -0.43, 0.90, ...]   (muy cercano en significado)
```

### 2.2 Bases de datos vectoriales
Una base de datos vectorial almacena muchos de estos vectores (provenientes de tus documentos). Cuando un usuario hace una pregunta:

1) **Creamos un embedding de la pregunta.**
2) Buscamos en la base de datos los vectores más similares (top-k resultados).
3) Le damos esos pasajes de texto a la IA para que responda con precisión.

Ejemplos populares: Pinecone, Weaviate, Milvus, Qdrant.

### 2.3 Búsqueda por similitud
Medimos la cercanía usando similitud coseno o distancia euclidiana. No necesitás la matemática: “mayor similitud = pasaje más relevante”.

### 2.4 Fragmentación (chunking)
Dividimos tus documentos en pequeños fragmentos antes de hacer embeddings. Tamaños típicos: 500–1.000 tokens (aprox. palabras), con un pequeño solapamiento para no cortar ideas a la mitad. Un buen chunking es el factor #1 para la calidad en RAG.

3) Arquitectura — Cómo funciona RAG (paso a paso)

### 3.1 Flujo de alto nivel

```
       ┌──────────────────┐
       │   Pregunta del   │  ej: “¿Cuál es nuestra política de reembolso?”
       │      usuario     │
       └───────┬──────────┘
               │
               ▼
       ┌──────────────────┐
       │  Embedding de la │  (texto → vector)
       │     consulta     │
       └───────┬──────────┘
               │
               ▼
       ┌──────────────────┐
       │ Búsqueda en base │  (top-k fragmentos similares)
       │   de vectores    │
       └───────┬──────────┘
               │
               ▼
       ┌──────────────────┐
       │  Construir prompt│  (pregunta + fragmentos recuperados)
       └───────┬──────────┘
               │
               ▼
       ┌──────────────────┐
       │ Respuesta del LLM│  (basada en tus datos)
       └──────────────────┘

```

### 3.2 Lo que necesitás
- **Modelo de embeddings** (ej: OpenAI embeddings u otro proveedor)
- **Base de datos vectorial** (hosteada o local)
- **LLM** (OpenAI/Anthropic/etc., o modelo local)
- **Orquestador** (usaremos n8n para integrarlo todo)

4) Elegir una base de datos vectorial (guía simple)

| Option   | Simple to Start | Scales Well | Notes |
|---------|------------------|-------------|-------|
| Pinecone| ⭐⭐⭐⭐            | ⭐⭐⭐⭐⭐      | Fully‑managed, easy APIs |
| Weaviate| ⭐⭐⭐             | ⭐⭐⭐⭐       | Open‑source & hosted options |
| Milvus  | ⭐⭐              | ⭐⭐⭐⭐       | Popular, performance‑focused |
| Qdrant  | ⭐⭐⭐             | ⭐⭐⭐⭐       | Open‑source & hosted options |

Tip: Si querés algo que “simplemente funcione”, empezá con Pinecone (cloud). Si querés open-source, Weaviate o Qdrant son excelentes.

## 5) Implementar RAG en n8n (pasos listos para pegar)

(Aquí seguirían las secciones con el detalle de nodos, ejemplos curl, preparación de datos, métricas de calidad, troubleshooting, seguridad, buenas prácticas, FAQ y glosario, todo traducido manteniendo formato y código igual al original pero en español.)

### 5.1 Workflow Overview (n8n)
```
┌──────────────┐     ┌───────────────────┐     ┌─────────────────┐
│ User Trigger │───▶ │ Embedding API Call│───▶ │ Vector DB Search│
└──────────────┘     └───────────────────┘     └─────────────────┘
                                                      │
                                                      ▼
                                            ┌────────────────────┐
                                            │  Build RAG Prompt  │
                                            └─────────┬──────────┘
                                                      │
                                                      ▼
                                            ┌────────────────────┐
                                            │     LLM Answer     │
                                            └─────────┬──────────┘
                                                      │
                                                      ▼
                                            ┌────────────────────┐
                                            │ Send Back to User  │
                                            └────────────────────┘
```

### 5.2 Nodos (Paso a paso)

#### (A) Disparador (Trigger)
- Usar **Telegram Trigger**, **Slack Trigger** o **Webhook**.  
- La salida debe contener la **pregunta** del usuario en un campo como `$json.text` o `$json.query`.

#### (B) Create Embedding (OpenAI example via HTTP Request)
- **Method:** `POST`  
- **URL:** `https://api.openai.com/v1/embeddings`  
- **Headers:**  
  - `Authorization: Bearer {{ $env.OPENAI_API_KEY }}`  
  - `Content-Type: application/json`
- **Body (JSON):**
```json
{
  "input": "{{ $json.query || $json.text }}",
  "model": "text-embedding-3-small"
}
```
- **Tip de mapeo:** Crear un nuevo campo `embedding` con `{{$json.data[0].embedding}}` usando un nodo **Set** después de la llamada.

#### (C) Query Vector DB (Pinecone example)
- **Method:** `POST`  
- **URL:** `https://YOUR_INDEX_NAME-YOUR_PROJECT.svc.YOUR_REGION.pinecone.io/query`  
- **Headers:**  
  - `Api-Key: {{ $env.PINECONE_API_KEY }}`  
  - `Content-Type: application/json`
- **Body (JSON):**
```json
{
  "vector": {{ $json.embedding }},
  "topK": 4,
  "includeMetadata": true
}
```
- **Mapeo de resultados:** Esperar algo como `matches[].metadata.text` (puede variar según tu formato de carga).

#### (D) Build the RAG Prompt (Set Node)
- **Propósito:** Combinar la pregunta del usuario + pasajes recuperados.  
- **Plantilla:**
```
Eres un asistente útil para nuestra organización.
Responde la pregunta usando SOLO el contexto de abajo. Si la respuesta no está en el contexto, di “No tengo esa información”.

[Context]
{{ $json.matches.map(m => m.metadata.text).join("\n\n---\n\n") }}

[Question]
{{ $json.query || $json.text }}
```
- Guardar este texto completo en un campo llamado `rag_prompt`.

#### (E) Ask the LLM (OpenAI Chat Completions via HTTP)
- **Method:** `POST`  
- **URL:** `https://api.openai.com/v1/chat/completions`  
- **Headers:**  
  - `Authorization: Bearer {{ $env.OPENAI_API_KEY }}`  
  - `Content-Type: application/json`
- **Body (JSON):**
```json
{
  "model": "gpt-4o-mini",
  "messages": [
    { "role": "system", "content": "You only answer from the provided context. If unsure, say you don’t know." },
    { "role": "user", "content": "{{ $json.rag_prompt }}" }
  ],
  "temperature": 0.2
}
```
- **Seleccionar salida:** `choices[0].message.content` como `final_answer`.

#### (F) Return to User
- Usar **Telegram**, **Slack** o **Webhook Response** para enviar `$json.final_answer`.


## 6) Copy‑Paste: Example `curl` & Payloads

> Útiles para pruebas rápidas fuera de n8n (por ejemplo, en tu terminal).


### 6.2 Consulta a Pinecone (reemplaza la URL por la de tu índice)
```bash
curl https://api.openai.com/v1/embeddings \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": "What is our refund policy?",
    "model": "text-embedding-3-small"
  }'
```

### 6.2 Pinecone Query (replace URL with your index endpoint)
```bash
curl https://YOUR_INDEX-YOUR_PROJECT.svc.YOUR_REGION.pinecone.io/query \
  -H "Api-Key: $PINECONE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "vector": [/* your vector numbers here */],
    "topK": 4,
    "includeMetadata": true
  }'
```

### 6.3 Chat Completion (OpenAI)
```bash
curl https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o-mini",
    "messages": [
      {"role": "system", "content": "Answer only from the provided context."},
      {"role": "user", "content": "CONTEXT: ... \n\nQUESTION: What is our refund policy?"}
    ],
    "temperature": 0.2
  }'
```



## 7) Preparar tus datos (para que la búsqueda funcione)

**1) Recolectar fuentes:** PDFs, páginas web, Google Docs/Sheets, Confluence, correos electrónicos.  
**2) Limpiar y normalizar:** Quitar encabezados/pies de página, corregir saltos de línea extraños, convertir a texto plano.  
**3) Fragmentar:** 500–1.000 tokens con **solapamiento (50–200)** para que las ideas no se corten.  
**4) Metadatos:** Guardar etiquetas útiles: `title`, `source`, `date`, `url`, `category`, `confidentiality`.  
**5) Insertar (Upsert):** Generar embeddings de cada fragmento y guardarlos en tu base vectorial con metadatos.

**Por qué importa el chunking:**  
- Muy chico ⇒ no hay suficiente contexto.  
- Muy grande ⇒ más ruido y búsqueda más lenta.  
- Punto óptimo ⇒ probar; empezar en ~800 tokens + 100 de solapamiento.



## 8) Calidad: Cómo saber si RAG “funciona”

- **Precisión@k:** Al traer los top-k pasajes, ¿son realmente relevantes?  
- **Fidelidad de la respuesta:** ¿La IA responde solo usando el contexto dado?  
- **Citas con referencia:** Opcional, incluir qué IDs de fragmento o URLs se usaron.  
- **Chequeo humano:** Crear 10–20 preguntas comunes y verificar respuestas.

**Tip:** Bajar `temperature` (0.0–0.3) para respuestas más deterministas y factuales.



## 9) Resolución de problemas

- **Respuestas malas o genéricas:**  
  - Revisar chunking y metadatos.  
  - Aumentar `topK` (ej. de 3 → 6).  
  - Hacer el prompt del sistema más estricto (“Si no está en el contexto, di que no lo sabes”).

- **Sin resultados de la base vectorial:**  
  - Confirmar que realmente insertaste los vectores.  
  - Verificar nombre de índice y entorno.  
  - Comprobar que estás enviando el **embedding de la consulta** (no el texto crudo).

- **Alucinaciones (información inventada):**  
  - Agregar: “Si no está en el contexto o no estás seguro, di que no lo sabes.”  
  - Reducir la temperatura.  
  - Usar ventanas de contexto más pequeñas con pasajes más específicos.

- **Costos altos:**  
  - Usar modelos de embeddings más baratos.  
  - Cachear embeddings (no recalcular los mismos documentos).  
  - Filtrar por metadatos antes de buscar (ej. solo documentos de “Política de reembolso”).



## 10) Seguridad y gobernanza

- **Control de acceso:** Filtrar por rol de usuario o departamento (metadatos + pre-filtros).  
- **PII/Secretos:** No indexar datos sensibles; redactar antes de insertarlos.  
- **Residencia de datos:** Elegir región que cumpla normativa.  
- **Auditabilidad:** Registrar qué fragmentos se recuperaron para cada respuesta.



## 11) Buenas prácticas (rápidas de aplicar)

- Buen chunking + solapamiento  
- Texto limpio (sin números de página o plantillas repetitivas)  
- Añadir metadatos (título, sección, URL)  
- Indicar al modelo que **solo** use el contexto dado  
- Mantener temperatura baja para tareas factuales  
- Empezar pequeño, medir y luego escalar



## 12) Preguntas frecuentes (FAQ)

**P: ¿Necesito afinar (fine-tune) el modelo?**  
R: Generalmente no. RAG evita costos de entrenamiento recuperando la información al momento de la respuesta.

**P: ¿Qué tan grandes pueden ser mis documentos?**  
R: De cualquier tamaño, mientras los **fragmentes** antes de generar embeddings.

**P: ¿Y si mis datos son privados?**  
R: Alojar tu propia base vectorial o usar un proveedor con seguridad y control regional sólidos. Nunca indexar secretos.

**P: ¿Puedo usar hojas de cálculo como fuente?**  
R: Sí—exportar a CSV o conectarse con una API, luego fragmentar filas o secciones como texto.

**P: ¿Qué es “topK”?**  
R: La cantidad de fragmentos a recuperar. Probar entre 3–8 y evaluar la calidad.



## 13) Valores recomendados (copiar tal cual)

- Tamaño de chunk: **800 tokens**, solapamiento **100**  
- topK: **4**  
- Temperatura: **0.2**  
- Guardrails de prompt: “Responder solo con el contexto; si no lo sabés, decir que no lo sabés.”



## 14) Glosario (muy breve)

- **Embedding:** Convertir texto en un vector (números) que captura su significado.  
- **Vector:** Lista de números que representan el significado del texto.  
- **Base vectorial:** Base optimizada para buscar por similitud de vectores.  
- **Chunking:** Partir documentos en fragmentos antes de generar embeddings.  
- **topK:** Número de fragmentos más similares a recuperar.  
- **RAG:** Retrieval-Augmented Generation—respuestas fundamentadas en texto recuperado.



## 15) Créditos y próximos pasos

- Explorar la documentación de Pinecone, Weaviate, Milvus o Qdrant.  
- Probar distintos modelos de embeddings y tamaños de fragmentos.  
- Añadir filtrado por rol para respetar el acceso a datos.  
- Medir calidad con un set reducido de preguntas reales.

¡Feliz construcción! 🚀