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
| [PeoplePortal-BackEnd](./PeoplePortal-BackEnd/README.md) | API REST .NET 9 — Clean Architecture + CQRS | [docs](./PeoplePortal-BackEnd/docs/README.md) |
| [PeoplePortal-FrontEnd-Colaborador](./PeoplePortal-FrontEnd-Colaborador/README.md) | React 19 — Portal del empleado | [docs](./PeoplePortal-FrontEnd-Colaborador/docs/README.md) |
| [PeoplePortal-FrontEnd-RRHH](./PeoplePortal-FrontEnd-RRHH/README.md) | React 19 — Panel administrativo RRHH | [docs](./PeoplePortal-FrontEnd-RRHH/docs/README.md) |

---

## Documentación global

Ver [`docs/`](./docs/README.md) para la documentación de infraestructura y arquitectura del sistema completo:

- [Arquitectura global](./docs/arquitectura.md) — diagrama de sistema, puertos K8s y roles
- [Guía de despliegue](./docs/despliegue.md) — build, K8s, scripts y CI/CD
- [Plan de implementación](./docs/plan-implementacion.md) — estado del proyecto
- [ADR-001: React vs Angular](./docs/adr/001-react-en-lugar-de-angular.md) — decisión de stack

---

## Stack tecnológico global

| Componente | Tecnología |
|---|---|
| Backend | .NET 9, Clean Architecture, CQRS, MediatR |
| Frontend Colaborador | React 19, Vite, MUI v9, Keycloak-js |
| Frontend RRHH | React 19, Vite, MUI v9, Keycloak-js |
| Base de datos | PostgreSQL 16, EF Core 9 |
| Autenticación | Keycloak (JWT + PKCE S256) |
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

Este proyecto está diseñado para desplegarse fácilmente mediante un script automatizado que construye las imágenes y despliega todos los manifiestos en Kubernetes de forma local.

1. Abre una terminal (Powershell) en la raíz del proyecto.
2. Ejecuta el script de despliegue principal:
   ```bash
   ./deploy/deploy.ps1
   ```
3. El script creará el namespace `peopleportal` y desplegará:
   - PostgreSQL (con persistencia PVC)
   - NATS JetStream
   - Keycloak (con configuración de realm pre-cargada)
   - API Backend
   - Frontend RRHH
   - Frontend Colaborador
   - APISIX (API Gateway + OIDC Plugin)

4. **Acceso al sistema:**
   - Portal Colaborador: [http://localhost:30081](http://localhost:30081)
   - Portal RRHH: [http://localhost:30082](http://localhost:30082)
   - API Swagger: `http://localhost:30090/api/swagger`
   - Keycloak Admin: [http://localhost:30080](http://localhost:30080) (user: `admin`, pass: `admin`)

---

## Variables de entorno necesarias

El proyecto maneja los secretos a través de Kubernetes Secrets (ver `k8s/secret.yaml`), pero a nivel de código se manejan las siguientes variables:

**Backend (API):**
- `ConnectionStrings__DefaultConnection`: Conexión a PostgreSQL.
- `Jwt__Authority`: URL de Keycloak (`http://keycloak.peopleportal.svc.cluster.local:8080/realms/peopleportal`).
- `Jwt__Audience`: `account`.

**Frontends (Vite):**
- `VITE_KEYCLOAK_URL`: `http://localhost:30080`
- `VITE_KEYCLOAK_REALM`: `peopleportal`
- `VITE_KEYCLOAK_CLIENT_ID`: `peopleportal-frontend` (Colaborador) o `peopleportal-hr-frontend` (RRHH)
- `VITE_API_BASE_URL`: `http://localhost:30090` (APISIX Gateway)

---

## Capturas de pantalla

> **Nota:** Puedes agregar tus capturas de pantalla aquí demostrando el sistema en funcionamiento.

- **Dashboard RRHH:**
  ![Dashboard RRHH](docs/assets/dashboard_rrhh.png) <!-- TODO: Sube tu captura a esta ruta -->

- **Portal Colaborador:**
  ![Portal Colaborador](docs/assets/portal_colaborador.png) <!-- TODO: Sube tu captura a esta ruta -->

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
| Arquitectura C4 | ✅ Cumple | Nivel 1 y 2 en `docs/arquitectura.md`. |
| Mapeo OWASP Top 10 | ✅ Cumple | Ver `docs/seguridad.md`. |
| Diagramas ER y Secuencia | ✅ Cumple | Ver `docs/base-de-datos.md` y `docs/flujos.md`. |

---

## Estado del proyecto

Ver [docs/plan-implementacion.md](./docs/plan-implementacion.md) para el estado completo.

**Resumen:**
- Backend + ambos frontends ✅ operativos con tests en verde
- Cobertura global ≥ 60% ✅
- Seguridad y autenticación activas ✅
- Infraestructura K8s documentada ✅
- Video demo pendiente ❌
- Repos en organización Forza pendiente ⚠️
