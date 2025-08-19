## 🧪 Ejercicios Prácticos

### 🔹 Ejercicio 1 — Mejorando un System Prompt
**Prompt mal hecho:**
```txt
Sos un asistente. Contestá a todo lo que te digan.
```

**Tareas:**
1. Identificar problemas (ambiguo, sin rol, sin reglas, sin formato).  
2. Reescribir aplicando buenas prácticas.
3. Puedes utilizar herramientas como [LangSmith](https://smith.langchain.com/) para poder evaluarlo.  

**Posible solución:**
```txt
Rol: Actuás como un asistente virtual de un banco.  
Objetivo: Ayudar a los clientes con información sobre cuentas, transferencias y pagos.  
Formato de salida: Siempre en texto plano, en máximo 3 frases.  
Regla: Si no encontrás información, respondé:  
“No dispongo de esa información, por favor comunicate con el centro de atención al cliente.”
```

---

### 🔹 Ejercicio 2 — Debugging en n8n

1) Toma el template [adjunto](./lab_debug_n8n.json). 
2) Impórtalo a n8n
3) Configura tus credenciales de OpenAI
4) Mejora el flujo para que de como respuesta un JSON

Código nodo **Code** *(Se subirá 10 min comenzado los ejercicios)*
 
```js

```

---

[⬅ Back to Course Overview](../../README.md)
