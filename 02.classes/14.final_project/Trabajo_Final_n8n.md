# 📘 Trabajo Final – Proyecto en n8n

## 🎯 Objetivo
En equipos de 3–4 integrantes, deben **diseñar, implementar y presentar un workflow funcional en n8n** que resuelva un caso realista de negocio o productividad.  

El trabajo busca evaluar:  
- Creatividad en la elección del caso de uso.  
- Correcta implementación técnica.  
- Aplicación de buenas prácticas de seguridad y manejo de datos.  
- Documentación clara para que un tercero pueda replicar el proyecto.  


## 💡 Ideas de proyectos
Los equipos pueden elegir libremente, pero aquí van algunas sugerencias:  

1. **Helpdesk automatizado**  
   - Captura de tickets vía formulario o email.  
   - Registro en Google Sheets/Notion/Airtable.  
   - Notificación al canal de soporte (Slack/Telegram/Discord).  

2. **Pipeline de Marketing**  
   - Automatizar la publicación de posts en redes sociales a partir de un calendario en Google Sheets.  
   - Generar imágenes con IA (ej. Flux o DALL·E) y adjuntarlas automáticamente.  

3. **Bot de recordatorios inteligentes**  
   - Recibir solicitudes por WhatsApp/Telegram.  
   - Guardarlas en una base de datos.  
   - Mandar recordatorios programados con mensajes personalizados.  

4. **ETL de datos simple**  
   - Consumir una API pública (ej. clima, criptomonedas, transporte).  
   - Transformar los datos (limpieza, normalización).  
   - Guardar resultados en una DB o dashboard (ej. Supabase, Google Data Studio).  

5. **Workflow para e-commerce**  
   - Capturar nuevas órdenes de Shopify/WooCommerce.  
   - Generar factura o comprobante automático.  
   - Enviar notificación al cliente + registrar en un CRM.  


## ✅ Requerimientos mínimos (para aprobar)
- **Al menos 6 nodos activos** conectados correctamente.  
- **1 integración con servicio externo** (API, app SaaS, base de datos, etc.).  
- **1 subworkflow** o implementación de MCP Server y MCP Client
- **1 manejo de datos** (transformación con *Function Node*, expresiones, o mapping).  
- **Gestión de credenciales seguras** (configuradas en n8n, no hardcodeadas).  
- **Documentación en un README.md** que explique:  
  - Objetivo del proyecto.  
  - Descripción del flujo.  
  - Instrucciones de ejecución.  
  - Diagrama del workflow.  
- **Demostración práctica**: cada grupo debe presentar el workflow corriendo (ejemplo con datos reales o simulados).  


## ⭐ Para destacar (extra points)
- Implementar **controles de seguridad** (webhook con firma, retención de ejecuciones ajustada).  
- Uso de **nodos avanzados** (Wait, IF, Switch, Merge, SplitInBatches).  
- Crear un **sub-workflow** reutilizable.  
- Incluir un **panel de monitoreo** (ej. logs centralizados, alerta en caso de error).  


## 📅 Entrega
- Fecha límite: **[definir fecha del curso]**  
- Entregables:  
  - Export del workflow en `.json`.  
  - README.md con documentación.  
  - Demo en vivo o grabada (5–10 min).  

## Recursos

- [Templates 1](https://github.com/enescingoz/awesome-n8n-templates)
- [Templates 2](https://github.com/wassupjay/n8n-free-templates)
- [Templates 3](https://github.com/Zie619/n8n-workflows)
