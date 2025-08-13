# 🧠 Lab 1: Retrieval‑Augmented Generation (RAG) & Vector Search Databases - Database feed

## Preparar los accesos y datos
Crea una cuenta en:

- OpenAI (para embeddings y LLM)
- Pinecone u otro vector DB (para almacenar y buscar datos)
- Guarda las claves API de cada servicio.
- Prepara tus documentos (manuales, FAQs, políticas internas).

### Pasos para crear una cuenta en Pinecone

1. Visita el sitio web oficial de Pinecone en [https://www.pinecone.io](https://www.pinecone.io)
2. Haz clic en el botón "Sign Up" o "Get Started" en la página principal
3. Completa el formulario de registro con tu información personal y profesional
4. Verifica tu cuenta a través del correo electrónico que recibirás
5. Inicia sesión en tu cuenta de Pinecone
6. En el panel de control, busca y guarda tu API Key, la necesitarás para conectarte a Pinecone desde tu código
7. En n8n crear una nueva credencial con la clave API de Pinecone.

### Pasos para crear un índice en Pinecone

1. Inicia sesión en tu cuenta de Pinecone
2. En el panel de control, haz clic en "Create Index"
3. Configura tu índice con los siguientes parámetros:
   - Nombre del índice (único en tu cuenta)
   - Dimensión de los vectores (depende del modelo de embeddings que uses, por ejemplo, 1536 para OpenAI)
   - Métrica de similitud (cosine, euclidean, dotproduct)
   - Tipo de índice (dense para búsqueda semántica o sparse para búsqueda léxica)
   - Tipo de despliegue (serverless o pod-based)
4. Haz clic en "Create Index" para finalizar


## Crear flujo - RAG data loader

1. Agrega un trigger manual
2. Agrega un nodo Google Drive (Search file / folder)
3. Agrega un nodo Google Drive (Download file)
4. Agrega un nodo Pinecone Vector Store
5. Configurar los parámetros del vector store.
    - Pinecone account
    - Operation mode: Insert Documents
    - Pinecone index name
    - Pinecone namespace
6. Agrega el embedding the OpenAI (text-embedding-3-small)
7. Agrega un nodo Default Data Loader (Default)
8. Agrega un nodo Recursive Character Text Splitter ald nodo Default Data Loader

El flujo debería lucir así:

![](../../04.assets/images/rag.png)

Este flujo nos permite cargar archivos desde un Google Drive, descargarlos y cargarlos en un vector database (Pinecone) para realizar búsquedas semánticas.

---

[⬅ Back to Course Overview](../../README.md)