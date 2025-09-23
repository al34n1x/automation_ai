# Seguridad en implementaciones de n8n

## 📚 Objetivo del curso
Brindar a los alumnos criterios y un checklist práctico para fortalecer la seguridad en despliegues de n8n, entendiendo riesgos, buenas prácticas y cumplimiento.


## 🗂️ Agenda
1. Introducción 
2. Riesgos comunes
3. Instalación y despliegue seguro 
4. Gestión de credenciales y secretos 
5. Seguridad en la operación de flujos
6. Cumplimiento y privacidad 
7. Cierre y checklist 



## 1) Introducción
- ¿Qué es n8n? Orquestador de flujos y APIs.
- Por qué la seguridad es crítica: se manejan credenciales, datos sensibles y sistemas de negocio.
- Meta: llevarse un **checklist** accionable.



## 2) Riesgos comunes
1. **Exposición de credenciales**
   - Ejemplo: API keys pegadas en nodos o en funciones y luego copiadas a Slack por error.
   - *Remedio*: usar credenciales del sistema, variables de entorno y *never* imprimir secretos en logs.
2. **Webhooks sin protección**
   - Ejemplo: endpoint `/webhook/…` público, sin firma ni IP allowlist. Un bot lo descubre y te inunda de requests.
   - *Remedio*: firmar requests, validar HMAC, listas de IP, Basic Auth en el proxy.
3. **Datos sensibles en logs o ejecuciones**
   - Ejemplo: guardar ejecuciones *con payloads completos* (PII) “para depurar”. Quedan meses en la base.
   - *Remedio*: configurar política de retención y masking; guardar solo metadatos.
4. **Permisos excesivos** (principio de mínimo privilegio ignorado)
   - Ejemplo: token de CRM con permisos de admin para leer *y* borrar, usado en un flujo de lectura.
   - *Remedio*: tokens dedicados por flujo con scopes mínimos.
5. **Nodos/paquetes de terceros sin control** (supply chain)
   - Ejemplo: instalar un nodo comunitario que envía métricas “inocentes”.
   - *Remedio*: revisar reputación, código o aislar en un entorno con egress controlado.
6. **Infra y red débiles**
   - Ejemplo: exponer el puerto de n8n directamente a Internet sin TLS.
   - *Remedio*: reverse proxy con HTTPS, WAF/Firewall, sólo 443 expuesto.

👉 Ejemplo: webhook abierto al mundo → bot de spam lo descubre.



## 3) Instalación y despliegue seguro

**Objetivo**: dar un blueprint de despliegue seguro (cloud o self-hosted).

**Decisiones de arquitectura**
- **n8n Cloud vs Self-hosted**: Cloud simplifica operación; self-hosted te da control de red, compliance y costos.
- **Aislamiento**: correr n8n en contenedor (Docker) o K8s; base de datos gestionada (Postgres) con TLS; VPC/Subnet privada.
- **Exposición**: nunca exponer n8n directo. Usá **reverse proxy** (Nginx/Traefik/Caddy) con **HTTPS** y **HTTP→HTTPS redirect**. Sólo 443 público.
- Configuración crítica (`N8N_ENCRYPTION_KEY`, `EXECUTIONS_*`, `N8N_BASIC_AUTH_*`).

### Ejemplo Docker Compose
```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    environment:
      - N8N_HOST=automations.ejemplo.com
      - N8N_PROTOCOL=https
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
      - EXECUTIONS_DATA_SAVE_ON_ERROR=all
    ports:
      - "127.0.0.1:5678:5678"
    depends_on:
      - db
  db:
    image: postgres:16
    environment:
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=n8n
```

**Variables y flags relevantes**
- `N8N_ENCRYPTION_KEY` → cifra credenciales en DB. **Debe ser largo y secreto.**
- `N8N_HOST`, `N8N_PORT=5678`, `N8N_PROTOCOL=https`, `WEBHOOK_URL` → URLs correctas, evita hardcodear IPs.
- `DB_TYPE=postgresdb` + `DB_POSTGRESDB_*` → credenciales DB seguras, rotación, TLS.
- Retención/logs: `EXECUTIONS_DATA_SAVE_ON_SUCCESS=none|all`, `EXECUTIONS_DATA_SAVE_ON_ERROR=all|none`, `EXECUTIONS_DATA_SAVE_ON_PROGRESS=true|false`, `EXECUTIONS_DATA_PRUNE=true`, `EXECUTIONS_DATA_MAX_AGE=<horas>`.
- Acceso a editor: `N8N_BASIC_AUTH_ACTIVE=true`, `N8N_BASIC_AUTH_USER`, `N8N_BASIC_AUTH_PASSWORD` (si no usás SSO/ingreso por VPN).



## 4) Gestión de credenciales y secretos
**Objetivo**: evitar filtraciones; institucionalizar cómo se crean, guardan, rotan y consumen secretos.

**Puntos clave**
- **Cifrado en n8n**: las credenciales se cifran en DB con `N8N_ENCRYPTION_KEY`. Si perdés esa key, perdés el acceso a credenciales; si se filtra, perdiste el cifrado. Tratarla como *joya de la corona*.
- **No hardcodear**: nunca poner tokens en nodos de Function ni en expresiones visibles. Usar credenciales del sistema o variables de entorno.
- **Variables de entorno**: consumir con `{{$env.MI_SECRETO}}` en expresiones.
- **Vault externo**: HashiCorp Vault, AWS Secrets Manager, GCP/OCI Secret Manager. Patrón típico: *al inicio del flujo*, pedí el secreto (con autenticación fuerte), guardalo en variable de ejecución, **no lo loguees**.
- **Rotación**: crear un flujo mensual que renueve tokens y actualice credenciales automáticamente.
- **Mínimo privilegio**: tokens por flujo, con scopes mínimos y naming consistente (ej. `crm-read-n8n-orders`).



## 5) Seguridad en la operación de flujos
**Objetivo**: que el día a día no debilite lo construido.

**Controles operativos**
- **Usuarios y roles**: separar admin de editores; cuentas nominales; MFA en el IdP si hay SSO.
- **Revisión por pares**: cambios en flujos críticos → revisión técnica simple (2 pares de ojos). Si tenés *Source Control* (edición Enterprise), integrarlo con Git.
- **Observabilidad**
  - Logs: `N8N_LOG_LEVEL=info|warn`. Enviar a un colector (ELK/CloudWatch/OCI Logging).
  - Auditoría: quién editó qué y cuándo.
  - Alertas: notificar fallos críticos y picos de llamadas en webhooks.
- **Retención de datos**
  - Guardar **solo lo necesario**. Evitar payloads completos en ejecuciones.
  - Anonimización: hash de emails (`sha256`), truncar teléfonos, etc., en un nodo Function.
- **Control de tasa y picos**
  - Rate limit en el proxy / WAF; “Rate Limit” node en n8n para salidas; colas con Redis si hay bursts.
- **Respuesta a incidentes** (mini playbook)
  1) Contener: revocar token, bloquear IPs, pausar flujos.
  2) Erradicar: arreglar config, rotar secretos, parchar.
  3) Recuperar: restaurar estado, reactivar con monitoreo.
  4) Lecciones: post-mortem corto y checklist actualizado.


## 6) Cumplimiento y privacidad
**Objetivo**: mapear “qué datos procesamos” y cómo cumplir sin frenar la innovación.

**Principios prácticos**
- **Minimización**: no recopilar lo que no usás; si llega, descartalo.
- **Propósito**: usar datos sólo para la finalidad del flujo.
- **Retención**: TTL claro; `EXECUTIONS_DATA_MAX_AGE` + borrado programado.
- **Derechos de personas**: tener un flujo para *acceso/borrado/export* (DSAR).
- **Trazabilidad**: registrar qué sistemas tocan PII.

**Mapa de datos del flujo (ejemplo)**
- Entrada: formulario web (nombre, email).
- Proceso: validación, enriquecimiento con API de terceros.
- Salida: CRM + email de bienvenida.
- Preguntas guía: ¿Se comparte con un LLM? ¿Hay DPA con ese proveedor? ¿Se anonimiza?

**LLMs vía n8n**
- No mandar PII a modelos externos sin base legal + contrato (DPA).
- Usa plantillas con anonimización previa: reemplazar `email` por `hash(email)` y mantener un diccionario seguro si hace falta reidentificar internamente.

**Regulatorio (alto nivel)**
- UE: GDPR; principios + DPA con proveedores.
- Local: ajustar a leyes nacionales (AR, UY, etc.). Mantener política de privacidad y registro de actividades de tratamiento.



## 7) Cierre y checklist final
**Objetivo**: dejar tareas accionables para la semana.

**Checklist de hardening (15 ítems)**
1. Reverse proxy con HTTPS + redirección forzada.
2. n8n **no** expuesto directo a Internet.
3. `N8N_ENCRYPTION_KEY` fuerte, guardado en secreto y respaldado.
4. DB con TLS y acceso sólo desde subred privada.
5. Variables `EXECUTIONS_*` ajustadas para **no** guardar PII innecesaria.
6. Retención: `EXECUTIONS_DATA_PRUNE=true` y `EXECUTIONS_DATA_MAX_AGE` definido.
7. Logs centralizados, con *masking* de campos sensibles.
8. Webhooks con firma/validador y/o allowlist de IPs.
9. Tokens dedicados por flujo, con mínimo privilegio.
10. Rotación de secretos automatizada (al menos trimestral).
11. Revisión por pares para flujos críticos.
12. Alertas de fallos y de volúmenes anómalos.
13. Backups y prueba de restore trimestral.
14. Inventario de datos y diagrama de flujos con PII marcado.
15. Plan de respuesta a incidentes escrito y accesible.


## 📖 Referencias útiles
- [n8n Documentation – Security & Hardening](https://docs.n8n.io/hosting/securing-n8n/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [HashiCorp Vault](https://www.vaultproject.io/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [GDPR Overview](https://gdpr-info.eu/)
