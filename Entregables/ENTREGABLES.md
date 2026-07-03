# Entregables Finales — Proyecto Curso IA
## PeoplePortal: Portal del Colaborador

> **Estudiante:** Bryan Xol  
> **Curso:** Proyecto Curso I  
> **Fecha de entrega:** Semana Final

---

## 1. Repositorio en GitHub

🔗 **Enlace del repositorio:**  
https://github.com/bryanjosue17/ProyectoIA-Forza

El repositorio contiene:
- ✅ Código fuente completo (monorepo con 3 submódulos)
- ✅ `README.md` en la raíz
- ✅ Carpeta `docs/`
- ✅ Carpeta `docs/prompts/`
- ✅ Workflows de CI/CD (GitHub Actions en cada submódulo)
- ✅ Archivos para despliegue (`k8s/`, `deploy/`, `docker-compose.yml`)

---

## 2. README.md

📄 Ver [`README.md`](./README.md) — incluye:
- Descripción del proyecto
- Objetivo del sistema
- Prerrequisitos
- Instrucciones para ejecutar el proyecto
- Variables de entorno necesarias
- Capturas de pantalla (pendientes de agregar)
- Enlaces a la documentación
- Matriz de cumplimiento (Anexo B)

---

## 3. Documentación (`docs/`)

| Archivo | Contenido |
|---|---|
| [`docs/arquitectura.md`](./docs/arquitectura.md) | Diagrama C4 Nivel 1 y C4 Nivel 2 (Contenedores) |
| [`docs/flujos.md`](./docs/flujos.md) | Diagramas de secuencia del flujo principal |
| [`docs/base-de-datos.md`](./docs/base-de-datos.md) | Modelo Entidad-Relación (ER Diagram) |
| [`docs/despliegue.md`](./docs/despliegue.md) | Pipeline CI/CD, proceso de despliegue y Runbook |
| [`docs/seguridad.md`](./docs/seguridad.md) | Mapeo OWASP Top 10 |

### `docs/prompts/`

Catálogo de prompts utilizados durante el desarrollo:

| Categoría | Archivo |
|---|---|
| Arquitectura | [`docs/prompts/arquitectura/diagrama-c4.md`](./docs/prompts/arquitectura/diagrama-c4.md) |
| Arquitectura | [`docs/prompts/arquitectura/diseno-entidades.md`](./docs/prompts/arquitectura/diseno-entidades.md) |
| Código | [`docs/prompts/codigo/scaffolding-handler-cqrs.md`](./docs/prompts/codigo/scaffolding-handler-cqrs.md) |
| Código | [`docs/prompts/codigo/consumer-nats.md`](./docs/prompts/codigo/consumer-nats.md) |
| Código | [`docs/prompts/codigo/pipeline-github-actions.md`](./docs/prompts/codigo/pipeline-github-actions.md) |
| Tests | [`docs/prompts/tests/unit-tests-handler.md`](./docs/prompts/tests/unit-tests-handler.md) |

---

## 4. Propuesta (Semana 1)

📄 [`Brief_Capstone_ForzaTechAcademy_v1.docx`](./Brief_Capstone_ForzaTechAcademy_v1.docx)

> **Nota:** La propuesta original se encuentra en formato `.docx`. Si se requiere en PDF, convertir antes de la entrega.

---

## 5. Video Demo

🎥 **Enlace del video demostrativo:**  
> ⚠️ **PENDIENTE** — Agregar el enlace del video demo aquí.  
> Duración esperada: entre 5 y 8 minutos.

---

## 6. Checklist de Entregables

| Entregable | Estado | Detalle |
|---|---|---|
| Repositorio GitHub | ✅ Listo | https://github.com/bryanjosue17/ProyectoIA-Forza |
| README.md en raíz | ✅ Listo | Incluye todos los requisitos mínimos |
| `docs/arquitectura.md` | ✅ Listo | C4 Nivel 1 y Nivel 2 |
| `docs/flujos.md` | ✅ Listo | Diagramas de secuencia |
| `docs/base-de-datos.md` | ✅ Listo | ER Diagram |
| `docs/despliegue.md` | ✅ Listo | CI/CD + Runbook |
| `docs/seguridad.md` | ✅ Listo | Mapeo OWASP Top 10 |
| `docs/prompts/` | ✅ Listo | 6 prompts categorizados |
| CI/CD Workflows | ✅ Listo | GitHub Actions en los 3 submódulos |
| Propuesta Semana 1 (PDF) | ⚠️ Pendiente | Disponible en `.docx`, convertir a PDF |
| Video Demo | ❌ Pendiente | Grabar video de 5–8 minutos |
| Capturas de pantalla | ⚠️ Pendiente | Agregar en README.md |
