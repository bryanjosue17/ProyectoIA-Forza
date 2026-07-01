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
| Base de datos | SQL Server 2022, EF Core 9 |
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

## Estado del proyecto

Ver [docs/plan-implementacion.md](./docs/plan-implementacion.md) para el estado completo.

**Resumen:**
- Backend + ambos frontends ✅ operativos con tests en verde
- Cobertura global ≥ 60% ✅
- Seguridad y autenticación activas ✅
- Infraestructura K8s documentada ✅
- Video demo pendiente ❌
- Repos en organización Forza pendiente ⚠️
