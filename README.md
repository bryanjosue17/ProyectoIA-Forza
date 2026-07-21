# PeoplePortal: Portal del Colaborador

## Descripción general

**PeoplePortal** es una plataforma web de autoservicio para colaboradores, diseñada para centralizar la información laboral de cada empleado y facilitar la gestión de procesos internos con RRHH.

El sistema permite que cada colaborador tenga acceso a su propio portal para consultar su información personal, documentos, beneficios, comunicados y realizar solicitudes a RRHH desde un solo lugar.

RRHH, por su parte, cuenta con un panel administrativo para gestionar colaboradores, documentos, solicitudes, aprobaciones, comunicados y reportes.

---

## Submódulos

Este repositorio es un **monorepo** que gestiona tres subproyectos independientes mediante Git Submodules:

| Subproyecto | Descripción | Documentación |
|---|---|---|
| [PeoplePortal-BackEnd](https://github.com/bryanjosue17/PeoplePortal-BackEnd) | API REST .NET 9 — Clean Architecture + CQRS | [docs](https://github.com/bryanjosue17/PeoplePortal-BackEnd/tree/main/docs) |
| [PeoplePortal-FrontEnd-Colaborador](https://github.com/bryanjosue17/PeoplePortal-FrontEnd-Colaborador) | React 19 — Portal del empleado | [docs](https://github.com/bryanjosue17/PeoplePortal-FrontEnd-Colaborador/tree/main/docs) |
| [PeoplePortal-FrontEnd-RRHH](https://github.com/bryanjosue17/PeoplePortal-FrontEnd-RRHH) | React 19 — Panel administrativo RRHH | [docs](https://github.com/bryanjosue17/PeoplePortal-FrontEnd-RRHH/tree/main/docs) |

---

## Documentación global

Ver [`docs/`](./docs/README.md) para la documentación de infraestructura y arquitectura del sistema completo:

- [Arquitectura global](./docs/tecnico/arquitectura.md) — diagrama de sistema, puertos K8s y roles
- [Guía de despliegue](./docs/tecnico/despliegue.md) — GHCR, K8s, scripts y CI/CD
- [Pruebas E2E](./docs/tecnico/playwright.md) — Playwright, flujos, screenshots
- [Video demo](./docs/proyecto/video-demo.md) — walkthrough funcional completo (5–8 min)
- [Plan de implementación](./docs/proyecto/plan-implementacion.md) — estado del proyecto
- [ADR-001: React vs Angular](./docs/adr/001-react-en-lugar-de-angular.md) — decisión de stack

---

## Stack tecnológico global

| Componente | Tecnología |
|---|---|
| Backend | .NET 9, Clean Architecture, CQRS, MediatR |
| Frontend Colaborador | React 19, Vite, MUI v9, AuthContext (ROPC) |
| Frontend RRHH | React 19, Vite, MUI v9, AuthContext (ROPC) |
| Base de datos | PostgreSQL 16, EF Core 9 |
| Autenticación | Keycloak 24 — token endpoint ROPC + JWT Bearer |
| API Gateway | APISIX con plugin openid-connect |
| Mensajería | NATS JetStream |
| Contenedores | Docker + docker-compose |
| Orquestación | Kubernetes (namespace `peopleportal`) |
| CI/CD | GitHub Actions + Codacy + Trivy |

---

## Roles del sistema

| Rol | Función | Portal |
|---|---|---|
| `employee` | Consulta información, documentos, beneficios y crea solicitudes | Colaborador |
| `jefe_inmediato` | Aprueba vacaciones y permisos de su equipo | Colaborador |
| `hr` | Administra colaboradores, documentos, solicitudes y comunicados | RRHH |
| `nomina` | Carga vouchers de pago y documentos de pago | RRHH |
| `admin` | Gestiona usuarios, roles, permisos y configuración | RRHH |

---

## Cómo clonar el proyecto

```bash
# Con submódulos en un solo paso (recomendado)
git clone --recurse-submodules https://github.com/bryanjosue17/ProyectoIA-Forza.git

# Si ya clonaste sin submódulos
git submodule update --init --recursive
```

### Actualizar submódulos a la última versión de `develop`

```bash
git submodule foreach 'git fetch origin && git checkout develop && git pull origin develop'
```

### Trabajar en un submódulo

```bash
cd PeoplePortal-BackEnd   # o FrontEnd-Colaborador / FrontEnd-RRHH
git checkout develop
git pull origin develop
# ... hacer cambios ...
git add .
git commit -m "feat: descripción"
git push origin develop
```

Luego, desde la raíz, actualizar la referencia del submódulo:

```bash
cd ..
git add PeoplePortal-BackEnd
git commit -m "chore: update submodule ref"
git push origin develop
```

---

## Prerrequisitos

Para ejecutar este proyecto de forma local, necesitas tener instalados:

- **Docker Desktop** (con Kubernetes activado)
- **Git**
- **.NET 9 SDK** (opcional, para desarrollo backend)
- **Node.js 22+** (opcional, para desarrollo frontend)
- **Powershell 7+** (recomendado para scripts en Windows)

---

## Instrucciones para ejecutar el proyecto

Este proyecto se despliega mediante un script automatizado que obtiene las imágenes desde **GitHub Container Registry (GHCR)** y las aplica en Kubernetes local.

1. Abre una terminal (Powershell) en la raíz del proyecto.
2. Ejecuta el script de despliegue:
   ```powershell
   ./deploy/deploy.ps1
   ```
   El script (sin parámetros) usa el entorno `develop` por defecto y obtiene las imágenes del último CI exitoso en GHCR.
3. El script despliega automáticamente:
   - PostgreSQL, NATS, Keycloak (con realm pre-configurado)
   - API Backend, Frontend RRHH, Frontend Colaborador, APISIX
4. **Acceso al sistema:**
   - Portal Colaborador: [http://localhost:30081](http://localhost:30081) — `testmanager` / `test123`
   - Portal RRHH: [http://localhost:30082](http://localhost:30082) — `admin` / `admin123`
   - Keycloak Admin: [http://localhost:30080/admin](http://localhost:30080/admin) — `admin` / `admin`
   - API Swagger: `http://localhost:30099/swagger/index.html`

Para más detalles, opciones de entorno y despliegue manual, ver [docs/tecnico/despliegue.md](./docs/tecnico/despliegue.md).

---

## Variables de entorno

El proyecto maneja los secretos a través de Kubernetes Secrets (`k8s/secret.yaml`). Las variables de entorno relevantes por capa son:

**Backend (API):**
- `ConnectionStrings__DefaultConnection` — cadena de conexión a PostgreSQL
- `Authentication__Authority` — URL del realm Keycloak (`http://keycloak-service:8080/realms/peopleportal`)
- `Authentication__Audience` — `peopleportal-api`

**Frontends (Vite):**
- `VITE_KEYCLOAK_URL` — URL del servidor Keycloak (ej. `http://localhost:30080`)
- `VITE_API_URL` — Base URL de la API (vacío = misma origin, el nginx hace proxy de `/api/`)

---

## Capturas de pantalla

Las capturas de cada módulo se generan automáticamente al ejecutar los tests E2E con Playwright.
Ver [`docs/tecnico/playwright.md`](./docs/tecnico/playwright.md) para instrucciones de ejecución y visualización de reportes.

---

## Matriz de cumplimiento (Anexo B)

| Requisito | Estado | Observación / Enlace |
|---|---|---|
| Repositorio con código fuente | ✅ Cumple | Monorepo con submódulos. |
| README completo | ✅ Cumple | Presente en la raíz. |
| Carpeta docs/ | ✅ Cumple | Arquitectura, Flujos, BD, Despliegue, Seguridad. |
| Carpeta docs/prompts/ | ✅ Cumple | Catálogo de prompts incluido. |
| Workflows CI/CD | ✅ Cumple | Github Actions configurado en submódulos. |
| Despliegue automatizado | ✅ Cumple | Script `deploy.ps1` e infraestructura en `k8s/`. |
| Arquitectura C4 | ✅ Cumple | Nivel 1 y 2 en [`docs/tecnico/arquitectura.md`](./docs/tecnico/arquitectura.md). |
| Mapeo OWASP Top 10 | ✅ Cumple | Ver [`docs/tecnico/seguridad.md`](./docs/tecnico/seguridad.md). |
| Diagramas ER y Secuencia | ✅ Cumple | Ver [`docs/tecnico/base-de-datos.md`](./docs/tecnico/base-de-datos.md) y [`docs/tecnico/flujos.md`](./docs/tecnico/flujos.md). |

---

## Estado del proyecto

Ver [docs/proyecto/plan-implementacion.md](./docs/proyecto/plan-implementacion.md) para el estado completo.

**Resumen:**
- Backend + ambos frontends ✅ operativos con tests en verde
- Cobertura global ≥ 60% ✅
- Seguridad y autenticación activas ✅
- Infraestructura K8s documentada ✅
- Video demo ✅ — [ver video demo](./docs/proyecto/video-demo.md)

---

## Entregables del curso

> Estudiante: Bryan Xol · Curso: Proyecto Curso I

| Entregable | Estado | Ubicación |
|---|---|---|
| Repositorio GitHub | ✅ Listo | https://github.com/bryanjosue17/ProyectoIA-Forza |
| README.md en raíz | ✅ Listo | Este archivo |
| Arquitectura C4 | ✅ Listo | [`docs/tecnico/arquitectura.md`](./docs/tecnico/arquitectura.md) |
| Diagramas de flujo | ✅ Listo | [`docs/tecnico/flujos.md`](./docs/tecnico/flujos.md) |
| Esquema ER | ✅ Listo | [`docs/tecnico/base-de-datos.md`](./docs/tecnico/base-de-datos.md) |
| Guía de despliegue | ✅ Listo | [`docs/tecnico/despliegue.md`](./docs/tecnico/despliegue.md) |
| Seguridad OWASP | ✅ Listo | [`docs/tecnico/seguridad.md`](./docs/tecnico/seguridad.md) |
| Catálogo de prompts | ✅ Listo | [`docs/prompts/`](./docs/prompts/) |
| CI/CD Workflows | ✅ Listo | GitHub Actions en los 3 submódulos |
| Propuesta Semana 1 (PDF) | ✅ Listo | [`docs/propuesta/Brief_Capstone_ForzaTechAcademy_v1.pdf`](./docs/propuesta/Brief_Capstone_ForzaTechAcademy_v1.pdf) |
| Video Demo | ✅ Realizado | [`docs/proyecto/video-demo.md`](./docs/proyecto/video-demo.md) |
