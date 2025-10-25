# 🧑‍💻 Curso: Buenas Prácticas de System Prompt, Debugging y Gestión de Errores

**Objetivo:** Aprender a diseñar *system prompts* robustos, depurar errores en flujos con LLMs y aplicar estrategias de manejo de errores y *fallbacks* en entornos productivos.

> “El prompt es código. Y como todo código, se prueba, se depura y se protege con manejo de errores.”


## 1. Introducción
- Qué es un **system prompt** y por qué es clave.  
- Diferencia entre *system*, *user* y *assistant prompts*.  
- Ejemplo rápido:  
  - ❌ *“Responde como un asistente.”*  
  - ✅ Prompt estructurado con rol, objetivo, tono y fallback.

### ¿Qué es un System Prompt?
Es la instrucción inicial que define cómo debe comportarse un modelo de lenguaje.
Funciona como el contrato entre nosotros (desarrolladores/usuarios) y el modelo.

**Define:**

- Rol (ej: “Sos un asesor financiero”)
- Objetivo (ej: “Tu misión es ayudar con consultas de clientes”)
- Tono y estilo (ej: “Profesional, claro y accesible”)
- Reglas: (qué hacer y qué no hacer)

**Diferencias clave**

- **System prompt**: establece el contexto y comportamiento general. (ej: “Actuás como un agente de soporte técnico especializado en redes.”)
- **User prompt**: es la entrada del usuario. (ej: “¿Cómo cambio mi contraseña?”)
- **Assistant prompt (output)**: es la respuesta generada siguiendo las reglas anteriores.


### Ejemplo rápido:

❌ Mal prompt (ambiguo):

```
Responde como un asistente.
```

**Problemas:**

- No define rol.
- No establece el dominio.
- No indica formato de salida.
- No da fallback si no sabe la respuesta.

✅ Buen prompt (claro y completo):
```
Rol: Actuás como un asistente virtual de una empresa financiera.  
Objetivo: Responder consultas sobre pagos, transferencias y servicios.  
Tono: Profesional y cordial.  
Formato: Responde siempre en máximo 3 frases.  
Regla: Si no tenés información, respondé:  
“No dispongo de esa información, por favor comunicate con el centro de atención al cliente.”

```

## 2. Buenas prácticas de System Prompt
**Claves:**
- Definir **rol** del modelo.  
- Establecer **contexto y dominio**.  
- Especificar el **formato esperado**.  
- Dar **ejemplos de entrada y salida**.  
- Aclarar **qué no debe hacer**.  

### Principios fundamentales
Un buen system prompt debe cumplir:
- Definir un rol claro
Ej: “Actuás como un asesor de soporte técnico de internet.”

- Dar contexto y dominio
Ej: “Resolvés consultas sobre conexión WiFi, routers y facturación.”

- Especificar formato de salida
Ej: “Respondé siempre en JSON con las claves: Cliente, Servicio, Estado.”

- Incluir ejemplos (opcional)
Input: “¿Cuál es el estado de mi factura?”

Output esperado:

```
{ "Factura": "123", "Estado": "Pagada" }

```

- Definir límites y prohibiciones
Ej: “Si la consulta no es sobre soporte técnico, respondé:
‘No puedo responder esa consulta, por favor contactá al área correspondiente.’”

### Errores comunes en prompts
- Ambigüedad → respuestas inconsistentes.
- Falta de formato definido → JSON roto, texto libre mezclado.
- Prompts demasiado largos o vagos → más margen para inventar.
- Sin fallback → el modelo improvisa información.

### Ejemplo rápido:

❌ Mal prompt:

```
Dame información de clientes.
```

**Problemas:**

- No aclara qué datos.
- No define estructura.
- No prevé el caso de error.

✅ Buen prompt:

```
Rol: Actuás como agente de soporte de clientes.  
Objetivo: Buscar información en Google Sheets por ID de cliente.  
Formato de salida: JSON con las claves {Nombre, Email, Estado, Plan, Gasto acumulado}.  
Fallback: Si no existe, devolvé: { "Estado": "No encontrado" }.  

```


## 3. Debugging en flujos con LLMs 

### Errores más comunes en flujos con LLMs
- Alucinaciones
El modelo inventa información que no existe.
Ej: Preguntar por un cliente inexistente y que devuelva datos falsos.

- Respuestas inconsistentes
Misma pregunta → respuestas distintas en distintos intentos.

- Contexto mal interpretado
El modelo responde con información fuera del dominio.

- Formato inválido
El modelo devuelve texto libre cuando pedimos JSON.

Ej:

❌ “La factura 453 corresponde a Juan Pérez”

✅ 
```
{   "NumeroFactura": "453", 
    "Cliente": "Juan Pérez" 
}
```
### Estrategias de Debugging

- Aislar el error
Probar el nodo/proceso donde ocurre, sin el resto del workflow.

- Reproducir el error
Ejecutar con el mismo input varias veces.
Revisar si es consistente o aleatorio.

- Reducir el prompt (Prompt Minimization)
Quitar adornos y quedarnos solo con lo esencial.

- Validar automáticamente
Usar try/catch o regex para confirmar formato (ej. JSON válido).

- Guardar logs
Registrar input, output y errores en una planilla o DB para analizar patrones.

### Ejemplo

**System prompt**

```
Dame la factura pedida en formato JSON.
```

**User Prompt**
```
Factura número 453
```

**Output**
```
La factura 453 corresponde a Juan Pérez por 121 euros.
```

### Ahora, mejoremos la versión

**System prompt**

```
Respondé SOLO en formato JSON con estas claves:  
{ "NumeroFactura": string, 
"Cliente": string, "Total": number }  
Si falta algún dato, devolvé null en esa clave.  

```

**User Prompt**
```
Factura número 453
```

**Output**
```
{
  "NumeroFactura": "453",
  "Cliente": "Juan Pérez",
  "Total": 121
}

```


**Errores más comunes:**
- Respuestas vagas o incoherentes (*alucinaciones*).  
- Formato inválido (ej. JSON roto).  
- Inconsistencia en respuestas.  

**Estrategias:**
- *Prompt minimization*: simplificar el prompt al máximo.  
- Testear nodo por nodo en n8n.  
- Usar logs y *trace tools* (LangSmith, Promptfoo).  

**Ejemplo de error de formato:**
- ❌ Output esperado en JSON → el modelo responde en texto libre.  
- ✅ Solución → reforzar en el prompt:  
```txt
Respondé SOLO en formato JSON con estas claves:  
{ "NumeroFactura": string, "Cliente": string, "Total": number }  
Si falta algún dato, devolvé null en esa clave.
```



## 4. Gestión de errores y fallback (

### Tipos de errores:
- **Formato**: JSON/XML inválido.  
- **Contenido**: Respuesta incoherente.  
- **Contexto**: No se encuentra información en la base. 
- **Información incoherente o alucinada.**
Ejemplo: “El cliente 003 es Juan Pérez” (cuando en la base no existe).
- **El modelo responde fuera de dominio.**
Ejemplo: Preguntar por “horóscopo” en un bot bancario y que responda en lugar de bloquear.- 

Ejemplo:

```
{ "Cliente": "Pedro", "Total": 250, }  // coma extra

```

### Estrategias de gestión de errores

- Validación automática
- Usar try/catch para JSON.
- Regex para emails, fechas, números de factura.
- Mensajes de error claros
- No devolver mensajes crudos del sistema.

Ejemplo:

❌ “Error 500: NullPointerException.”

✅ “El sistema no encontró esa factura. Revisá el número ingresado.”

- Fallback prompts
Preparar instrucciones para cuando no hay información.

Ejemplo:

```
Si la base no devuelve resultados, respondé:  
“No encontré información en este momento. Podés comunicarte al 0800-111-222.”
```

- Retries con backoff
Volver a intentar con un prompt simplificado o con menos carga.



## Recap
1. Un buen *system prompt* = claridad, rol definido, reglas explícitas.  
2. Debugging = logs + pruebas controladas + prompts simples.  
3. Gestión de errores = validación + fallback + comunicación clara.  

**Herramientas recomendadas:**  
- [LangSmith](https://smith.langchain.com/) → logging y testeo de prompts.  
- [Promptfoo](https://promptfoo.dev/) → benchmarking de prompts.  
- [JSONLint](https://jsonlint.com/) → validar JSON.  
- **Debug Mode en n8n** → paso a paso.


---

[⬅ Back to Course Overview](../../README.md)