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

Código nodo **Code**
 
```js
try {
  const input = $input.first().json.output;
  
  if (input === undefined || input === null) {
    return [{
      json: {
        valid: false,
        error: "El campo 'output' no existe o es null"
      }
    }];
  }
  
  if (typeof input === 'object') {
    return [{
      json: {
        valid: true,
        message: "El input ya es un objeto JSON válido",
        type: Array.isArray(input) ? 'array' : 'object'
      }
    }];
  }
  
  if (typeof input === 'string') {
    JSON.parse(input);
    return [{
      json: {
        valid: true,
        message: "String JSON válido",
        type: 'string'
      }
    }];
  }
  
  return [{
    json: {
      valid: false,
      error: `Tipo de dato no válido: ${typeof input}`
    }
  }];
  
} catch (e) {
  return [{
    json: {
      valid: false,
      error: e.message
    }
  }];
}
```

---

[⬅ Back to Course Overview](../../README.md)
