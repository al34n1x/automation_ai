# 🤖 Hands-On Project: Make.com AI-Powered Workflow

In this project, you'll build an automation using **Make.com** to connect apps and use AI to process data in real time.

---

## 🧠 Use Case

> Automatically take form submissions, summarize the responses using AI, and log them in Notion.

---

## 🛠️ Tools You’ll Use

- [Make.com](https://make.com) (automation platform)
- Google Forms or Typeform (data input)
- OpenAI (summarization)
- Notion (data destination)

---

## 🔧 Workflow Overview

### Step 1: Trigger from Form Submission
- Use **Google Sheets** or **Typeform** as the trigger module.
- This collects new user responses.

### Step 2: Summarize with OpenAI
- Add the **OpenAI** module
- Prompt example:
  _“Summarize the following feedback in 2 sentences and extract any key decisions or questions: [input]”_

### Step 3: Store in Notion
- Use the **Notion** module to create a new page in a database
- Include:
  - Original input
  - AI-generated summary
  - Timestamp

---

## ✅ Result

Every time a form is submitted, it’s automatically summarized and stored neatly in Notion — ready for follow-up or sharing with your team.

---

## 🚀 Bonus Ideas

- Translate responses before saving them
- Add Slack or Email notifications
- Use Airtable instead of Notion

---

[⬅ Back to Module Folder](./README.md)
