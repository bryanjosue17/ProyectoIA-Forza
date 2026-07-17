# Prompt — Frontend RRHH (React 19 + Vite + MUI — Panel Administrativo)

## Contexto
SPA React 19, Vite, Material UI v9. Panel administrativo RRHH en puerto 30082.
Auth: **AuthContext personalizado con ROPC** + ProtectedRoute con verificación de roles.
Roles requeridos: `hr` o `admin` (desde JWT tokenParsed.realm_access.roles).
Módulos: Dashboard, Empleados, Documentos, Solicitudes, Comunicados, Beneficios, Nómina, Usuarios, Reportes.

---

## Prompt 1: AuthContext ROPC + ProtectedRoute (Panel RRHH)

```
Genera el sistema de auth del Panel RRHH con ROPC (idéntico al Colaborador pero con
claves sessionStorage 'pp-rrhh-token'/'pp-rrhh-refresh') y un ProtectedRoute:

ProtectedRoute.jsx:
- Usa useAuth() del contexto (NO useKeycloak de @react-keycloak/web)
- Muestra CircularProgress mientras loading=true
- Si !isAuthenticated → <Navigate to="/login">
- Extrae roles de auth.user?.realm_access?.roles
- Si no tiene hr ni admin → <Navigate to="/access-denied">
- Si pasa → renderiza children

AccessDenied.jsx:
- Mensaje explicativo de acceso denegado
- Link al Portal Colaborador (http://localhost:30081)
- Botón cerrar sesión
```

---

## Prompt 2: Layout RRHH con glassmorphism, polling de notificaciones y DiceAvatar

```
Genera Layout.jsx para el Panel RRHH con MUI v9:

1. AppBar glassmorphism (igual que Colaborador: backdropFilter:blur(16px))
2. Icono de notificaciones con badge: hace GET /api/hr/requests cada 60s,
   cuenta las que tienen status='Submitted' o 'InReview', muestra el número en Badge
3. Selector de tema light/dark/system
4. DiceAvatar en el header (seed=email del usuario, size=36) — mismo avatar que en Perfil
5. Drawer lateral con menú: Dashboard, Empleados, Documentos, Solicitudes,
   Comunicados, Beneficios, Nómina, Usuarios, Reportes
6. Ítems activos con borderLeft '4px solid #10B981' y gradiente verde esmeralda
   (diferencia visual respecto al Colaborador que usa azul)
7. Logo "PeoplePortal RRHH" con gradiente verde (#34D399, #10B981)
```

---

## Prompt 3: Gestión de Empleados con creación y keycloakId auto-generado

```
Genera Employees.jsx para el Panel RRHH:

1. Tabla paginada con columnas: Código, Nombre, Email, Departamento, Cargo,
   Tipo Contrato, Chip Estado activo/inactivo
2. Buscador por nombre/departamento/email
3. Botón "Añadir Empleado" → Dialog con formulario:
   - Campos requeridos: code, fullName, email, department, position, hireDate, contractType
   - Campos opcionales: phone, site, emergencyContact
   - SIN campo keycloakId visible — se genera automáticamente con crypto.randomUUID()
     en el onSubmit antes de llamar POST /api/hr/employees
   - useFormik + Yup, contractType Select (Indefinido/Temporal/Prácticas/Freelance)
4. Click en fila → /employees/{id} (detalle)
5. toast.success tras crear, toast.error si falla
```

---

## Prompt 4: Aprobación de Solicitudes RRHH

```
Genera Requests.jsx (Panel RRHH) para gestión de solicitudes:

1. Filtros: por tipo (Vacation/Certificate/Voucher) y estado (Submitted/InReview/...)
2. Tabla con: Empleado (nombre), Tipo (label español), Estado (Chip), Fecha, Acciones
3. Acciones en fila para Submitted/InReview: botones inline "Aprobar" y "Rechazar"
   → PATCH /api/hr/requests/{id}/status con { status: 'Approved'|'Rejected' }
4. Click en fila → Dialog de detalle con campo hrComment (opcional) y botones Aprobar/Rechazar
5. toast.success "Solicitud aprobada/rechazada exitosamente"
```

---

## Prompt 5: Módulo Nómina RRHH (crear registros + subir archivos)

```
Genera Nomina.jsx para el Panel RRHH:

1. KPI cards: Total registros, Pendientes de archivo, Disponibles para descarga
2. Tabla paginada con filtros (tipo, estado, período)
3. Botón "Nuevo Registro" → Dialog:
   - Autocomplete de empleados (getAllEmployees), label "fullName (code)"
   - Select tipo: ComprobanteDepago/Bonificacion/Adelanto/Aguinaldo/Vacaciones/Otro
   - Select mes (Enero…Diciembre) + TextField año
   - TextField notas (opcional)
   - POST /api/hr/nomina con { employeeId, period: 'Mes Año', nominaType, notes }
4. Para registros con status='Requested': botón "Subir" → Dialog con TextField URL del archivo
   → PATCH /api/hr/nomina/{id}/upload con { fileUrl }
5. Toast success/error en ambas operaciones
```

---

## Prompt 6: Gestión de Usuarios Keycloak

```
Genera UserManagement.jsx para el Panel RRHH:

1. Tabla de usuarios Keycloak: GET /api/hr/users
   Columnas: Avatar (DiceAvatar seed=email), Username, Email, Nombre, Roles (Chips), Estado toggle
2. Botón "Nuevo Usuario" → Dialog "Crear Usuario en Keycloak":
   - Campos: username*, email*, firstName, lastName, tempPassword*, Switch "Habilitado al crear"
   - POST /api/hr/users
3. Para cada usuario:
   - IconButton editar roles → Dialog con checkboxes de roles disponibles
     (GET /api/hr/users/roles, PUT /api/hr/users/{id}/roles)
   - Switch habilitado/deshabilitado → PATCH /api/hr/users/{id}/enabled
   - Botón reset contraseña → Dialog → POST /api/hr/users/{id}/reset-password
4. Toast para cada operación
```

---

## Prompt 7: Reportes con Chart.js y descarga PDF

```
Genera Reports.jsx para el Panel RRHH con gráficas y exportación PDF:

1. Datos: Promise.all de 5 endpoints:
   GET /api/hr/reports/employees/active → Doughnut de estados
   GET /api/hr/reports/requests/by-status → Doughnut de estados de solicitudes
   GET /api/hr/reports/requests/by-type → Bar horizontal de tipos
   GET /api/hr/reports/requests/over-time → Line de solicitudes por mes
   GET /api/hr/reports/documents/pending → número simple

2. Registrar Chart.js con todos los elementos necesarios (ChartJS.register)
3. Usar react-chartjs-2 (Bar, Doughnut, Line)
4. Adaptar colores al tema (useTheme) para que funcione en dark mode

5. Botón "Descargar PDF" usando @react-pdf/renderer (PDFDownloadLink):
   - Documento PDF con tablas de datos (sin gráficas, solo datos tabulares)
   - Usar react-pdf Document/Page/View/Text/StyleSheet

6. Tabla resumen de documentos pendientes por empleado
```

---

## Prompt 1: ProtectedRoute con validación de roles

```
Genera el componente ProtectedRoute.jsx para el Panel RRHH de PeoplePortal que:

1. Verifica si Keycloak está inicializado (keycloak.initialized):
   - Si no está inicializado → mostrar CircularProgress centrado

2. Verifica si el usuario está autenticado (keycloak.authenticated):
   - Si no está autenticado → redirigir al login de Keycloak

3. Recibe una prop "roles" (array de strings) y verifica que el usuario tiene al menos uno:
   - Obtiene roles desde keycloak.tokenParsed?.realm_access?.roles
   - Si no tiene el rol → redirigir a /access-denied

4. Si pasa todas las validaciones → renderiza children

Uso esperado:
<ProtectedRoute roles={['hr', 'admin']}>
  <Dashboard />
</ProtectedRoute>

Archivo: src/components/ProtectedRoute.jsx
```

---

## Prompt 2: Dashboard del Panel RRHH

```
Genera el componente Dashboard.jsx para el Panel RRHH de PeoplePortal con React 19 + MUI:

1. KPI Cards (Grid 4 columnas en desktop, 2 en tablet):
   - Total Empleados Activos (verde, PeopleIcon)
   - Solicitudes Pendientes (naranja, AssignmentIcon)
   - Documentos Cargados (azul, DescriptionIcon)
   - Comunicados Activos (morado, CampaignIcon)
   Con Skeleton mientras cargan

2. Sección de Acciones Rápidas (Botones prominentes):
   - "Gestionar Empleados" → /employees
   - "Revisar Solicitudes" → /requests
   - "Cargar Documento" → /documents (abre modal)
   - "Nuevo Comunicado" → /announcements (abre modal)

3. Tabla de Solicitudes Recientes (últimas 5):
   - Columnas: Empleado, Tipo, Estado (chip), Fecha

4. Datos obtenidos en paralelo con Promise.all desde:
   GET /api/employees, GET /api/requests, GET /api/documents, GET /api/announcements

Archivo: src/pages/Dashboard/Dashboard.jsx
```

---

## Prompt 3: Página de Gestión de Empleados

```
Genera el componente Employees.jsx para el Panel RRHH de PeoplePortal:

1. DataGrid de MUI con columnas:
   - Nombre completo (FirstName + LastName)
   - Email
   - Departamento
   - Puesto/Posición
   - Estado (chip Activo/Inactivo)
   - Fecha de contratación (formato dd/MM/yyyy)
   - Acciones: Ver detalles (IconButton)

2. Barra de herramientas con:
   - Buscador de texto (filtra por nombre o email en tiempo real)
   - Filtro por Departamento (Select)
   - Filtro por Estado (Activo/Inactivo)

3. Paginación server-side (page, pageSize)

4. Al hacer clic en "Ver detalles" → navegar a /employees/:id

5. Datos de: GET /api/employees con query params ?search=&department=&isActive=&page=&pageSize=

Archivo: src/pages/Employees/Employees.jsx
```

---

## Prompt 4: Página de Revisión de Solicitudes RRHH

```
Genera el componente Requests.jsx para el Panel RRHH que permita:

1. DataGrid con columnas:
   - Empleado (nombre)
   - Tipo de solicitud (chip)
   - Estado actual (chip con colores)
   - Comentarios del empleado
   - Fecha de solicitud
   - Acciones: Aprobar / Rechazar (IconButtons, solo si status = Pending)

2. Filtros en la barra superior:
   - Por estado (Todos, Pendientes, Aprobados, Rechazados)
   - Por tipo de solicitud
   - Rango de fechas (DatePicker de MUI)

3. Al hacer clic en Aprobar/Rechazar:
   - Abrir Dialog de confirmación con campo para "Notas del revisor"
   - Al confirmar: PATCH /api/requests/:id/status con body { status, reviewerNotes }
   - Refrescar la tabla tras la acción
   - Mostrar Snackbar de éxito o error

Archivo: src/pages/Requests/Requests.jsx
```

---

## Prompt 5: Gestión de Comunicados

```
Genera el componente Announcements.jsx para el Panel RRHH de PeoplePortal que permita
a los administradores gestionar comunicados internos:

1. Lista de comunicados en Cards con:
   - Título (h6)
   - Tipo (chip: General=azul, Urgent=rojo, Policy=naranja, Event=verde)
   - Estado activo/inactivo
   - Fecha de publicación y expiración
   - Botón Editar y Desactivar

2. FAB (Floating Action Button) para crear nuevo comunicado que abre Dialog con:
   - TextField: Título (requerido, max 200 chars)
   - Select: Tipo (General, Urgent, Policy, Event)
   - TextField multiline: Contenido (requerido, max 5000 chars)
   - DatePicker: Fecha de expiración (opcional)
   - Botones: Cancelar / Publicar

3. Al publicar: POST /api/announcements
4. Al desactivar: PATCH /api/announcements/:id (toggle IsActive)
5. Ordenar por fecha de publicación descendente

Archivo: src/pages/Announcements/Announcements.jsx
```
