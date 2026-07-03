# Base de Datos — PeoplePortal

PostgreSQL 16 con Entity Framework Core 9. Naming convention: `snake_case`.

## Diagrama ER

```mermaid
erDiagram
    employees {
        guid id PK
        string keycloak_id UK
        string code UK
        string full_name
        string email
        string phone
        string department
        string position
        date hire_date
        string contract_type
        string status
        string emergency_contact
        string site
        string manager_id
        datetime created_at_utc
        datetime updated_at_utc
    }

    hr_requests {
        guid id PK
        string employee_id FK
        string type
        string status
        date vacation_start_date
        date vacation_end_date
        string certificate_type
        string period
        string reason
        string hr_comment
        string reviewed_by
        datetime created_at_utc
        datetime updated_at_utc
    }

    documents {
        guid id PK
        string employee_id FK
        string name
        string type
        string status
        string file_url
        date expires_at
        datetime uploaded_at
        string reviewed_by
    }

    vouchers {
        guid id PK
        string employee_id FK
        string period
        string status
        string file_url
        string reason
        datetime requested_at
        datetime updated_at_utc
    }

    announcements {
        guid id PK
        string title
        string body
        string type
        datetime published_at
        datetime expires_at
        string created_by
        boolean is_active
    }

    benefits {
        guid id PK
        string name
        string description
        string type
        boolean is_active
    }

    employees ||--o{ hr_requests : "employee_id"
    employees ||--o{ documents : "employee_id"
    employees ||--o{ vouchers : "employee_id"
```

---

## Tablas y descripción

| Tabla | Descripción |
|---|---|
| `employees` | Colaboradores registrados en el sistema |
| `hr_requests` | Solicitudes (vacaciones, constancias, vouchers, permisos) |
| `documents` | Documentos del expediente digital del colaborador |
| `vouchers` | Vouchers de pago solicitados/cargados por nómina |
| `announcements` | Comunicados internos publicados por RRHH |
| `benefits` | Catálogo de beneficios de la empresa |

---

## Convenciones

| Convención | Ejemplo |
|---|---|
| Tablas en snake_case plural | `hr_requests` |
| Columnas en snake_case | `employee_id`, `created_at_utc` |
| Primary keys | `id` (GUID) |
| Foreign keys | `{tabla_singular}_id` |
| Índices | `ix_{tabla}_{columna}` |
| Timestamps en UTC | `created_at_utc`, `updated_at_utc` |

---

## Migraciones EF Core

```bash
# Aplicar migraciones (docker-compose)
docker-compose run --rm migrate

# Aplicar migraciones (K8s)
kubectl apply -f k8s/migration-job.yaml
kubectl wait --for=condition=complete job/peopleportal-migrations \
  -n peopleportal --timeout=180s
```

Las migraciones se encuentran en `src/PeoplePortal.Infrastructure/Persistence/Migrations/`.
