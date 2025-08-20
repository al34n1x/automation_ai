# 🔹 Ejercicio prácticos

### 🎯 Asistente de Gmail con OpenAI

**Objetivo:** procesar correos automáticamente y responder con IA.  

1. **Gmail Trigger** → detecta nuevo correo.  
2. **OpenAI Node** → resumir texto + clasificar sentimiento.  

Ejemplo de prompt en n8n:
```
Resumí el siguiente correo en 2 líneas y decime si el sentimiento es positivo, neutro o negativo:
{{ $json.body }}
```

3. **Google Sheets Node** → guardar remitente, resumen, sentimiento.  
4. **Gmail Node** → responder con un template automático.  

**Ejemplo de respuesta al cliente:**  
```
Hola Juan, recibimos tu mensaje.  
Resumen: Necesitás ayuda con tu factura de enero.  
Estado detectado: Negativo.  
Nuestro equipo se pondrá en contacto contigo pronto.
```

