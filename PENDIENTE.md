# PeoplePortal -- Checklist de Pendientes (actualizado 2026-06-30)

> Este archivo refleja el estado real del proyecto tras analisis profundo carpeta por carpeta.

---

## COMPLETADOS

| # | Tarea | Evidencia |
|---|-------|-----------|
| 1 | Seed data: 4 empleados en K8s | BD `PeoplePortalDb` con testuser, testmanager, testhr, admin |
| 2 | Eventos NATS verificados | Stream `peopleportal-events` con `hr.request.submitted` |
| 3 | Branch protection en los 3 submodulos | BackEnd, FrontEnd-Colaborador, FrontEnd-RRHH protegidos |
| 4 | APISIX client_secret configurado | `k8s/apisix-configmap.yaml` actualizado |
| 5 | `.editorconfig` creado | `PeoplePortal-BackEnd/.editorconfig` estandar Forza |
| 6 | `CHANGELOG.md` iniciado | `PeoplePortal-BackEnd/CHANGELOG.md` v0.2.0 y v0.2.1 |
| 7 | CI/CD pipeline verde | `PeoplePortal-BackEnd/.github/workflows/ci.yml` build+test+Trivy+Docker push GHCR |
| 8 | CI frontend activo | `PeoplePortal-FrontEnd-Colaborador` y `RRHH` con ci.yml |
| 9 | NATS JetStream integrado | `Infrastructure/Messaging/NatsEventBus.cs` + `EventConsumerService.cs` |
| 10 | FluentValidation | 5+ validadores + ValidationBehavior pipeline |
| 11 | Documentacion viva /docs | Arquitectura C4, flujos sequence, ER, despliegue, OWASP con Mermaid |
| 12 | Catalogo de prompts | `PeoplePortal-BackEnd/docs/prompts/` 6 prompts en 3 categorias |
| 13 | OWASP Top 10 mapeado | `PeoplePortal-BackEnd/docs/seguridad.md` |
| 14 | Manifiestos Kubernetes completos | `k8s/` global + `*/k8s/` por subproyecto |
| 15 | Despliegue K8s funcionando | Todos los pods Running en namespace `peopleportal` |
| 16 | 49 tests backend verdes | 44 unitarios + 5 integracion -- 0 failures |
| 17 | 37 tests frontend verdes | 19 Colaborador + 18 RRHH -- 0 failures |
| 18 | Todos los modulos del MVP implementados | Perfil, Docs, Comunicados, Beneficios, Dashboard, Solicitudes, Panel RRHH, Reportes |
| 19 | APISIX como unico punto de entrada | `k8s/apisix-configmap.yaml` con rutas y plugin openid-connect |
| 20 | Desviacion Angular->React documentada | Nota en `README.md` raiz -- aprobada por el lider |

---

## PENDIENTES CRITICOS

### 1. Cobertura de tests >= 60% -- ALTA PRIORIDAD

**Estado actual:** 4% linea / 6.6% rama
(medido con coverlet: `dotnet test --collect:"XPlat Code Coverage"`)

**Causa:** Los tests cubren entidades de dominio (factories, validaciones), pero los handlers
de Application (Commands/Queries) no tienen tests. La capa Application es donde esta la mayor
cantidad de codigo.

**Handlers sin tests (prioridad):**
- `CreateVacationRequestCommandHandler`
- `CreateCertificateRequestCommandHandler`
- `GetMyRequestsQueryHandler`
- `CreateEmployeeCommandHandler` / `UpdateMyProfileCommandHandler`
- `UploadDocumentCommandHandler` / `UpdateDocumentStatusCommandHandler`
- `GetDashboardQueryHandler`
- Handlers de Reports

**Objetivo:** ~30 tests de Application con NSubstitute (mocks de repositorios) para llegar al 60%.

---

### 2. Video demo 5-8 min -- ALTA PRIORIDAD

**Estado:** No grabado

**Guion sugerido (6 min):**
1. `kubectl get pods -n peopleportal` -- 7 pods OK (30s)
2. Keycloak Admin: realm `peopleportal`, clients, roles, usuarios (1 min)
3. Frontend Colaborador: login testuser/test123 en http://localhost:30081, dashboard, crear solicitud (2 min)
4. Frontend RRHH: login testhr/test123 en http://localhost:30082, panel, aprobar/rechazar (1 min)
5. API Swagger o llamada directa a `/api/dashboard` con token JWT (1 min)
6. Cierre: Clean Architecture, CQRS, NATS, K8s, 86 tests totales (30s)

Herramientas: OBS Studio (gratis), Loom, Clipchamp.

---

### 3. Repositorio privado en organizacion Forza -- MEDIA

**Estado:** Repos estan en `bryanjosue17` (cuenta personal), no en una organizacion Forza.

**Opciones:**
- Crear organizacion `ForzaTechAcademy` (o nombre acordado) en GitHub
- Transferir los 4 repos: ProyectoIA-Forza, PeoplePortal-BackEnd, PeoplePortal-FrontEnd-Colaborador, PeoplePortal-FrontEnd-RRHH
- O cambiar visibilidad a privado: GitHub Settings -> General -> Change visibility

---

### 4. Typo en package.json FrontEnd-Colaborador -- BAJA (CORREGIDO)

**Estado:** CORREGIDO -- `"name": "frontend-colaborador"` (antes: "frontend-coloborador")

---

### 5. Codacy -- issues criticos/altos en 0 -- MEDIA

**Estado:** No verificado localmente. El CI sube cobertura cuando `CODACY_PROJECT_TOKEN`
esta configurado como secret del repo.

**Accion:** Revisar https://app.codacy.com -- verificar que no haya issues CRITICAL o HIGH sin resolver.

---

## RESUMEN DE ESTADO

Backend (.NET 9)
- Entidades:        Employee, HrRequest, Document, Voucher, Announcement, Benefit  [OK]
- Repositorios:     6 interfaces + 6 implementaciones                               [OK]
- Handlers CQRS:    ~40 handlers en Application                                     [OK]
- Controllers:      11 controllers                                                  [OK]
- Migrations EF:    2 migraciones (InitialCreate + AddEmployeeDocuments)            [OK]
- NATS JetStream:   NatsEventBus + EventConsumerService                             [OK]
- Auth Keycloak:    JWT Bearer + 5 policies                                         [OK]
- Tests:            44 unit + 5 integracion = 49 total (0 failures)                 [OK]
- Coverage:         4% linea -- META: >=60%                                         [FALTA]
- CI/CD:            build+test+Trivy+Docker push GHCR                               [OK]
- K8s:              api, sqlserver, nats, configmap, migration-job                  [OK]

Frontend Colaborador (React 19)
- Paginas:          Dashboard, Perfil, Documentos, Comunicados, Beneficios, Solicitudes  [OK]
- Auth Keycloak:    PKCE S256                                                            [OK]
- Tests:            19 tests (4 archivos, 0 failures)                                   [OK]
- K8s:              frontend-colaborador.yaml                                           [OK]

Frontend RRHH (React 19)
- Paginas:          Dashboard, Empleados, Detalle, Documentos, Solicitudes, Comunicados, Beneficios, Reportes, AccessDenied  [OK]
- Auth Keycloak:    PKCE S256                                                                                                [OK]
- Tests:            18 tests (4 archivos, 0 failures)                                                                       [OK]
- K8s:              frontend-rrhh.yaml                                                                                      [OK]

Infraestructura Global
- K8s global:       namespace, secret, keycloak, keycloak-realm-configmap, apisix, apisix-configmap, ingress  [OK]
- Docker Compose:   api, api-migrations, frontend-colaborador, frontend-rrhh                                  [OK]
- Deploy scripts:   deploy.ps1 + build.ps1 + deploy.sh                                                        [OK]
- Docs globales:    docs/README.md (C4+tests+deploy+auth+ER), arquitectura.md, despliegue.md                  [OK]

---

## REQUISITOS DEL BRIEF -- ESTADO FINAL

| Requisito | Estado |
|-----------|--------|
| Pipeline CI/CD verde (build+test+Codacy+Trivy) | OK - 3 repos con ci.yml activo |
| Cobertura de tests >= 60% | FALTA - 4% actual, meta pendiente |
| Autenticacion Keycloak con PKCE | OK - JWT Bearer + PKCE S256 en frontends |
| Backend .NET con Clean Architecture y CQRS | OK - 4 capas + MediatR + 11 controllers |
| Frontends con SSO funcional | OK - 2 apps React 19 con Keycloak-js |
| SQL Server con migrations versionadas | OK - 2 migraciones EF Core 9 |
| NATS JetStream integrado | OK - hr.request.submitted + hr.request.approved |
| Documentacion viva con Mermaid | OK - C4, sequence, ER, pipeline, arquitectura |
| Catalogo de prompts en /docs/prompts/ | OK - 6 prompts (arquitectura, codigo, tests) |
| OWASP Top 10 mapeado | OK - PeoplePortal-BackEnd/docs/seguridad.md |
| Manifiestos Kubernetes | OK - Todos los servicios desplegados y running |
| Repositorio privado en organizacion Forza | FALTA - repos en bryanjosue17, no en org |
| Branch protection en develop | OK - Activada en los 3 submodulos |
| Video demo 5-8 min | FALTA - pendiente de grabar |
| Desviacion Angular->React documentada | OK - Nota en README raiz + Anexo B |