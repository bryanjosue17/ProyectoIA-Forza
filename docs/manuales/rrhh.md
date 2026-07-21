# Manual Técnico — Portal RRHH (Administración)

## Arquitectura del Sistema

```
  Usuario (Browser)
       │
       ▼
  ┌─────────────────────────────┐      ┌─────────────────┐
  │  Frontend React + MUI       │─────▶│  API ASP.NET     │
  │  Puerto :30082              │◀─────│  Puerto :30099   │
  │  PeoplePortal-FrontEnd-RRHH │      └────────┬────────┘
  └─────────────────────────────┘               │
                                                ▼
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

---

## Flujo de Navegación

### 1. Inicio de Sesión

El usuario administrador accede al portal y es redirigido a Keycloak para autenticarse con sus credenciales corporativas. Tras la autenticación exitosa, se presenta el Dashboard principal con acceso a todos los módulos de administración.

![](screenshots/01-dashboard.png)

---

### 2. Gestión de Perfil Administrativo

**Módulo:** Mi Perfil

El administrador de RRHH puede visualizar su información de cuenta, consultar sus roles asignados en el sistema (SSO Keycloak) y actualizar su información de contacto (teléfono, sede física y contacto en caso de emergencia).

| Formulario en edición | Perfil actualizado |
|---|---|
| ![](screenshots/02-perfil-form.png) | ![](screenshots/02-perfil.png) |

**API:** `GET /api/employees/me` / `PUT /api/employees/me`

---

### 3. Gestión de Empleados

**Módulo:** Empleados

El administrador puede crear un nuevo empleado llenando un formulario con sus datos personales y laborales. El campo `Keycloak ID` se genera automáticamente mediante `crypto.randomUUID()` al guardar, por lo que no es necesario que el administrador lo ingrese.

**Campos del formulario:**

| Campo | Requerido | Descripción |
|---|---|---|
| Código | ✅ | Identificador único del empleado |
| Nombre Completo | ✅ | Nombre del empleado |
| Email | ✅ | Correo electrónico corporativo |
| Departamento | ✅ | Área de trabajo |
| Puesto | ✅ | Cargo dentro de la organización |
| Fecha de Contratación | ✅ | Fecha de inicio |
| Tipo de Contrato | ✅ | Indefinido, Temporal, Prácticas, Freelance |
| Teléfono | — | Número de contacto |
| Sitio | — | Ubicación física |
| Contacto de Emergencia | — | Persona a contactar |

| Formulario de creación lleno | Confirmación de creación |
|---|---|
| ![](screenshots/03-empleados-form.png) | ![](screenshots/03-empleados.png) |

**API:** `POST /api/hr/employees`

---

### 4. Gestión de Documentos

**Módulo:** Documentos

El administrador puede subir documentos y asignarlos a un empleado específico. El formulario permite seleccionar el empleado, ingresar el nombre del documento, el tipo y la URL del archivo.

| Formulario de carga lleno | Confirmación de carga |
|---|---|
| ![](screenshots/04-documentos-form.png) | ![](screenshots/04-documentos.png) |

**API:** `POST /api/hr/documents`

---

### 5. Aprobación de Solicitudes

**Módulo:** Solicitudes

El administrador puede filtrar las solicitudes de los empleados por tipo (Vacaciones, Permisos, etc.) y aprobarlas o rechazarlas directamente desde la lista.

| Lista con filtro aplicado | Solicitud aprobada |
|---|---|
| ![](screenshots/05-solicitudes-form.png) | ![](screenshots/05-solicitudes.png) |

**API:** `PATCH /api/hr/requests/{id}/status`

---

### 6. Gestión de Comunicados

**Módulo:** Comunicados

El administrador puede crear comunicados internos con título, tipo, fecha de expiración y cuerpo del mensaje. Los comunicados activos son visibles para todos los colaboradores.

| Formulario de creación lleno | Confirmación de creación |
|---|---|
| ![](screenshots/06-comunicados-form.png) | ![](screenshots/06-comunicados.png) |

**API:** `POST /api/hr/announcements`

---

### 7. Gestión de Beneficios

**Módulo:** Beneficios

El administrador puede registrar beneficios corporativos (Salud, Educación, Bienestar, etc.) que los colaboradores podrán canjear posteriormente.

| Formulario de creación lleno | Confirmación de creación |
|---|---|
| ![](screenshots/07-beneficios-form.png) | ![](screenshots/07-beneficios.png) |

**API:** `POST /api/hr/benefits`

---

### 8. Gestión de Nómina

**Módulo:** Nómina

El administrador puede crear registros de nómina seleccionando el empleado, el tipo de comprobante, el período (mes/año) y agregando notas.

| Formulario de registro lleno | Confirmación de creación |
|---|---|
| ![](screenshots/08-nomina-form.png) | ![](screenshots/08-nomina.png) |

**API:** `POST /api/hr/nomina`

---

### 9. Gestión de Usuarios del Sistema

**Módulo:** Usuarios

El administrador puede crear cuentas de usuario para que los empleados accedan al sistema. Las cuentas se crean con credenciales temporales.

| Formulario de creación lleno | Confirmación de creación |
|---|---|
| ![](screenshots/09-usuarios-form.png) | ![](screenshots/09-usuarios.png) |

**API:** `POST /api/hr/users`

---

### 10. Reportes Gerenciales y Estadísticas

**Módulo:** Reportes

Panel de reportes con métricas en tiempo real: distribución de empleados por estado, solicitudes por estado y tipo, evolución mensual de solicitudes, documentos pendientes. Permite descarga en PDF.

![](screenshots/10-reportes.png)

**APIs:**
- `GET /api/hr/reports/employees/active`
- `GET /api/hr/reports/documents/pending`
- `GET /api/hr/reports/requests/by-status`
- `GET /api/hr/reports/requests/by-type`
- `GET /api/hr/reports/requests/over-time`

---

### 11. Dashboard Final

Vista resumen del sistema con acceso consolidado y estado verificado.

![](screenshots/11-dashboard-final.png)

---

## Resumen de Endpoints de la API

| Método | Endpoint | Módulo | Propósito |
|---|---|---|---|
| `GET` | `/api/employees/me` | Perfil | Cargar datos del perfil |
| `PUT` | `/api/employees/me` | Perfil | Actualizar datos del perfil |
| `POST` | `/api/hr/employees` | Empleados | Crear un empleado |
| `POST` | `/api/hr/documents` | Documentos | Subir un documento |
| `PATCH` | `/api/hr/requests/{id}/status` | Solicitudes | Aprobar o rechazar una solicitud |
| `POST` | `/api/hr/announcements` | Comunicados | Crear un comunicado |
| `POST` | `/api/hr/benefits` | Beneficios | Crear un beneficio |
| `POST` | `/api/hr/nomina` | Nómina | Crear un registro de nómina |
| `POST` | `/api/hr/users` | Usuarios | Crear un usuario del sistema |
| `GET` | `/api/hr/reports/*` | Reportes | Obtener métricas y estadísticas |

---

## Pruebas Automatizadas E2E

### Resultado de la última ejecución

| Test | Resultado | Duración | Fecha |
|---|---|---|---|
| Portal RRHH — Full Flows (POM based) | ✅ 1 passed | 1m 12s | 2026-07-17 |

**Comando de ejecución:**
```bash
npx playwright test e2e-tests/full-flows.spec.js --headed
```

### Flujos cubiertos por los tests E2E

| Paso | Módulo | Acción | Endpoint verificado |
|---|---|---|---|
| 1 | Login | Autenticación con Keycloak (`admin` / `admin123`) | — |
| 2 | Perfil | Editar teléfono, sede, contacto → Guardar | `PUT /api/employees/me` |
| 3 | Empleados | Crear empleado con todos los campos (keycloakId auto-generado) | `POST /api/hr/employees` |
| 4 | Documentos | Buscar + Subir documento (empleado, nombre, tipo, URL) | `POST /api/hr/documents` |
| 5 | Solicitudes | Filtrar por tipo + Aprobar solicitud pendiente | `PATCH /api/hr/requests/{id}/status` |
| 6 | Comunicados | Crear comunicado (título, tipo HR, expiración, cuerpo) | `POST /api/hr/announcements` |
| 7 | Beneficios | Crear beneficio (nombre, tipo Salud, descripción) | `POST /api/hr/benefits` |
| 8 | Nómina | Crear registro (empleado, tipo, mes Junio, año 2026) | `POST /api/hr/nomina` |
| 9 | Usuarios | Crear usuario Keycloak (username, email, nombre, apellido, contraseña) | `POST /api/hr/users` |
| 10 | Reportes | Verificar carga de gráficas y tablas | `GET /api/hr/reports/*` |
| 11 | Dashboard | Navegar al dashboard final | — |

---

## Troubleshooting

| Síntoma | Causa | Solución |
|---|---|---|
| Error 401 al cargar datos | Token de sesión expirado | Cerrar sesión y volver a iniciar |
| Error 500 en usuarios | Keycloak no disponible | Contactar al administrador del sistema |
| Selectores sin opciones | Error de carga de datos | Recargar la página |
