# 🔄 Hands-On Project: Workflow Automation with Make or Zapier

In this project, you’ll build a simple automation that connects **Google Forms → OpenAI → Notion**, to summarize input and store it for later use.

---

## 🧠 Use Case

> “Automatically summarize form responses using AI and save them in a Notion database.”

This could be used for:
- Lead intake summaries
- Client feedback aggregation
- Daily check-in logs

---

## 🛠️ Tools You’ll Use

- [Google Forms](https://forms.google.com)
- [Make.com](https://www.make.com) or [Zapier](https://zapier.com)
- [OpenAI](https://platform.openai.com) (for summarization)
- [Notion](https://www.notion.so) (for storing results)

---

## 🔧 Steps Overview

### 1. Create Your Google Form
- Ask a question like:  
  _“What did you do today?”_  
  _“What blockers are you facing?”_

---

### 2. Set Up Make (or Zapier)

#### Trigger
- **App**: Google Forms or Google Sheets
- **Trigger**: New form submission

#### Step 1: Summarize with OpenAI
- Use OpenAI GPT API to summarize the response  
  Example prompt:  
  _"Summarize the following response in 2 sentences and highlight any blockers or decisions required."_  

#### Step 2: Send to Notion
- Create a Notion entry with:
  - Original response
  - AI summary
  - Date/time

---

## ✅ Result

Every time a form is submitted, you’ll have a **clean, summarized record** in Notion — perfect for async updates or status reviews.

---

## 📦 Bonus Ideas

- Email yourself or your team the AI summary
- Post the summary to a Slack channel
- Use sentiment analysis to flag responses needing attention

---

[⬅ Back to Module Folder](./README.md)
