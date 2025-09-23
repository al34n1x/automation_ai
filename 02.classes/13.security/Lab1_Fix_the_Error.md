# 🧪 Lab 1 – Fix the Error: Asset Generator (n8n)

## 🎯 Objetivo
Aprender a **depurar** un flujo roto de n8n encontrando y corrigiendo errores típicos:  
1. Configuración de credenciales.  
2. Inclusión de un nodo faltante en el flujo.  

Al finalizar este laboratorio deberías ser capaz de:  
- Importar un workflow existente en n8n.  
- Detectar nodos con errores.  
- Configurar credenciales proporcionadas por el instructor.  
- Agregar y conectar un nodo faltante para completar el flujo.  



## 📂 Archivos
- [Asset_Generator_error.json](https://raw.githubusercontent.com/al34n1x/senpai/main/automation_ai/02.classes/13.security/Asset_Generator_error.json)→ Workflow con errores intencionales.  



## 📝 Instrucciones

### 1. Importar el workflow
1. Ingresá a tu instancia de n8n (cloud o local).  
2. Menú **Workflows → Import from File**.  
3. Seleccioná `Asset_Generator_error.json`.  
4. Abrí el workflow y asegurate de que todos los nodos se visualicen.  



### 2. Identificar el error
- Verás que algunos nodos muestran un **ícono rojo de advertencia**.  
- El flujo **no ejecuta correctamente** porque:  
  1. Faltan credenciales en tres nodos.   
  2. Hay un **nodo faltante** que conecta la salida de generación con la parte de almacenamiento.  



### 3. Corregir credenciales
- Buscá los nodos HTTP REQUEST (según el caso del workflow).  
- Abrí la configuración → pestaña **Credentials**.  
- El profesor te dará un **API Key / Token** o credenciales de prueba.  
- Configuralas en n8n: **Settings → Credentials → New Credential**.  
- Volvé al nodo y asigná las credenciales que creaste.  



### 4. Agregar el nodo faltante
- Observá la línea rota: hay una salida que **no conecta con nada**.  
- Tu tarea es identificar qué falta:  
  - ¿Un nodo **HTTP Request** para enviar la imagen a un servicio externo?  
  - ¿Un nodo **Write Binary File** para guardar el asset localmente?  
  - ¿Un nodo **Google Drive / S3** para almacenamiento en la nube?  
- Agregá el nodo correcto según el enunciado del profesor.  
- Conectá la salida del nodo de generación con el nuevo nodo de almacenamiento.  



### 5. Ejecutar y validar
- Corré el workflow con datos de prueba.  
- Revisá en **Execution Data** que el asset se genera y se almacena sin errores.  
- Asegurate de que las credenciales funcionan y el flujo finaliza con estado **Success**.  



## 💡 Pistas
- Recordá: en n8n, cuando ves `No credentials selected`, siempre revisá el menú **Credentials**.  
- El nodo faltante está relacionado con **cómo y dónde guardar el asset generado**.  
- Usá el **Panel de Ejecuciones** para inspeccionar los datos que fluyen entre nodos y confirmar que el archivo existe.  



## ✅ Entrega
- Exportá tu workflow corregido como `Asset_Generator_fixed.json`.  
- Subilo al repositorio/clase indicado por el profesor.  



## 📖 Recursos
- [n8n Docs – Working with Credentials](https://docs.n8n.io/credentials/)  
- [n8n Docs – Nodes Reference](https://docs.n8n.io/integrations/builtin/)  
- [n8n Docs – Binary Data Handling](https://docs.n8n.io/data/binary-data/)  
