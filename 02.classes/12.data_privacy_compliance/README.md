# Privacy & Data Ethics for AI and n8n (1h30)

**Audience:** Basic–intermediate knowledge of n8n and AI  
**Goal:** Enable teams to design, evaluate, and implement n8n workflows and AI solutions that meet privacy regulations and ethical good practices—without sacrificing productivity.

---

## Learning Objectives
- Understand what counts as **personal data** vs **sensitive data**, and the difference between **pseudonymization** and **anonymization** (and why only the latter can take data *out of scope* if truly irreversible).
- Map the **regulatory landscape** (GDPR, EU AI Act, Argentina’s Law 25.326 + AAIP guidance, Brazil’s LGPD, California’s CCPA/CPRA + Delete Act) and how it affects AI + automation.
- Recognize **ethical risks** in AI (bias, opacity/“black boxes”, surveillance creep) and how to document systems responsibly.
- Apply **privacy-by-design** patterns in n8n (data minimization, logging discipline, encryption, retention) and design safe integrations with LLMs/APIs.
- Practice with a **mini hands‑on** flow: ingest PII → pseudonymize → downstream analytics/LLM with minimized exposure.

> **Time plan (suggested):** 0:05 intro • 0:25 laws • 0:15 ethics • 0:25 n8n practices • 0:10 workshop • 0:10 checklist/QA

---

## 0) Setup & Concepts (5 min)
- **Personal data** = any information about an identified/identifiable natural person (e.g., name, email, IP, cookie IDs). **Sensitive data** may include health, biometrics, political opinions, etc.  
- **Pseudonymization** = replace direct identifiers with tokens/hashes, but still *linkable* with additional information (therefore still personal data).  
- **Anonymization** = irreversible removal of linkability at individual level. If re-identification is feasible, it’s **not** anonymous.

**Key terms to keep handy:** lawful basis, controller vs processor, transparency notice, RoPA (record of processing), DPIA/impact assessment, data residency/transfer, sub‑processors, data retention, data subject rights.

---

## 1) Law & Compliance Essentials (25 min)

### 1.1. European Union (GDPR)
**Core principles**: lawfulness, fairness, transparency; purpose limitation; data minimization; accuracy; storage limitation; integrity & confidentiality; accountability.  
**Privacy by design & by default (Art. 25)** requires building safeguards (e.g., minimization, pseudonymization) **into** systems and defaults.  
**Data subject rights**: access, rectification, erasure (“right to be forgotten”), restriction, portability, objection; explain automated decisions where applicable.  
**Records of Processing (Art. 30)**: keep an inventory of what you process, for what purpose, legal bases, retention, recipients, transfers, and security measures.  
**Where to start**: maintain a RoPA, keep/update your transparency notice, and run DPIAs when automations/AI could significantly affect people.

**Primary references:**  
- GDPR consolidated legal text (EUR‑Lex) and quick-lookup mirror:  
  - https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng  
  - https://gdpr-info.eu/ (mirror)  
- Article 25 (privacy by design): https://gdpr-info.eu/art-25-gdpr/  
- Article 30 (records): https://gdpr-info.eu/art-30-gdpr/  
- Article 13 (transparency): https://gdpr-info.eu/art-13-gdpr/

### 1.2. EU Artificial Intelligence Act (2024)
The **EU AI Act** (Regulation (EU) 2024/1689) establishes a risk‑based regime: bans **unacceptable risk** practices (e.g., social scoring), defines **high‑risk** obligations (risk management, data governance/quality, logs, documentation, human oversight), and mandates **transparency** for certain uses (e.g., deepfakes). Published in the Official Journal **Jul 12, 2024**; obligations phase in over time (most high‑risk duties apply by 2026).  
**References:**  
- Official Journal page: https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng  
- Overview/explorer: https://artificialintelligenceact.eu/the-act/

### 1.3. Argentina
- **Law 25.326 (Habeas Data)** and **Decree 1558/2001** define principles, rights (ARCO), international transfers, registries, and sanctions.  
- **AAIP (Data Protection Authority) – 2024 guidance** on responsible AI: transparency, explicability, impact assessment, and risk mitigation across the AI lifecycle.  
**References:**  
- Law 25.326: https://www.argentina.gob.ar/normativa/nacional/ley-25326-64790  
- Consolidated text (Infoleg): https://servicios.infoleg.gob.ar/infolegInternet/anexos/60000-64999/64790/texact.htm  
- AAIP Guide (PDF): https://www.argentina.gob.ar/sites/default/files/aaip-argentina-guia_para_usar_la_ia_de_manera_responsable.pdf

### 1.4. Brazil (LGPD)
**Lei 13.709/2018 (LGPD)**: lawful bases, data subject rights, data governance, and **RIPD** (impact assessment) in some cases.  
**References:**  
- Official text (Planalto): https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm  
- Gov.br explainer: https://www.gov.br/esporte/pt-br/acesso-a-informacao/lgpd

### 1.5. California (CCPA/CPRA + Delete Act)
**CCPA** grants rights to know, delete, correct, **opt‑out** of “sale/share,” and limit use of **sensitive** personal information; **CPRA** created the **CPPA** (agency). The **Delete Act (SB‑362)** requires an accessible deletion mechanism and expands obligations for **data brokers**.  
**References:**  
- CCPA overview + regs: https://oag.ca.gov/privacy/ccpa • https://oag.ca.gov/privacy/ccpa/regs  
- CPPA resources: https://cppa.ca.gov/regulations/  
- Delete Act rulemaking page (DROP): https://cppa.ca.gov/regulations/drop.html

> **Field note:** Laws evolve. Keep a tracked “legal register” for your org and revisit it (e.g., quarterly).

---

## 2) Applied AI Ethics (15 min)
**Global principles** reinforce rights, transparency, security, robustness, and accountability:
- **OECD AI Principles** (2019): trustworthy AI that respects human rights and democratic values. https://oecd.ai/en/ai-principles  
- **UNESCO Recommendation (2021)**: dignity, human oversight, transparency, and governance. (PDF) https://unesdoc.unesco.org/ark:/48223/pf0000385082

**Bias in the wild—two classics:**
- **COMPAS** risk scoring debate (ProPublica, 2016) surfaced disparities; follow‑up research shows **fairness trade‑offs** among metrics (calibration vs error parity).  
  - https://www.propublica.org/article/machine-bias-risk-assessments-in-criminal-sentencing  
  - Kleinberg–Mullainathan–Raghavan (2016): https://arxiv.org/abs/1609.05807  
- **Face recognition**: NIST FRVT reports show demographic performance variations across vendors/algorithms.  
  - 2019 demographics report: https://nvlpubs.nist.gov/nistpubs/ir/2019/nist.ir.8280.pdf

**Documentation patterns you should adopt:**
- **Model Cards** (for models): https://arxiv.org/abs/1810.03993  
- **Datasheets for Datasets** (for datasets): https://arxiv.org/abs/1803.09010

**Risk frameworks & standards to align with:**
- **NIST AI RMF GenAI Profile (NIST AI 600‑1, 2024)**: actionable controls for Generative AI across design→deployment. https://www.nist.gov/itl/ai-risk-management-framework  
- **ISO/IEC 42001** (AI management systems) & **ISO/IEC 23894** (AI risk management). https://www.iso.org/standard/42001 • https://www.iso.org/standard/77304.html

---

## 3) n8n Privacy‑by‑Design Patterns (25 min)

### 3.1. Secure configuration (self‑hosted or cloud)
- **Encrypt credentials** with a controlled key: set `N8N_ENCRYPTION_KEY` (same across workers/queue mode), back it up and rotate under change control.  
  Docs: https://docs.n8n.io/hosting/configuration/configuration-examples/encryption-key/
- **Reduce saved execution data** (avoid storing payloads with PII):  
  - Instance‑wide env vars (examples):  
    ```bash
    # Save only errors; never save progress, avoid success payloads in DB
    export EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
    export EXECUTIONS_DATA_SAVE_ON_ERROR=all
    export EXECUTIONS_DATA_SAVE_ON_PROGRESS=false
    # Consider pruning / retention windows
    export EXECUTIONS_DATA_PRUNE=true
    export EXECUTIONS_DATA_MAX_AGE=168 # hours (7 days), adjust to your policy
    ```
  Docs: https://docs.n8n.io/hosting/configuration/environment-variables/executions/  
  Retention: https://docs.n8n.io/hosting/scaling/execution-data/
- **Harden access**: enforce TLS/SSL, enable **2FA**, and configure **SSO (OIDC/SAML)** where available.  
  - SSL: https://docs.n8n.io/hosting/securing/set-up-ssl/  
  - 2FA: https://docs.n8n.io/user-management/two-factor-auth/  
  - SSO: https://docs.n8n.io/hosting/securing/set-up-sso/
- **Externalize secrets** with a vault (AWS Secrets Manager, HashiCorp Vault, Azure Key Vault):  
  - https://docs.n8n.io/external-secrets/ • https://docs.n8n.io/hosting/configuration/environment-variables/external-secrets/

> **Tip:** Keep an **architecture register**: where data flows, what nodes/APIs touch PII, which logs persist fields, and where retention/pruning is enforced.

### 3.2. Design patterns in workflows
- **Minimize data**: in **Set/Move** nodes, drop any fields not strictly needed downstream; prefer stable internal IDs over emails/phones.  
- **Pseudonymize at the edge** (before leaving your perimeter) and segregate the re‑identification table.  
- **Tame logs**: disable success‑data saving in production; log only metadata and error contexts that you truly need; avoid storing request/response bodies with PII.  
- **Explainability & traceability**: keep model/dataset docs (Model Cards/Datasheets) in your repo; log model/version and prompt templates (but avoid PII in prompts).  
- **Govern vendors**: check terms on data use for training, retention, sub‑processors, and data residency; use DPAs/SCCs where needed.

### 3.3. LLM/API integrations
- Run a **DPIA** when using profiling, decisioning, or when people could be significantly affected by automation.  
- **Guardrail prompts**: strip PII before the LLM call; inject policy reminders into system prompts (no long‑term storage, don’t output raw PII, etc.).  
- **Tokenization strategy**: if downstream needs consistency across events, use deterministic hashes with salt (still personal data!) and keep salt in a vault.  
- **Data residency**: prefer regional endpoints; avoid cross‑border flows unless covered by valid transfer mechanisms.



## 5) Rapid Case Studies & Dilemmas (10 min)
- **Automated scoring for onboarding**: lawful basis (contract/legitimate interest?), transparency, and right to human review where applicable. Add a DPIA.  
- **Face recognition for access control**: assess high‑risk implications (EU AI Act) and demographic performance per NIST FRVT; often avoid or constrain.  
- **“Consent or Pay” walls**: ensure consent remains **freely given** (avoid coercive conditions); document rationale and alternatives.

---

## 6) Final Checklist (10 min)
- **RoPA** up to date (purposes, bases, recipients/transfers, retention, security measures).  
- **DPIA/RIPD** for high‑impact automations or profiling.  
- **n8n hardened**: `N8N_ENCRYPTION_KEY` set/rotated; **external secrets**; execution‑data policies tuned; TLS, 2FA, SSO where possible.  
- **Vendor governance**: DPAs, data residency, sub‑processor visibility, model‑provider terms on training/retention.  
- **Documentation**: Model Cards, Datasheets, prompt templates, model/version traceability in logs.  
- **Education**: brief your team on PII handling and red‑teaming prompts to prevent leaks.

---

## References & Further Reading
**Core law & guidance**
- GDPR consolidated text (EUR‑Lex): https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng  
  - Art. 25 (privacy by design): https://gdpr-info.eu/art-25-gdpr/  
  - Art. 30 (records/RoPA): https://gdpr-info.eu/art-30-gdpr/  
  - Art. 13 (transparency): https://gdpr-info.eu/art-13-gdpr/  
- **EU AI Act** (Reg. 2024/1689): https://eur-lex.europa.eu/eli/reg/2024/1689/oj/eng • Overview: https://artificialintelligenceact.eu/the-act/  
- **Argentina**: Law 25.326 https://www.argentina.gob.ar/normativa/nacional/ley-25326-64790 • Infoleg https://servicios.infoleg.gob.ar/.../64790/texact.htm • **AAIP Guide (2024)** PDF: https://www.argentina.gob.ar/sites/default/files/aaip-argentina-guia_para_usar_la_ia_de_manera_responsable.pdf  
- **Brazil (LGPD)**: https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm • https://www.gov.br/esporte/pt-br/acesso-a-informacao/lgpd  
- **California**: CCPA https://oag.ca.gov/privacy/ccpa • Regs https://oag.ca.gov/privacy/ccpa/regs • CPPA https://cppa.ca.gov/regulations/ • Delete Act (DROP) https://cppa.ca.gov/regulations/drop.html

**AI ethics & risk**
- OECD AI Principles: https://oecd.ai/en/ai-principles  
- UNESCO Recommendation (2021) PDF: https://unesdoc.unesco.org/ark:/48223/pf0000385082  
- NIST AI RMF – GenAI Profile (AI 600‑1, 2024): https://www.nist.gov/itl/ai-risk-management-framework  
- ISO/IEC 42001 (AI management systems): https://www.iso.org/standard/42001  
- ISO/IEC 23894 (AI risk management): https://www.iso.org/standard/77304.html  
- Model Cards: https://arxiv.org/abs/1810.03993 • Datasheets: https://arxiv.org/abs/1803.09010  
- NIST FRVT demographics (2019): https://nvlpubs.nist.gov/nistpubs/ir/2019/nist.ir.8280.pdf

**n8n documentation**
- Set custom encryption key: https://docs.n8n.io/hosting/configuration/configuration-examples/encryption-key/  
- Execution data env vars: https://docs.n8n.io/hosting/configuration/environment-variables/executions/ • Retention: https://docs.n8n.io/hosting/scaling/execution-data/  
- Security overview: https://docs.n8n.io/hosting/securing/overview/ • SSL: https://docs.n8n.io/hosting/securing/set-up-ssl/  
- 2FA: https://docs.n8n.io/user-management/two-factor-auth/ • SSO: https://docs.n8n.io/hosting/securing/set-up-sso/  
- External secrets: https://docs.n8n.io/external-secrets/ • Env vars for external secrets: https://docs.n8n.io/hosting/configuration/environment-variables/external-secrets/

---

## Appendix A — RoPA & DPIA Starters

**RoPA (Record of Processing Activities) — fields you’ll need:**
- Controller / DPO contacts
- Purposes & lawful bases
- Categories of data subjects and personal data
- Recipients (incl. processors/sub‑processors)
- Transfers & mechanisms (e.g., SCCs)
- Retention periods
- Security measures (high level)

**DPIA prompts (copy/paste into your template):**
- What is the **purpose** and expected **benefit**?  
- What personal data and **sensitive data** are processed?  
- What is the **lawful basis**? Is consent **freely given** and demonstrable?  
- Who are the **recipients** (internal + vendors) and what are the **transfers** (regions)?  
- What are the **risks** (privacy, bias, security, transparency)?  
- What **mitigations/controls** are in place (technical/organizational)?  
- How will you handle **rights requests**, **objections**, and **human review**?
- What is the **retention** and **deletion** policy? Who verifies it?

---

## Appendix B — Sample Policy Snippets

> **Execution data retention (n8n)**  
> “In production, workflow execution payloads are not stored by default. Only error metadata is retained for up to 7 days for debugging. Success payloads are never persisted. Personally identifiable information (PII) must not appear in logs. Exceptions require DPO approval and a DPIA.”

> **LLM usage rule**  
> “Prompts and outputs must not contain raw PII unless explicitly authorized by the DPO for a defined purpose. When identity‑level linkage is required, use salted deterministic tokens. Providers must contractually commit not to use our content for model training and to enforce regional data residency.”

---

**Maintainer’s note:** This README is intentionally pragmatic. Keep your **legal register**, **RoPA**, and **DPIAs** in the same repository (or linked) so engineers and legal can collaborate friction‑free.
