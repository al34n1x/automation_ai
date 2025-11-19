# Guía básica: Servidores, Docker, Máquinas Virtuales y n8n Cloud

Este documento tiene como objetivo explicar de manera sencilla algunos conceptos clave que suelen aparecer cuando hablamos de **infraestructura**, **contenedores** y **automatización con n8n**.

---

## 🔹 ¿Qué es un servidor?

Un **servidor** es una computadora (física o virtual) diseñada para proveer servicios a otros programas o usuarios a través de una red.

* **Servidor físico**: hardware dedicado (ej. un rack en un datacenter).
* **Servidor virtual**: una máquina virtual dentro de un servidor físico, creada con software de virtualización (VMware, VirtualBox, KVM, etc.).

Ejemplos de uso:

* Servidores web (ej. Apache, Nginx).
* Servidores de base de datos (ej. MySQL, Postgres).
* Servidores de aplicaciones (ej. Node.js, Java EE).

---

## 🔹 ¿Qué es Docker?

**Docker** es una plataforma que permite crear, ejecutar y gestionar **contenedores**.

* Un **contenedor** es una “cajita” ligera que incluye la aplicación y todas sus dependencias, pero comparte el mismo núcleo del sistema operativo (a diferencia de una VM).
* Los contenedores son portátiles: se pueden correr en tu laptop, en un servidor o en la nube sin cambios.

Ejemplo:

```bash
docker run -it --rm -p 5678:5678 n8nio/n8n
```

Con este comando podés ejecutar n8n en un contenedor, sin instalar Node.js o dependencias.

---

## 🔹 Diferencias entre Docker y una Máquina Virtual (VM)

| Característica | Docker (contenedores)                                | Máquina Virtual (VM)                        |
| -------------- | ---------------------------------------------------- | ------------------------------------------- |
| Peso           | Ligero (MBs)                                         | Pesada (GBs)                                |
| Arranque       | Segundos                                             | Minutos                                     |
| Kernel         | Comparte el kernel del host                          | Tiene su propio kernel y SO completo        |
| Aislamiento    | A nivel de proceso                                   | A nivel de hardware (hipervisor)            |
| Portabilidad   | Muy alta (misma imagen en cualquier host con Docker) | Alta, pero requiere exportar VM completa    |
| Uso típico     | Microservicios, despliegue ágil                      | Escenarios donde se necesita un SO completo |

👉 Resumen rápido: **Docker es más liviano y ágil**, mientras que una VM es más pesada pero ofrece aislamiento completo de sistema operativo.

---

## 🔹 Diferencias con n8n Cloud

**n8n Cloud** es la versión **SaaS (Software as a Service)** de n8n, donde el equipo de n8n se encarga de la infraestructura.

| Aspecto       | n8n Cloud                        | Docker/Servidor propio                         |
| ------------- | -------------------------------- | ---------------------------------------------- |
| Instalación   | No requiere, listo para usar     | Tenés que instalar y mantenerlo                |
| Escalabilidad | Automática (gestionada por n8n)  | Depende de tu servidor y configuración         |
| Control       | Limitado (lo que ofrece el SaaS) | Total: configuraciones, integraciones, plugins |
| Costos        | Suscripción mensual              | Costos de servidor + mantenimiento             |
| Seguridad     | Gestionada por n8n (con SLA)     | Depende de cómo configures tu servidor         |

👉 En resumen:

* **n8n Cloud** es para quienes quieren rapidez y olvidarse de la parte técnica.
* **Docker o servidor propio** es para quienes necesitan control total, flexibilidad o integración con sistemas internos.


# 📊 Formas de acceder a n8n según dificultad

¿Para qué usar cada uno?

* **n8n Cloud** → empezar rápido, cero infraestructura.
* **Docker local o en servidor** → control total, ideal para empresas o usuarios técnicos.
* **VMs** → cuando necesitás un SO completo con fuerte aislamiento.
* **Servidores físicos** → cuando querés rendimiento dedicado o infraestructura on-premise.


| Nivel | Opción                                 | Dificultad ⚡ | Pros ✅                                                                                       | Contras ❌                                                                          | Ideal para 👤                                                        |
| ----- | -------------------------------------- | ------------ | -------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| 1     | **n8n Cloud (SaaS oficial)**           | ⭐            | - No requiere instalación<br>- Escalable y mantenido por n8n<br>- Soporte y features premium | - Es pago (tras el free trial)<br>- Menos control sobre la infra                   | Usuarios que quieren empezar rápido sin preocuparse por nada técnico |
| 2     | **Docker local**                       | ⭐⭐           | - Rápido de levantar<br>- Entorno reproducible<br>- Persistencia con volúmenes               | - Necesitás instalar Docker                                                        | Devs que quieren simular producción en su máquina                    |
| 3     | **npm local**                          | ⭐⭐           | - Sencillo si ya usás Node.js<br>- Muy flexible                                              | - Puede romper dependencias de Node global<br>- Menos aislado que Docker           | Devs que prefieren trabajar directo con Node.js                      |
| 4     | **PaaS (Railway, Render, etc.)**       | ⭐⭐⭐          | - Deploy con un clic<br>- Infra gestionada                                                   | - Limitaciones de recursos en planes free<br>- Menos control sobre red y seguridad | Prototipos rápidos en la nube                                        |
| 5     | **Docker en servidor (VPS/Cloud)**     | ⭐⭐⭐          | - Control total<br>- Escalable<br>- Portátil                                                 | - Necesitás gestionar servidor, seguridad y actualizaciones                        | Usuarios intermedios con VPS/Cloud propio                            |
| 6     | **npm en servidor**                    | ⭐⭐⭐          | - No requiere Docker<br>- Flexible con Node                                                  | - Menos portable que Docker<br>- Puede complicar dependencias                      | Casos donde no se quiere usar contenedores                           |
| 7     | **Kubernetes (K8s)**                   | ⭐⭐⭐⭐         | - Escalabilidad y HA<br>- Integración con monitoreo y secretos                               | - Complejidad alta<br>- Requiere conocimientos de K8s                              | Empresas grandes con infra compleja                                  |

## ✅ Conclusión

* Un **servidor** es la base donde corren las aplicaciones.
* **Docker** permite empaquetar y ejecutar apps de forma ligera y portátil.
* Una **VM** ofrece un entorno completo de SO, pero más pesado que Docker.
* **n8n Cloud** elimina la necesidad de gestionar servidores, a cambio de pagar una suscripción y ceder algo de control.

---
[⬅ Back to Course Overview](../../README.md)