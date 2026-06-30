# PeoplePortal — Documentación del Proyecto

## 1. Arquitectura del Sistema (C4 — Diagrama de Contexto)

```mermaid
C4Context
  title System Context diagram — PeoplePortal

  Person(colaborador, "Colaborador", "Empleado que consulta su información y realiza solicitudes")
  Person(rrhh_user, "Usuario RRHH", "Administra colaboradores, documentos, solicitudes y comunicados")

  System_Boundary(peopleportal, "PeoplePortal") {
    System(web_colab, "Frontend Colaborador", "React + Vite + MUI\nPuerto 30081")
    System(web_rrhh, "Frontend RRHH", "React + Vite + MUI\nPuerto 30082")
    System(api, "Backend API", ".NET 9 — Clean Architecture + CQRS\nPuerto 8080")
    SystemDb(sqlserver, "SQL Server", "Base de datos relacional\nPuerto 1433")
    System(nats, "NATS JetStream", "Mensajería asíncrona\nPuerto 4222")
    System(keycloak, "Keycloak", "SSO / OpenID Connect\nPuerto 8080")
    System(apisix, "APISIX Gateway", "API Gateway\nPuerto 30090")
  }

  Rel(colaborador, web_colab, "Navega", "HTTPS")
  Rel(rrhh_user, web_rrhh, "Administra", "HTTPS")
  Rel(web_colab, apisix, "Consume API", "HTTP")
  Rel(web_rrhh, apisix, "Consume API", "HTTP")
  Rel(apisix, api, "Proxy inverso", "HTTP")
  Rel(api, sqlserver, "Lectura/escritura", "TDS")
  Rel(api, nats, "Publica/consume eventos", "NATS")
  Rel(web_colab, keycloak, "Autenticación PKCE", "OIDC")
  Rel(web_rrhh, keycloak, "Autenticación PKCE", "OIDC")
  Rel(api, keycloak, "Validación JWT", "JWKS")

  UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")
```

El sistema se despliega en **Docker Desktop Kubernetes** sobre el namespace `peopleportal`. Los frontends redirigen `/api/` directamente al backend via Nginx. APISIX está disponible como gateway alternativo (`NodePort 30090`). Keycloak provee autenticación SSO con flujo PKCE S256. NATS JetStream maneja eventos de dominio (ej. `hr.request.submitted`) para integración asíncrona.

---

## 2. Pipeline CI/CD

```mermaid
flowchart LR
  A[Push a main] --> B[Checkout]
  B --> C[Lint Backend<br/>dotnet format]
  B --> D[Lint Frontend<br/>oxlint]
  C --> E[Build Backend<br/>dotnet build]
  D --> F[Build Frontend<br/>vite build]
  E --> G[Test Backend<br/>dotnet test + coverage]
  F --> H[Test Frontend<br/>vitest run]
  G --> I{¿Tests OK?}
  H --> I
  I -->|Sí| J[Análisis estático<br/>Codacy + Trivy]
  J --> K[Docker Build<br/>api, migrations, frontends]
  K --> L[Push a GHCR<br/>ghcr.io/peopleportal/*]
  L --> M[Deploy a K8s<br/>kubectl apply]
  I -->|No| N[❌ Falla el pipeline]
```

**Referencias:**
- **GitHub Container Registry (GHCR):** las imágenes se etiquetan y publican como `ghcr.io/peopleportal/api:latest`, etc.
- **Codacy:** análisis de calidad y cobertura de código (`PeoplePortal-BackEnd/.codacy.yml`).
- **Trivy:** escaneo de vulnerabilidades en imágenes Docker.
- **Branch protection:** la rama `main` está protegida; requiere pipeline verde para fusionar.

---

## 3. Estrategia de Pruebas

```mermaid
mindmap
  root((PeoplePortal Tests))
    Backend (49 tests)
      Domain (25 tests)
        EmployeeTests[5 tests<br/>Creación, validación, actualización]
        HrRequestTests[8 tests<br/>Vacaciones, constancias, vouchers, cancelación]
        DocumentTests[5 tests<br/>Creación, carga, cambio de estado]
        VoucherTests[3 tests<br/>Solicitud, carga, estados finales]
        AnnouncementTests[2 tests<br/>Creación, desactivación]
        BenefitTests[2 tests<br/>Creación, desactivación]
      Application (12 tests)
        EmployeeHandlerTests[3 tests<br/>CreateEmployee, UpdateMyProfile]
        DocumentHandlerTests[4 tests<br/>UploadDocument, UpdateStatus]
        RequestHandlersTests[5 tests<br/>Vacation, Certificate, Status, Query]
      Controllers (7 tests)
        AnnouncementHandlerTests[3 tests<br/>Create, GetActive, invalid type]
        BenefitHandlerTests[3 tests<br/>GetActive, empty, all fields]
      Integration (5 tests)
        BasicTests[5 tests<br/>Entity creation, enums, status]
    Frontend Colaborador (19 tests)
      Dashboard.test[5 tests<br/>Welcome, API fail, stat cards, values, empty state]
      Layout.test[6 tests<br/>Title, subtitle, nav items, user, children, active route]
      keycloak.test[3 tests<br/>URL config, defaults, realm/clientId]
      client.test[5 tests<br/>baseURL, headers, token interceptor]
    Frontend RRHH (18 tests)
      Dashboard.test[4 tests<br/>Welcome, summary cards, values, quick actions]
      Layout.test[6 tests<br/>Title, subtitle, nav items, user, children, active route]
      keycloak.test[3 tests<br/>URL config, defaults, realm/clientId]
      client.test[5 tests<br/>baseURL, headers, token interceptor]
```

**Stack de testing:**
| Capa | Framework | Assertions | Mocks |
|------|-----------|------------|-------|
| Backend Domain | xUnit | FluentAssertions | — |
| Backend Application | xUnit | FluentAssertions | NSubstitute |
| Frontend | Vitest | Testing Library + jest-dom | MSW + vi.mock |
| Cobertura | coverlet | — | — |

---

## 4. Proceso de Despliegue

```mermaid
sequenceDiagram
  participant Dev as Desarrollador
  participant Docker as Docker Compose
  participant K8s as Kubernetes
  participant Svcs as Servicios

  Dev ->> Docker: docker compose build
  Docker ->> Docker: api, migrations, frontend-colaborador, frontend-rrhh

  Dev ->> K8s: deploy.ps1 / deploy.sh

  K8s ->> Svcs: Fase 1 — Infraestructura
  Svcs ->> Svcs: namespace.yaml, configmap, secret
  Svcs ->> Svcs: sqlserver.yaml, nats.yaml, keycloak.yaml
  Svcs ->> Svcs: Wait pods ready (SQL, Keycloak)

  K8s ->> Svcs: Fase 2 — Migraciones
  Svcs ->> Svcs: migration-job.yaml
  Svcs ->> Svcs: Wait job complete

  K8s ->> Svcs: Fase 3 — Aplicación
  Svcs ->> Svcs: api.yaml, frontend-colaborador.yaml, frontend-rrhh.yaml, apisix.yaml

  K8s ->> Svcs: Fase 4 — Ingress (opcional)
  Svcs ->> Svcs: ingress.yaml

  Dev -->> Dev: Servicios disponibles:
  Note right of Dev: Colaborador: http://localhost:30081
  Note right of Dev: RRHH:        http://localhost:30082
  Note right of Dev: Keycloak:    http://localhost:30080
  Note right of Dev: APISIX:      http://localhost:30090
```

**Puertos NodePort expuestos:**

| Servicio | Puerto |
|----------|--------|
| Frontend Colaborador | 30081 |
| Frontend RRHH | 30082 |
| Keycloak | 30080 |
| APISIX Gateway | 30090 |

---

## 5. Flujo de Autenticación

```mermaid
sequenceDiagram
  participant User as Usuario
  participant FE as Frontend (React)
  participant KC as Keycloak
  participant API as Backend API (.NET)
  participant DB as SQL Server

  User ->> FE: Accede al portal
  FE ->> KC: Redirección OIDC (PKCE S256)
  KC ->> FE: Código de autorización
  FE ->> KC: Canje por tokens (access + refresh + id)
  KC ->> FE: JWT + roles (employee, jefe_inmediato, hr, nomina, admin)

  FE ->> API: Petición HTTP + Bearer JWT
  API ->> KC: Validación JWKS (issuer signing key)
  API ->> API: Extrae roles de realm_access.roles
  API ->> API: Claims → ClaimTypes.Role
  API ->> API: Autorización por policy

  alt Employee
    API ->> DB: Consulta empleado por KeycloakId
  end

  alt Admin / HR
    API ->> DB: CRUD completo
  end

  API ->> FE: Respuesta JSON
```

**Políticas de autorización** (`Program.cs:109-125`):

| Policy | Rol requerido |
|--------|---------------|
| EmployeePolicy | `employee` |
| ManagerPolicy | `jefe_inmediato` |
| HrPolicy | `hr` |
| NominaPolicy | `nomina` |
| AdminPolicy | `admin` |

Keycloak se configura con:
- **Realm:** `peopleportal`
- **Client ID frontend:** `peopleportal-frontend` (PKCE, S256)
- **Client ID backend:** `peopleportal-api` (confidencial)
- **Audience:** `peopleportal-api`

---

## 6. Diagrama Entidad-Relación

```mermaid
erDiagram
  Employee {
    guid Id PK
    string KeycloakId UK
    string Code UK
    string FullName
    string Email
    string Phone
    string Department
    string Position
    date HireDate
    enum ContractType
    enum Status
    string EmergencyContact
    string Site
    string ManagerId
    datetime CreatedAtUtc
    datetime UpdatedAtUtc
  }

  Document {
    guid Id PK
    string EmployeeId FK
    string Name
    string Type
    enum Status
    string FileUrl
    date ExpiresAt
    datetime UploadedAt
    string ReviewedBy
  }

  Voucher {
    guid Id PK
    string EmployeeId FK
    string Period
    enum Status
    string FileUrl
    string Reason
    datetime RequestedAt
    datetime UpdatedAtUtc
  }

  Announcement {
    guid Id PK
    string Title
    string Body
    enum Type
    datetime PublishedAt
    datetime ExpiresAt
    string CreatedBy
    bool IsActive
  }

  Benefit {
    guid Id PK
    string Name
    string Description
    string Type
    bool IsActive
  }

  HrRequest {
    guid Id PK
    string EmployeeId FK
    enum Type
    enum Status
    date VacationStartDate
    date VacationEndDate
    string CertificateType
    string Period
    string Reason
    string HrComment
    string ReviewedBy
    datetime CreatedAtUtc
    datetime UpdatedAtUtc
  }

  Employee ||--o{ Document : "tiene"
  Employee ||--o{ Voucher : "solicita"
  Employee ||--o{ HrRequest : "realiza"
  Employee ||--o{ Employee : "reporta a (ManagerId)"
```

**Descripción de entidades:** (basado en `PeoplePortal-BackEnd/src/PeoplePortal.Domain/Entities/`)

| Entidad | Propósito | Estados clave |
|---------|-----------|---------------|
| **Employee** | Colaborador registrado en la plataforma. Vinculado a Keycloak via `KeycloakId`. | `Active`, `Inactive`, `OnLeave`, `Terminated` |
| **Document** | Documento digital asociado a un empleado. Pueden ser contratos, constancias, identificaciones, etc. | `Available`, `Pending`, `InReview`, `Approved`, `Rejected`, `Expired` |
| **Voucher** | Comprobante de pago solicitado por el empleado a nómina. | `Requested`, `InProcess`, `AvailableForDownload`, `Rejected`, `Completed` |
| **HrRequest** | Solicitud genérica a RRHH: vacaciones, constancias, vouchers, permisos, actualización de datos. | `Submitted`, `InReview`, `Approved`, `Rejected`, `Cancelled` |
| **Announcement** | Comunicado interno publicado por RRHH. | `IsActive: true/false` |
| **Benefit** | Beneficio informativo disponible para colaboradores. | `IsActive: true/false` |

**Tipos de solicitud (`RequestType`):** Vacation (1), Certificate (2), Voucher (3), Permission (4), DataUpdate (5), Other (6).
