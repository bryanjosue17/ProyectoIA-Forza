# Flujos del Sistema — PeoplePortal

## Flujo 1: Colaborador solicita vacaciones

```mermaid
sequenceDiagram
    participant C as Colaborador (React)
    participant A as APISIX Gateway
    participant API as PeoplePortal API
    participant DB as PostgreSQL
    participant N as NATS JetStream

    C->>A: POST /api/requests/vacation (JWT Bearer)
    A->>A: Validar token con Keycloak
    A->>API: Reenviar request
    API->>API: Validar FluentValidation
    API->>DB: Guardar HrRequest (status: Submitted)
    API->>N: Publish "hr.request.submitted"
    N-->>API: ack
    API->>A: 201 Created (HrRequestDto)
    A->>C: Response
```

---

## Flujo 2: Jefe inmediato aprueba solicitud

```mermaid
sequenceDiagram
    participant J as Jefe Inmediato
    participant A as APISIX Gateway
    participant API as PeoplePortal API
    participant DB as PostgreSQL
    participant N as NATS JetStream

    J->>A: PATCH /api/manager/requests/{id}/status (JWT)
    A->>A: Validar token + ManagerPolicy
    A->>API: Reenviar request
    API->>DB: Actualizar status (Approved / Rejected)
    API->>N: Publish "hr.request.approved"
    N-->>API: ack
    API->>A: 200 OK
    A->>J: Response
```

---

## Flujo 3: RRHH sube documento a expediente

```mermaid
sequenceDiagram
    participant H as RRHH
    participant A as APISIX Gateway
    participant API as PeoplePortal API
    participant DB as PostgreSQL

    H->>A: POST /api/hr/documents (JWT + archivo)
    A->>A: Validar token + HrPolicy
    A->>API: Reenviar request
    API->>DB: Guardar Document (status: Available)
    API->>A: 201 Created (DocumentDto)
    A->>H: Response
```

---

## Flujo 4: Colaborador consulta su Dashboard

```mermaid
sequenceDiagram
    participant C as Colaborador
    participant A as APISIX Gateway
    participant API as PeoplePortal API
    participant DB as PostgreSQL

    C->>A: GET /api/dashboard (JWT)
    A->>A: Validar token + EmployeePolicy
    A->>API: Reenviar request
    API->>DB: GetMyProfile (employees)
    API->>DB: GetMyRequests (hr_requests)
    API->>DB: GetMyDocuments (documents)
    API->>DB: GetAnnouncements (announcements)
    API->>DB: GetActiveBenefits (benefits)
    API->>A: DashboardDto (agregado)
    A->>C: Response
```

---

## Flujo 5: Evento NATS — Consumer Service

```mermaid
sequenceDiagram
    participant API as PeoplePortal API
    participant NATS as NATS JetStream
    participant CS as EventConsumerService
    participant LOG as ILogger

    API->>NATS: Publish("hr.request.submitted", payload)
    NATS->>CS: Deliver message (subject: hr.request.submitted)
    CS->>LOG: Log evento recibido
    CS->>NATS: Ack mensaje
    Note over NATS: Stream "peopleportal-events"<br/>Subjects: hr.request.submitted,<br/>hr.request.approved, employee.*
```
