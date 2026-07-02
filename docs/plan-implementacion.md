# Plan de Implementación General — PeoplePortal (Backend + Frontend + Infra)

> Documento unificado (reemplaza el contenido de `PENDIENTE.md` y del plan anterior).  
> Última actualización: 2026-06-30.

## 1. Alcance del plan

Este plan cubre de forma integral:

- Backend (`PeoplePortal-BackEnd`)
- Frontend Colaborador (`PeoplePortal-FrontEnd-Colaborador`)
- Frontend RRHH (`PeoplePortal-FrontEnd-RRHH`)
- Infraestructura y DevOps (K8s, APISIX, Keycloak, NATS, CI/CD)

## 2. Checklist de trabajo abarcado

### 2.1 Completado

| # | Tema | Estado | Evidencia resumida |
|---|------|--------|--------------------|
| 1 | Arquitectura base (Clean + CQRS) | ✅ | Capas Domain/Application/Infrastructure/Api y MediatR activos |
| 2 | Módulos funcionales MVP | ✅ | Perfil, documentos, comunicados, beneficios, solicitudes, dashboard, panel RRHH, reportes |
| 3 | Autenticación y roles Keycloak | ✅ | JWT + PKCE S256 + políticas por rol |
| 4 | NATS JetStream integrado | ✅ | Publicación/consumo de eventos en infraestructura |
| 5 | PostgreSQL + migraciones versionadas | ✅ | Migraciones EF Core (PostgreSQL) aplicadas |
| 6 | Kubernetes (manifiestos) | ✅ | Manifiestos globales y por subproyecto |
| 7 | APISIX gateway | ✅ | Configuración declarativa y plugin OIDC |
| 8 | CI/CD en repos principales | ✅ | Build/test/lint y pipeline docker |
| 9 | Documentación técnica principal | ✅ | Docs de arquitectura, despliegue, seguridad, flujos |
| 10 | Tests backend en verde | ✅ | 49/49 |
| 11 | Tests frontend colaborador en verde | ✅ | 25/25 |
| 12 | Tests frontend RRHH en verde | ✅ | 29/29 |
| 13 | Cobertura global >= 60% (scope de cobertura configurado) | ✅ | Líneas 60.57%, ramas 60.20% |

### 2.2 Pendiente / parcial

| # | Tema | Estado | Acción siguiente |
|---|------|--------|------------------|
| 1 | Video demo 5-8 min | ❌ | Grabar walkthrough funcional completo |
| 2 | Repositorio privado en organización Forza | ⚠️ | Crear/usar org y transferir 4 repos |
| 3 | Codacy (issues críticos/altos en 0) validado formalmente | ⚠️ | Revisar dashboard final por repo |
| 4 | Deploy automático a K8s desde CI | ❌ | Definir runner con acceso al cluster o estrategia CD alternativa |

## 3. Validación de temas del plan anterior

En esta sección se responde explícitamente: "lo del plan anterior ya se realizó o no".

| Tema del plan anterior | Resultado actual |
|------------------------|------------------|
| Fundamentos de repositorio y ramas | ✅ Realizado |
| Branch protection | ✅ Realizado |
| Pipeline CI (build/test/lint/security) | ✅ Realizado |
| Push de imágenes (docker) | ✅ Realizado |
| Dominio ampliado (entidades principales) | ✅ Realizado |
| EDD con NATS JetStream | ✅ Realizado |
| APISIX + OIDC | ✅ Realizado |
| Endpoints principales de negocio | ✅ Realizado |
| Roles y autorización por políticas | ✅ Realizado |
| Documentación técnica en `/docs` | ✅ Realizado |
| Suite de tests funcionales backend + frontends | ✅ Realizado |
| Meta cobertura >= 60% | ✅ Realizado (global consolidado) |
| Integraciones avanzadas pendientes (flujos e2e completos con contenedores en CI) | ⚠️ Parcial |
| Video demo del proyecto | ❌ No realizado |

## 4. Estado por capa (general)

### 4.1 Backend

- Estado general: ✅ Operativo
- Entidades/módulos clave: ✅
- Controladores y handlers: ✅
- Seguridad y validaciones: ✅
- Mensajería NATS: ✅
- Tests backend: ✅

### 4.2 Frontend Colaborador

- Estado general: ✅ Operativo
- Autenticación Keycloak: ✅
- Módulos UI principales: ✅
- Correcciones de layout/grid/forms: ✅
- Tests: ✅

### 4.3 Frontend RRHH

- Estado general: ✅ Operativo
- Guards por rol (`hr/admin`): ✅
- Módulos administrativos: ✅
- Correcciones de layout/grid/forms: ✅
- Tests: ✅

### 4.4 Infraestructura y DevOps

- Kubernetes manifiestos: ✅
- APISIX + rutas: ✅
- Keycloak realm/roles/clientes: ✅
- CI/CD base: ✅
- CD automático a cluster desde CI: ❌

## 5. Riesgos y siguientes pasos recomendados

1. Formalizar cierre de calidad en Codacy por los 3 repos de código.
2. Grabar video demo técnico-funcional (5-8 min).
3. Mover repos a organización Forza (privado) y confirmar políticas.
4. Definir estrategia de CD real (GitHub Actions -> entorno destino).

## 6. Criterio de cierre de implementación

El proyecto se considera técnicamente implementado para alcance MVP+ cuando:

- Backend + ambos frontends están en verde en tests.
- Cobertura global consolidada está en 60% o superior.
- Seguridad/autenticación/autorización están activas.
- Infraestructura base y despliegue están documentados.

Estado actual frente a este criterio: ✅ CUMPLIDO (con pendientes administrativos/documentales señalados arriba).

### 2.3 Últimos Parches (Correcciones Fase 2)
- ✅ Migración exitosa de base de datos a **PostgreSQL** para optimizar persistencia.
- ✅ Resolución de bugs de UI/UX en paneles FrontEnd y fechas.
- ✅ Fijación de identidades (UUIDs) de Keycloak en ConfigMap para evitar orfandad tras reinicios de pod.
- ✅ Refactor de Dashboard RRHH para extraer métricas precisas del backend.
