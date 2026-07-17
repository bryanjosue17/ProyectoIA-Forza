# Catálogo de Prompts — PeoplePortal

Este directorio contiene los prompts utilizados durante el desarrollo de PeoplePortal.
Cada archivo documenta el contexto, los prompts usados y el resultado esperado.

## Estructura

```
prompts/
├── README.md
├── arquitectura/
│   ├── diagrama-c4.md              — Diagrama C4 del sistema
│   └── diseno-entidades.md         — Diseño de entidades de dominio
├── backend/
│   └── cqrs-handlers.md            — Handlers CQRS con MediatR
├── base-de-datos/
│   └── schema-y-seed.md            — Schema PostgreSQL y datos semilla
├── ci-cd/
│   └── pipelines.md                — GitHub Actions: build/test/GHCR push
├── codigo/
│   ├── consumer-nats.md            — Consumer NATS JetStream
│   ├── pipeline-github-actions.md  — Pipeline CI completo
│   └── scaffolding-handler-cqrs.md — Scaffolding de handlers
├── docker/
│   └── dockerfiles.md              — Dockerfiles multi-stage + docker-compose
├── frontend-colaborador/
│   └── paginas-y-componentes.md    — AuthContext ROPC, Layout, módulos (Nómina, Mi Equipo, etc.)
├── frontend-rrhh/
│   └── paginas-y-componentes.md    — AuthContext ROPC, Layout, Empleados, Nómina, Usuarios, Reportes
├── kubernetes/
│   ├── manifiestos.md              — Manifiestos K8s base (namespace, postgres, keycloak, etc.)
│   └── kustomize.md                — Kustomize overlays develop/production
├── seguridad/
│   └── owasp.md                    — Mapeo OWASP Top 10
└── tests/
    ├── pruebas.md                  — Tests unitarios backend + frontend (con AuthContext mock)
    ├── unit-tests-handler.md       — Tests de handlers CQRS específicos
    └── e2e-playwright.md           — Tests E2E con Playwright POM (flujos completos)
```

## Estado del sistema (2026-07-17)

| Componente | Tecnología actual |
|---|---|
| Auth frontend | AuthContext personalizado + ROPC (NO PKCE/ReactKeycloakProvider) |
| Imágenes Docker | GHCR `ghcr.io/bryanjosue17/...` con tags branch y SHA |
| K8s despliegue | Kustomize overlays `overlays/develop/` y `overlays/production/` |
| Tests E2E | Playwright con POM, Microsoft Edge, 9+ pasos por portal |
| Node.js | 20-alpine (Dockerfiles) |

## Reglas de uso
- Nunca enviar datos reales de empleados o financieros a herramientas de IA
- Todo código generado debe revisarse antes de mergear
- Los prompts se guardan con el contexto y resultado obtenido
