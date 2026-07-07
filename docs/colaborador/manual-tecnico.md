# Manual Técnico — Portal Colaborador (Empleados)

## Arquitectura del Sistema

```
  Usuario (Browser)
       │
       ▼
  ┌─────────────────────────────┐      ┌─────────────────┐
  │  Frontend React + MUI       │─────▶│  API ASP.NET     │
  │  Puerto :30081              │◀─────│  Puerto :30099   │
  │  PeoplePortal-FrontEnd-     │      └─────────────────┘
  │    Colaborador              │              │
  └─────────────────────────────┘              ▼
                                        ┌─────────────────┐
                                        │  SQL Server      │
                                        └─────────────────┘
                                                │
                                                ▼
                                        ┌─────────────────┐
                                        │  Keycloak Auth   │
                                        │  Puerto :30080   │
                                        └─────────────────┘
```

**Diferencia con el Portal RRHH:** El Portal Colaborador está orientado al empleado individual. Cada usuario solo puede ver y editar su propia información y crear solicitudes. No tiene acceso a la administración de otros empleados.

---

## Flujo de Navegación

### 1. Inicio de Sesión

El colaborador accede al portal y es redirigido a Keycloak para autenticarse. Tras la autenticación exitosa, se presenta el Dashboard con los módulos disponibles.

![](screenshots/01-dashboard.png)

---

### 2. Perfil

**Módulo:** Mi Perfil

El colaborador puede editar su información de contacto: teléfono, ubicación, contacto de emergencia y teléfono de emergencia.

| Formulario de edición lleno | Confirmación de actualización |
|---|---|
| ![](screenshots/02-perfil-form.png) | ![](screenshots/02-perfil.png) |

**API:** `PUT /api/employees/me`

---

### 3. Documentos Personales

**Módulo:** Documentos

El colaborador puede consultar los documentos que la administración ha subido a su expediente (contratos, constancias, etc.). La vista incluye un buscador para filtrar por nombre.

![](screenshots/03-documentos.png)

**API:** `GET /api/documents/me`

---

### 4. Solicitudes

**Módulo:** Mis Solicitudes

El colaborador puede crear solicitudes desde dos tabs:

**4.1 Solicitud de Vacaciones**

Selecciona fechas de inicio y fin, y agrega un motivo. La solicitud queda pendiente de aprobación por RRHH.

![](screenshots/04-solicitudes-vac-form.png)

**API:** `POST /api/requests/vacation`

**4.2 Solicitud de Constancia**

Selecciona el tipo de constancia (Trabajo, Salarial, etc.) y agrega un motivo.

![](screenshots/04-solicitudes-const-form.png)

**API:** `POST /api/requests/certificate`

| Confirmación de solicitud creada |
|---|
| ![](screenshots/04-solicitudes.png) |

---

### 5. Solicitudes del Equipo

**Módulo:** Mi Equipo *(solo disponible para usuarios con rol de manager)*

El manager puede ver las solicitudes pendientes de los miembros de su equipo.

![](screenshots/05-mi-equipo.png)

**API:** `GET /api/team/requests`

---

### 6. Comunicados

**Módulo:** Comunicados

El colaborador puede leer los comunicados internos publicados por la administración.

![](screenshots/06-comunicados.png)

**API:** `GET /api/announcements`

---

### 7. Beneficios

**Módulo:** Beneficios

El colaborador puede ver los beneficios disponibles y canjearlos.

![](screenshots/07-beneficios.png)

**API:** `POST /api/benefits/redeem`

---

### 8. Nómina

**Módulo:** Nómina

El colaborador puede consultar sus recibos de nómina.

![](screenshots/08-nomina.png)

**API:** `GET /api/payroll/me`

---

### 9. Dashboard

Vista resumen con acceso a todos los módulos disponibles.

![](screenshots/09-dashboard-final.png)

---

## Resumen de Endpoints de la API

| Método | Endpoint | Módulo | Propósito |
|---|---|---|---|
| `PUT` | `/api/employees/me` | Perfil | Actualizar datos del perfil |
| `GET` | `/api/documents/me` | Documentos | Listar documentos personales |
| `POST` | `/api/requests/vacation` | Solicitudes | Crear solicitud de vacaciones |
| `POST` | `/api/requests/certificate` | Solicitudes | Crear solicitud de constancia |
| `GET` | `/api/team/requests` | Mi Equipo | Ver solicitudes del equipo |
| `GET` | `/api/announcements` | Comunicados | Listar comunicados |
| `POST` | `/api/benefits/redeem` | Beneficios | Canjear un beneficio |
| `GET` | `/api/payroll/me` | Nómina | Ver recibos de nómina |

---

## Troubleshooting

| Síntoma | Causa | Solución |
|---|---|---|
| Error 401 al cargar datos | Token de sesión expirado | Cerrar sesión y volver a iniciar |
| Error 500 al obtener datos | Keycloak no disponible | Contactar al administrador del sistema |
| No aparecen documentos | Solo se muestran documentos asignados al usuario | Contactar a RRHH para que asigne el documento |
