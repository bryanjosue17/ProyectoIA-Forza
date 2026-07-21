# Mapa de Evaluación — Capstone Forza Tech Academy

Este documento relaciona directamente los requisitos obligatorios exigidos en el **Brief del Capstone (v1.0)** con su ubicación exacta dentro del código fuente de este repositorio. Facilita la revisión por parte del comité evaluador.

## 1. Requisitos Técnicos Obligatorios (Sección 6)

| Componente Exigido | Ubicación en el Repositorio | Descripción Breve |
|---|---|---|
| **Repositorio GitHub** | Raíz (`/`) | Monorepo público/privado con submódulos, branch protection y control de versiones. |
| **CI/CD (GitHub Actions)** | `.github/workflows/ci.yml` (en los 3 submódulos) | Pipelines configurados con build, tests, linting, análisis de Codacy y escaneo de vulnerabilidades con Trivy. |
| **Autenticación Keycloak** | `k8s/keycloak.yaml`<br>`k8s/keycloak-realm-configmap.yaml` | Keycloak 24 con ROPC (formulario login propio). Frontends usan AuthContext con POST directo al token endpoint. Configuración pre-cargada con roles (`employee`, `hr`, `admin`, etc.). |
| **API Gateway (APISIX)** | `k8s/apisix.yaml`<br>`k8s/apisix-configmap.yaml` | Único punto de entrada a las APIs. Integración directa con plugin `openid-connect`. |
| **Frontend (React)** | `PeoplePortal-FrontEnd-Colaborador/`<br>`PeoplePortal-FrontEnd-RRHH/` | Dos SPAs desarrolladas en React 19 + Vite, integradas con Keycloak. |
| **Backend (.NET + Clean Arch)** | `PeoplePortal-BackEnd/src/` | API construida en .NET 9 usando Clean Architecture, CQRS y MediatR. |
| **Persistencia (PostgreSQL)** | `PeoplePortal-BackEnd/src/PeoplePortal.Infrastructure/Data/Migrations/`<br>`k8s/postgres.yaml` | Base de datos relacional con migraciones automáticas versionadas vía Entity Framework Core. |
| **Arquitectura de Eventos (EDD)** | `PeoplePortal-BackEnd/k8s/nats.yaml`<br>`PeoplePortal-BackEnd/src/PeoplePortal.Infrastructure/Messaging/` | Bus de eventos usando NATS JetStream para publicación y consumo de mensajes asíncronos. |
| **Kubernetes (Manifiestos)** | `k8s/` (Raíz)<br>`[Submódulos]/k8s/base/` + `k8s/overlays/` | Manifiestos con Kustomize: overlays `develop` (:develop images) y `production` (:main images). Infra global: namespace, secret, keycloak, postgres, nats, apisix. |
| **Seguridad OWASP** | `docs/seguridad.md` | Documentación técnica con el mapeo del cumplimiento del top 10 de OWASP. |
| **Catálogo de Prompts IA** | `docs/prompts/` | Colección estructurada de las interacciones y plantillas utilizadas con IA. |
| **Cobertura de Tests (≥ 60%)** | `tests/` (en Backend y Frontends) | Pruebas unitarias para handlers y componentes. Ejecutadas y validadas en el CI/CD. |

## 2. Entregables Documentales Obligatorios (Sección 8)

| Entregable Documental | Enlace al Archivo |
|---|---|
| **1. Documento de Propuesta (PDF/Word)** | [`docs/propuesta/Brief_Capstone_ForzaTechAcademy_v1.pdf`](./docs/propuesta/Brief_Capstone_ForzaTechAcademy_v1.pdf) |
| **2. README.md Raíz** | [`README.md`](./README.md) |
| **3. Diagrama de Arquitectura (C4)** | [`docs/arquitectura.md`](./docs/arquitectura.md) |
| **4. Diagrama de Flujos (Secuencia)** | [`docs/flujos.md`](./docs/flujos.md) |
| **5. Esquema de Base de Datos (ER)** | [`docs/base-de-datos.md`](./docs/base-de-datos.md) |
| **6. Guía de Despliegue y Runbook** | [`docs/despliegue.md`](./docs/despliegue.md) |
| **7. Seguridad y OWASP** | [`docs/seguridad.md`](./docs/seguridad.md) |
| **8. Matriz de Cumplimiento (Anexo B)** | Al final del archivo [`README.md`](./README.md#matriz-de-cumplimiento-anexo-b) |
| **9. Video Demo (5-8 min)** | ✅ [Ver video demo](./docs/video-demo.md) |
