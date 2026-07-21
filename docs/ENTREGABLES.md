# Entregables Finales — PeoplePortal

> **Estudiante:** Bryan Xol  
> **Curso:** Proyecto Curso I  
> **Fecha de entrega:** Semana Final

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

📄 Ver [`README.md`](../README.md) — incluye:
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
| [`arquitectura.md`](./arquitectura.md) | Diagrama C4 Nivel 1 y C4 Nivel 2 (Contenedores) |
| [`flujos.md`](./flujos.md) | Diagramas de secuencia del flujo principal |
| [`base-de-datos.md`](./base-de-datos.md) | Modelo Entidad-Relación (ER Diagram) |
| [`despliegue.md`](./despliegue.md) | Pipeline CI/CD, proceso de despliegue y Runbook |
| [`seguridad.md`](./seguridad.md) | Mapeo OWASP Top 10 |

### `docs/prompts/`

Catálogo de prompts utilizados durante el desarrollo:

| Categoría | Archivo |
|---|---|
| Arquitectura | [`prompts/arquitectura/diagrama-c4.md`](./prompts/arquitectura/diagrama-c4.md) |
| Arquitectura | [`prompts/arquitectura/diseno-entidades.md`](./prompts/arquitectura/diseno-entidades.md) |
| Backend | [`prompts/backend/cqrs-handlers.md`](./prompts/backend/cqrs-handlers.md) |
| Base de Datos | [`prompts/base-de-datos/schema-y-seed.md`](./prompts/base-de-datos/schema-y-seed.md) |
| CI/CD | [`prompts/ci-cd/pipelines.md`](./prompts/ci-cd/pipelines.md) |
| Docker | [`prompts/docker/dockerfiles.md`](./prompts/docker/dockerfiles.md) |
| Frontend Colaborador | [`prompts/frontend-colaborador/paginas-y-componentes.md`](./prompts/frontend-colaborador/paginas-y-componentes.md) |
| Frontend RRHH | [`prompts/frontend-rrhh/paginas-y-componentes.md`](./prompts/frontend-rrhh/paginas-y-componentes.md) |
| Kubernetes | [`prompts/kubernetes/manifiestos.md`](./prompts/kubernetes/manifiestos.md) |
| Seguridad | [`prompts/seguridad/owasp.md`](./prompts/seguridad/owasp.md) |
| Tests | [`prompts/tests/pruebas.md`](./prompts/tests/pruebas.md) |

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
| Video Demo | ✅ Realizado | [Ver video demo](./video-demo.md) |
| Capturas de pantalla | ⚠️ Pendiente | Agregar en README.md |
