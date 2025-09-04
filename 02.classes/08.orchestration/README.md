# Orquestación de Agentes con n8n — Teoría + Casos de Uso

> **Propósito**: guía **teórica y educativa** para entender cómo diseñar orquestación de agentes (LLM + herramientas) en n8n, con **escenarios reales** y criterios de diseño.  
> **Para quién**: público con nociones básicas de automatización.  
> **Enfoque**: sin pasos técnicos ni configuración; **sólo teoría**, decisiones de arquitectura y casos de uso.

---

## Tabla de contenidos

- [1. Conceptos clave](#1-conceptos-clave)
  - [1.1 ¿Qué es un agente?](#11-qué-es-un-agente)
  - [1.2 Orquestación](#12-orquestación)
  - [1.3 Componentes típicos](#13-componentes-típicos)
- [2. Patrones de orquestación](#2-patrones-de-orquestación)
  - [2.1 Router por intención](#21-router-por-intención)
  - [2.2 Supervisor (Planner-Executor)](#22-supervisor-planner-executor)
  - [2.3 Comité de expertos](#23-comité-de-expertos)
  - [2.4 Cadena de herramientas (tool-calling)](#24-cadena-de-herramientas-tool-calling)
- [3. Decisiones de diseño](#3-decisiones-de-diseño)
- [4. Casos de uso (escenarios de implementación)](#4-casos-de-uso-escenarios-de-implementación)
  - [4.1 Atención al cliente con RAG (FAQ multicanal)](#41-atención-al-cliente-con-rag-faq-multicanal)
  - [4.2 Asistente de ventas (CRM + Email)](#42-asistente-de-ventas-crm--email)
  - [4.3 Agenda inteligente (Calendario + Contactos)](#43-agenda-inteligente-calendario--contactos)
  - [4.4 Soporte Técnico / IT Ops (Triage + Escalamiento)](#44-soporte-técnico--it-ops-triage--escalamiento)
  - [4.5 Back-Office Financiero (Validación de facturas)](#45-back-office-financiero-validación-de-facturas)
  - [4.6 Analítica Self-Service (SQL Seguro)](#46-analítica-self-service-sql-seguro)
  - [4.7 Marketing Ops (Pipeline de contenido)](#47-marketing-ops-pipeline-de-contenido)
  - [4.8 Educación corporativa (Tutor inteligente con guardrails)](#48-educación-corporativa-tutor-inteligente-con-guardrails)
- [5. Guardrails imprescindibles](#5-guardrails-imprescindibles)
- [6. Métricas y evaluación](#6-métricas-y-evaluación)
- [7. Antipatrones comunes](#7-antipatrones-comunes)
- [8. Roadmap de madurez](#8-roadmap-de-madurez)
- [9. Checklist antes de lanzar](#9-checklist-antes-de-lanzar)
- [10. FAQ](#10-faq)
- [Licencia](#licencia)

---

## 1. Conceptos clave

### 1.1 ¿Qué es un agente?
Un **agente** es un modelo de lenguaje con:
- **Objetivo** (qué debe lograr),  
- **Herramientas** (APIs, BD, email, búsqueda, planillas),  
- **Políticas** (formato de salida, límites, privacidad, tono),  
- **Memoria** (contexto de conversación o conocimiento persistente),  
- **Criterios de éxito** (cómo sabés que “cumplió”).

> **Idea central**: el agente **no** “sabe todo”. Debe **usar herramientas** y respetar reglas.

### 1.2 Orquestación
**Orquestar** es coordinar **varios** agentes/herramientas para resolver tareas complejas, dividiendo responsabilidades y manteniendo control, trazabilidad y calidad.

### 1.3 Componentes típicos
- **Agente Orquestador** (o “Supervisor”): decide qué subagente/herramienta usar y en qué orden.  
- **Subagentes especialistas**: Email, Calendario, Contactos, SQL, FAQ/RAG, etc.  
- **Fuentes de verdad**: bases de datos, planillas, CRMs, **Vector DB** para RAG.  
- **Canales**: Slack, Telegram, WhatsApp, Web, Email.  
- **Observabilidad**: logs, métricas, auditoría.  
- **Guardrails**: validaciones, límites, confirmaciones humanas.

---

## 2. Patrones de orquestación

### 2.1 Router por intención
**Cuándo**: 3–5 categorías claras (FAQ, CRM, SQL, Agenda).  
**Cómo funciona**: un agente **clasifica** la intención y **deriva** al subagente correcto.

```
[Usuario] -> [Router] -> (faq | crm | sql | calendar | email) -> [Respuesta]
```

**Pros**: simple, rápido, barato.  
**Contras**: una **mala ruta** afecta todo; requiere validación mínima.

---

### 2.2 Supervisor (Planner-Executor)
**Cuándo**: tareas con varios pasos y dependencias.  
**Cómo funciona**: el “Planner” **descompone** la tarea, ejecuta pasos con subagentes y **consolida** resultados.

```
[Usuario] -> [Planner] -> [Pasos]
                 |-> paso1 -> [Agente A]
                 |-> paso2 -> [Agente B]
                 `-> ...
             -> [Unificador] -> [Respuesta]
```

**Pros**: flexible, escalable.  
**Contras**: más latencia/coste, mayor complejidad.

---

### 2.3 Comité de expertos
**Cuándo**: dominios ambiguos o críticos.  
**Cómo funciona**: varios expertos **opinan** y un árbitro **unifica**.

```
[Usuario] -> [Experto 1]
           -> [Experto 2]
           -> [Experto 3]
                \___ [Árbitro] -> [Respuesta]
```

**Pros**: robustez.  
**Contras**: costo/latencia altos.

---

### 2.4 Cadena de herramientas (tool-calling)
**Cuándo**: el agente debe **activar acciones** en secuencia (buscar → filtrar → formatear → enviar).

```
[Agente Principal] -> {action:..., args:{...}} -> [Herramienta]
                                         (n pasos) -> [Salida]
```

**Pros**: auditable y potente.  
**Contras**: exige **JSON estricto** y límites claros.

---

## 3. Decisiones de diseño

- **Fuente prioritaria**: si hay **RAG/KB**, consultarla **antes** que la web.  
- **Consentimiento**: pedir permiso explícito antes de buscar en Internet.  
- **Privacidad**: mínimo privilegio; no exponer PII en logs.  
- **Validaciones**: formatos **estrictos** (JSON) cuando una acción ejecuta efectos (email, agenda, DB).  
- **Idempotencia**: reintentos que no dupliquen efectos (p. ej., evitar duplicar correos).  
- **Observabilidad**: logs por paso, tiempos, errores con contexto utilizable.  
- **SLA**: latencia, coste y disponibilidad; límites de tokens y top_k.  
- **HITL**: confirmación humana para acciones críticas.

---

## 4. Casos de uso (escenarios de implementación)

> Estructura: **Objetivo → Flujo → Agentes/Herramientas → Guardrails → KPIs → Señales**

### 4.1 Atención al cliente con RAG (FAQ multicanal)
**Objetivo**: responder preguntas frecuentes con **cero alucinaciones**.  
**Flujo**:
```
Canal (Slack/WA/Web) -> Router -> FAQ/RAG -> Formateador -> Respuesta
```
**Agentes/Herramientas**: Router, Agente FAQ (RAG), Vector DB (KB), Formateador.  
**Guardrails**: si el contexto KB es insuficiente, pedir aclaración o permiso para web. Marcar “(fuente: KB)”.  
**KPIs**: resolución en 1ª respuesta, % “sin contexto”, tiempo por ticket.  
**Señales**: éxito = consistencia con KB; fallo = inventa políticas/precios.

**Ejemplo de escenario**  
- *Usuario*: “¿Qué incluye el plan Premium?”  
- *Agente*: consulta KB; si encuentra info suficiente, responde y cita KB. Si no, pide permiso para buscar en la web o solicita un dato faltante.

---

### 4.2 Asistente de ventas (CRM + Email)
**Objetivo**: enriquecer ficha del lead y enviar un **borrador** de seguimiento.  
**Flujo**:
```
Usuario -> Router -> CRM (consulta/enriquecimiento)
                 -> (si ok) Email (borrador) -> (HITL) Aprobación -> Envío
```
**Agentes/Herramientas**: CRM Agent (lectura/actualización), Email Agent (borrador).  
**Guardrails**: correo en **borrador** y **aprobación humana**. No loguear PII.  
**KPIs**: leads enriquecidos, tasa de aprobación, respuesta a correos.  
**Señales**: éxito = mails personalizados correctos; fallo = envíos sin datos básicos.

**Ejemplo de escenario**  
- *Usuario*: “Prepará un mail de seguimiento para maría@acme.com con su último interés.”  
- *Agente*: consulta CRM, arma borrador con detalles y solicita aprobación para enviar.

---

### 4.3 Agenda inteligente (Calendario + Contactos)
**Objetivo**: agendar/reprogramar respetando preferencias y zonas horarias.  
**Flujo**:
```
Usuario -> Planner (preferencias/slots)
        -> Calendar Agent + Contacts Agent
        -> Propuesta -> (HITL) Confirmación -> Alta evento
```
**Guardrails**: confirmación humana antes de invitar externos; zona horaria explícita.  
**KPIs**: conflictos evitados, tiempo hasta confirmación, satisfacción.  
**Señales**: éxito = menos idas y vueltas; fallo = solapamientos/errores de horario.

**Ejemplo de escenario**  
- *Usuario*: “Armá un slot de 30’ mañana entre 10 y 12 con Ana y Tomás.”  
- *Agente*: verifica disponibilidad, propone 2–3 horarios y pide confirmación para crear el evento.

---

### 4.4 Soporte Técnico / IT Ops (Triage + Escalamiento)
**Objetivo**: clasificar incidentes y ejecutar runbooks **read-only**/seguros.  
**Flujo**:
```
Ticket -> Router (incidente/consulta)
       -> (incidente) Planner -> Acciones (consultas métricas/logs)
       -> Si no resuelve -> Escalar con contexto
```
**Guardrails**: por defecto **read-only**; cambios requieren HITL.  
**KPIs**: MTTA/MTTR, % auto-resueltas, falsos positivos.  
**Señales**: éxito = aplica runbooks y documenta; fallo = acciones sin trazas.

**Ejemplo de escenario**  
- *Usuario*: “El servicio X está lento.”  
- *Agente*: corre verificación de salud y métricas, adjunta hallazgos, propone opciones y escalamiento con contexto si es necesario.

---

### 4.5 Back-Office Financiero (Validación de facturas)
**Objetivo**: extraer campos y validar contra reglas.  
**Flujo**:
```
Entrada (PDF/Email) -> Extracción (OCR/LLM) -> Validador (reglas)
                    -> (ok) Aprobar/Registrar | (fail) Solicitar corrección
```
**Guardrails**: doble validación para montos; auditoría.  
**KPIs**: % validaciones automáticas, errores, tiempo por factura.  
**Señales**: éxito = menos carga manual; fallo = aprobar inconsistencias.

**Ejemplo de escenario**  
- *Usuario*: “Procesá el lote de facturas de proveedores.”  
- *Agente*: extrae, valida reglas (IVA/total/fechas) y marca las que requieren revisión.

---

### 4.6 Analítica Self-Service (SQL Seguro)
**Objetivo**: consultas en lenguaje natural → **solo SELECT**.  
**Flujo**:
```
Usuario -> SQL Agent (genera SELECT) -> Validador -> Ejecutar -> Resumen + tabla
```
**Guardrails**: lista blanca de tablas/campos, **LIMIT 50**, filtros obligatorios.  
**KPIs**: consultas exitosas, latencia, incidentes.  
**Señales**: éxito = respuestas útiles y seguras; fallo = queries pesadas o peligrosas.

**Ejemplo de escenario**  
- *Usuario*: “Top 5 clientes por gasto en 2024.”  
- *Agente*: genera SELECT con LIMIT y filtros; si faltan datos (fechas/segmentos), pide precisión.

---

### 4.7 Marketing Ops (Pipeline de contenido)
**Objetivo**: research → brief → borrador → QA → publicación (HITL).  
**Flujo**:
```
Brief -> (si KB) RAG -> Research web (con permiso)
      -> Content Agent (borrador) -> QA (humano) -> Publicar
```
**Guardrails**: citar fuentes, evitar claims sin evidencia, revisión humana.  
**KPIs**: tiempo de ciclo, engagement, retrabajos.  
**Señales**: éxito = contenidos útiles; fallo = plagio o info errónea.

**Ejemplo de escenario**  
- *Usuario*: “Prepará un post de anuncio de features con fuentes verificadas.”  
- *Agente*: usa KB, pide permiso para web si hace falta, arma borrador y lo manda a QA.

---

### 4.8 Educación corporativa (Tutor inteligente con guardrails)
**Objetivo**: tutor que responde sobre material interno, sin “inventar”.  
**Flujo**:
```
Canal -> Router -> Tutor RAG -> Respuesta
          (si falta contexto) -> pedir aclaración o permiso web
```
**Guardrails**: “única fuente” KB; web solo con consentimiento; marcar fuente en la respuesta.  
**KPIs**: exactitud vs. material oficial, satisfacción, % respuestas “no sé”.  
**Señales**: éxito = alineado con contenido oficial; fallo = contradicciones.

**Ejemplo de escenario**  
- *Usuario*: “¿Cuál es la política de licencias?”  
- *Agente*: responde sólo si está en KB; si no, indica que no tiene contexto y ofrece opciones.

---

## 5. Guardrails imprescindibles

- **Fuente prioritaria**: KB/RAG antes que web.  
- **Consentimiento web**: preguntar antes de buscar en Internet.  
- **Acciones sensibles**: HITL o sandbox (correo, calendarios, DB).  
- **Formato**: JSON **estricto** cuando activa herramientas.  
- **Privacidad**: PII anonimizada en trazas; principio de mínimo privilegio.  
- **Límites**: tokens/top_k/timeouts; LIMIT 50 en SQL; whitelists de tablas.  
- **Auditoría**: guardar decisiones (alto nivel) y resultados por paso.

---

## 6. Métricas y evaluación

- **Utilidad**: tasa de resolución en 1ª respuesta, pasos ahorrados.  
- **Calidad**: precisión (vs. ground-truth), NPS/satisfacción.  
- **Riesgo**: incidencias de seguridad/privacidad, acciones no permitidas.  
- **Coste**: tokens, llamadas a herramientas, reintentos.  
- **Rendimiento**: latencia, disponibilidad, timeouts.

**QA recomendado**  
- Conjunto de **prompts canónicos** (golden set).  
- Tests de **regresión** ante cambios de prompts/modelos.  
- “Monkey tests” controlados para rutas inesperadas.

---

## 7. Antipatrones comunes

- Un **mega-agente** “que hace todo” → dividir en subagentes con límites.  
- **Web scraping** sin control → solo con permiso y fuentes confiables; citar fuente.  
- **Acciones irreversibles** sin HITL → siempre confirmación.  
- **Prompts ambiguos** → especificar formato, políticas y límites.  
- **Sin observabilidad** → logs por nodo, IDs de correlación, métricas mínimas.

---

## 8. Roadmap de madurez

- **Nivel 0**: Router + 1–2 subagentes (FAQ/RAG + CRM).  
- **Nivel 1**: agregar Planner-Executor para tareas compuestas.  
- **Nivel 2**: guardrails avanzados, whitelists, HITL, métricas de calidad.  
- **Nivel 3**: comité de expertos en dominios críticos + A/B de prompts/modelos.

---

## 9. Checklist antes de lanzar

- ¿Cuál es la **fuente de verdad**? (KB/BD)  
- ¿Qué **no** puede hacer el agente? (límites claros)  
- ¿Qué requiere **aprobación humana**?  
- ¿Qué **formato** debe devolver cada subagente?  
- ¿Cómo medimos **utilidad, calidad, riesgo y coste**?  
- ¿Cuál es el **fallback** si falla una herramienta?

---

## 10. FAQ

**¿Puedo usar un único agente para todo?**  
Podés, pero perdés control y calidad. Mejor separar en **subagentes** con responsabilidades claras.

**¿Necesito Vector DB para RAG?**  
Para dominios con material propio, **sí**. Si no hay, podés empezar sin RAG y luego incorporarlo.

**¿Cómo reduzco alucinaciones?**  
- Priorizar **KB**; castigar respuestas fuera de contexto; marcar fuente.  
- Limitar acciones con guardrails y validaciones.

**¿Qué modelo conviene?**  
Depende de costo/latencia/SLA. Empezar con uno “balanceado” y optimizar por caso de uso.

---

## Licencia

Este contenido se publica bajo **MIT License**. Podés usarlo y adaptarlo libremente citando la fuente cuando corresponda.

---
[⬅ Back to Course Overview](../../README.md)