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
| Backend | [`docs/prompts/backend/cqrs-handlers.md`](./docs/prompts/backend/cqrs-handlers.md) |
| Base de Datos | [`docs/prompts/base-de-datos/schema-y-seed.md`](./docs/prompts/base-de-datos/schema-y-seed.md) |
| CI/CD | [`docs/prompts/ci-cd/pipelines.md`](./docs/prompts/ci-cd/pipelines.md) |
| Docker | [`docs/prompts/docker/dockerfiles.md`](./docs/prompts/docker/dockerfiles.md) |
| Frontend Colaborador | [`docs/prompts/frontend-colaborador/paginas-y-componentes.md`](./docs/prompts/frontend-colaborador/paginas-y-componentes.md) |
| Frontend RRHH | [`docs/prompts/frontend-rrhh/paginas-y-componentes.md`](./docs/prompts/frontend-rrhh/paginas-y-componentes.md) |
| Kubernetes | [`docs/prompts/kubernetes/manifiestos.md`](./docs/prompts/kubernetes/manifiestos.md) |
| Seguridad | [`docs/prompts/seguridad/owasp.md`](./docs/prompts/seguridad/owasp.md) |
| Tests | [`docs/prompts/tests/pruebas.md`](./docs/prompts/tests/pruebas.md) |

---

## 4. Propuesta (Semana 1)

📄 [`Brief_Capstone_ForzaTechAcademy_v1.pdf`](./Brief_Capstone_ForzaTechAcademy_v1.pdf)

> **Nota:** La propuesta original en formato `.docx` ha sido convertida a PDF exitosamente para la entrega final.

---

## 5. Video Demo

🎥 **Enlace del video demostrativo:**  
[https://1drv.ms/v/c/1da8397487f6c670/IQDj3mseN8KsQrgYq93vCtX7Afy7cQfNQaI8CC3_MsRebk8?e=6WGI5f](https://1drv.ms/v/c/1da8397487f6c670/IQDj3mseN8KsQrgYq93vCtX7Afy7cQfNQaI8CC3_MsRebk8?e=6WGI5f)  
> Duración: 5–8 minutos. Hospedado en OneDrive.

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
| `docs/prompts/` | ✅ Listo | Catálogo completo (11 archivos en 10 categorías) |
| CI/CD Workflows | ✅ Listo | GitHub Actions en los 3 submódulos |
| Propuesta Semana 1 (PDF) | ✅ Listo | Convertido a PDF exitosamente |
| Video Demo | ✅ Realizado | [Ver video demo](../docs/video-demo.md) |
| Capturas de pantalla | ⚠️ Pendiente | Agregar en README.md |
