# 🧠 Retrieval‑Augmented Generation (RAG) & Vector Search Databases — For AI Automation (with n8n)

> **Audience:** Non‑technical to intermediate learners  
> **Goal:** Understand RAG end‑to‑end and implement a working RAG workflow in **n8n** using a vector database.  
> **What you’ll get:** Plain‑language explanations, ASCII diagrams, step‑by‑step labs, copy‑paste prompts, example API payloads, and troubleshooting.

---

## 📚 Syllabus (Read Me in Order)

1) Big Picture: What RAG solves (in simple words)  
2) Concepts: Embeddings, vectors, similarity, chunking  
3) Architecture: How a RAG system flows (ASCII diagrams)  
4) Tooling: Vector DB options & when to use them  
5) Implementation in **n8n** (step‑by‑step)  
6) Copy‑paste examples (prompts, bodies, curl)  
7) Testing & evaluation (does it work?)  
8) Troubleshooting & FAQs  
9) Security, cost, and best practices  
10) Glossary

---

## 1) Big Picture — What Problem Does RAG Solve?

Large Language Models (LLMs) are great at writing, explaining, and summarizing—but they can **guess** when they don’t know something or when your company’s policies, prices, or docs weren’t in their training data. That can produce **confident but wrong** answers.

**RAG = Retrieval‑Augmented Generation.**  
Instead of asking the AI to “remember everything,” we **retrieve the right passages** from **your** data (docs, wikis, spreadsheets, emails, PDFs) at question time and give those passages to the model to ground its response.

Think of it like an open‑book exam:  
- **Without RAG:** Student answers from memory only.  
- **With RAG:** Student quickly looks up the relevant page in the book and then answers.

**Results:** more accurate, up‑to‑date, and explainable answers—without retraining the model.

---

## 2) Core Concepts (Plain Language)

### 2.1 Embeddings (turn text into numbers)
We turn text like *“refund policy”* into a list of numbers called a **vector**. This “vector” captures the **meaning** of the text. Similar meanings → similar vectors.

```
"refund policy"  →  [0.12, -0.45, 0.88, ...]   (vector)
"return policy"  →  [0.11, -0.43, 0.90, ...]   (very close in meaning)
```

### 2.2 Vector Databases
A **vector database** stores lots of these vectors (from your documents). When a user asks a question, we:
1) make an **embedding** for the question,  
2) **search** the database for the **most similar** vectors (top‑k results),  
3) feed those text passages to the AI to answer accurately.

Popular vector DBs (any is fine to learn): **Pinecone, Weaviate, Milvus, Qdrant**.

### 2.3 Similarity Search
We measure closeness by **cosine similarity** or **Euclidean distance**. You don’t need the math; just know “higher similarity = more relevant passage.”

### 2.4 Chunking
We split your documents into **small pieces** (“chunks”) before embedding. Typical chunk sizes: **500–1,000 tokens** (words-ish), with a small **overlap** so ideas don’t get cut in half. Good chunking is the #1 quality booster for RAG.

---

## 3) Architecture — How RAG Works (Step‑by‑Step)

### 3.1 High‑Level Flow
```
       ┌──────────────────┐
       │     User Ask     │  e.g., “What is our refund policy?”
       └───────┬──────────┘
               │
               ▼
       ┌──────────────────┐
       │  Embed the Query │  (text → vector)
       └───────┬──────────┘
               │
               ▼
       ┌──────────────────┐
       │ Vector DB Search │  (find top‑k similar chunks)
       └───────┬──────────┘
               │
               ▼
       ┌──────────────────┐
       │   Build Prompt   │  (question + retrieved chunks)
       └───────┬──────────┘
               │
               ▼
       ┌──────────────────┐
       │    LLM Answer    │  (grounded in your data)
       └──────────────────┘
```

### 3.2 What You Need
- **Embedding Model** (e.g., OpenAI embeddings or other vendor)
- **Vector Database** (hosted or self‑hosted)
- **LLM** (OpenAI/Anthropic/etc., or local model)
- **Orchestrator** (we’ll use **n8n** to glue it all together)

---

## 4) Choosing a Vector Database (Simple Guide)

| Option   | Simple to Start | Scales Well | Notes |
|---------|------------------|-------------|-------|
| Pinecone| ⭐⭐⭐⭐            | ⭐⭐⭐⭐⭐      | Fully‑managed, easy APIs |
| Weaviate| ⭐⭐⭐             | ⭐⭐⭐⭐       | Open‑source & hosted options |
| Milvus  | ⭐⭐              | ⭐⭐⭐⭐       | Popular, performance‑focused |
| Qdrant  | ⭐⭐⭐             | ⭐⭐⭐⭐       | Open‑source & hosted options |

**Tip:** If you want “just works,” start with **Pinecone** (hosted). If you want open‑source, **Weaviate** or **Qdrant** are great.

---

## 5) Implementing RAG in **n8n** (Copy‑Pastable Steps)

> You can build this *without coding* using n8n’s nodes. We’ll use generic **HTTP Request** nodes so you can plug in **any** provider. Replace `YOUR_*` placeholders with your real keys/URLs.

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

### 5.2 Nodes (Step‑by‑Step)

#### (A) Trigger
- Use **Telegram Trigger**, **Slack Trigger**, or **Webhook**.  
- Output should contain the user’s **question** in a field like `$json.text` or `$json.query`.

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
- **Mapping tip:** Set a new field `embedding` to `{{$json.data[0].embedding}}` using a **Set** node after the call.

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
- **Result mapping:** Expect something like `matches[].metadata.text` (varies by your upsert format).

#### (D) Build the RAG Prompt (Set Node)
- **Purpose:** Combine the user question + retrieved passages.  
- **Template:**
```
You are a helpful assistant for our organization.
Answer the question using ONLY the context below. If the answer is not in the context, say “I don’t have that information.”

[Context]
{{ $json.matches.map(m => m.metadata.text).join("\n\n---\n\n") }}

[Question]
{{ $json.query || $json.text }}
```
- Store this whole string into a field called `rag_prompt`.

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
- **Pick Output:** `choices[0].message.content` as `final_answer`.

#### (F) Return to User
- Use **Telegram**, **Slack**, or **Webhook Response** to send `$json.final_answer`.

---

## 6) Copy‑Paste: Example `curl` & Payloads

> Useful for quick tests outside n8n (e.g., in your terminal).

### 6.1 Create an Embedding (OpenAI)
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

---

## 7) Preparing Your Data (So Search Actually Works)

**1) Collect Sources:** PDFs, web pages, Google Docs/Sheets, Confluence, emails.  
**2) Clean & Normalize:** Remove headers/footers, fix weird line breaks, convert to plain text.  
**3) Chunk:** 500–1,000 tokens with **overlap (50–200)** so ideas aren’t split.  
**4) Metadata:** Store helpful tags: `title`, `source`, `date`, `url`, `category`, `confidentiality`.  
**5) Upsert:** Embed each chunk and store in your vector DB with metadata.

**Why chunking matters:**  
- Too small ⇒ not enough context.  
- Too big ⇒ more noise and slower search.  
- Sweet spot ⇒ test! Start at ~800 tokens + 100 overlap.

---

## 8) Quality: How to Tell if RAG “Works”

- **Precision@k:** When you fetch top‑k passages, are they actually relevant?  
- **Answer faithfulness:** Does the AI answer only using the provided context?  
- **Grounded citations:** Optionally, include which chunk IDs or URLs were used.  
- **Human spot checks:** Create 10–20 common questions and verify answers.

**Tip:** Lower `temperature` (0.0–0.3) for more deterministic, factual answers.

---

## 9) Troubleshooting

- **Bad or generic answers?**  
  - Check chunking & metadata.  
  - Increase `topK` (e.g., 3 → 6).  
  - Make the system prompt stricter (“If not in context, say you don’t know”).

- **No results from vector DB?**  
  - Ensure you actually upserted vectors.  
  - Confirm index name & environment.  
  - Check that you’re passing the **query embedding** (not raw text).

- **Hallucinations (making stuff up)**  
  - Add: “If uncertain or not in context, say you don’t know.”  
  - Reduce temperature.  
  - Consider smaller context windows with more targeted passages.

- **Costs getting high?**  
  - Use cheaper embedding models.  
  - Cache embeddings (don’t recompute the same docs).  
  - Pre‑filter by metadata (e.g., only “RefundPolicy” docs) before vector search.

---

## 10) Security & Governance

- **Access control:** Filter by user role or department (metadata + pre‑filters).  
- **PII/Secrets:** Don’t index secrets; redact sensitive data before upsert.  
- **Data residency:** Choose DB region that satisfies compliance.  
- **Auditability:** Log which chunks were retrieved for each answer.

---

## 11) Best Practices (Quick Wins)

- Good chunking + overlaps  
- Clean text (no page numbers/boilerplate)  
- Add metadata (title, section, URL)  
- Prompt the model to **only** use provided context  
- Keep temperature low for factual tasks  
- Start small, measure, then scale

---

## 12) Minimal Working Example (All Steps Together in n8n)

> Overview of nodes and the fields you’ll set. You can mirror this exactly in the n8n UI.

1) **Trigger Node** (Webhook or Telegram)  
   - Output field with user question → `query`

2) **HTTP Request — Create Embedding**  
   - URL: `https://api.openai.com/v1/embeddings`  
   - Body: `{ "input": "{{ $json.query }}", "model": "text-embedding-3-small" }`  
   - Map result to `embedding = {{$json.data[0].embedding}}` (via a **Set** node)

3) **HTTP Request — Vector DB Query (Pinecone)**  
   - URL: `https://YOUR_INDEX-YOUR_PROJECT.svc.YOUR_REGION.pinecone.io/query`  
   - Body: `{ "vector": {{ $json.embedding }}, "topK": 4, "includeMetadata": true }`  
   - Expect `matches[].metadata.text`

4) **Set — Build RAG Prompt**  
```
You are a helpful assistant for our organization.
Answer the question using ONLY the context below. If the answer is not in the context, say “I don’t have that information.”

[Context]
{{ $json.matches.map(m => m.metadata.text).join("\n\n---\n\n") }}

[Question]
{{ $json.query }}
```

5) **HTTP Request — LLM Chat**  
   - URL: `https://api.openai.com/v1/chat/completions`  
   - Body:
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

6) **Respond to User** (Telegram/Slack/Webhook Response)  
   - Send `choices[0].message.content`

---

## 13) Frequently Asked Questions (FAQ)

**Q: Do I need to fine‑tune the model?**  
A: Usually no. RAG avoids training costs by retrieving your data at answer time.

**Q: How big can my documents be?**  
A: Any size, as long as you **chunk** them before embedding.

**Q: What if my data is private?**  
A: Host your own vector DB or choose a provider with strong security & region controls. Never index secrets.

**Q: Can I use spreadsheets as sources?**  
A: Yes—export to CSV or pull with an API, then chunk rows or sections as text.

**Q: What is “topK”?**  
A: How many chunks you retrieve. Try 3–8 and evaluate answer quality.

---

## 14) Sane Defaults (Copy These)

- Chunk size: **800 tokens**, overlap **100**  
- topK: **4**  
- Temperature: **0.2**  
- Prompt guardrails: “Answer only from context; otherwise say you don’t know.”

---

## 15) Glossary (Very Short)

- **Embedding:** Turning text into a vector (numbers) that capture meaning.  
- **Vector:** List of numbers representing text meaning.  
- **Vector DB:** Database optimized to search by vector similarity.  
- **Chunking:** Splitting documents into small pieces before embedding.  
- **topK:** Number of most similar chunks to retrieve.  
- **RAG:** Retrieval‑Augmented Generation—LLM answers are grounded by retrieved text.

---

## 16) Credits & Next Steps

- Explore Pinecone, Weaviate, Milvus, or Qdrant docs.  
- Try different embedding models and chunk sizes.  
- Add role‑based filtering to respect data access.  
- Measure quality with a small set of real questions.

Happy building! 🚀

---

[⬅ Back to Course Overview](../../README.md)