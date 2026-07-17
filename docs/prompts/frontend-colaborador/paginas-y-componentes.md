# Prompt — Frontend Colaborador (React 19 + Vite + MUI)

## Contexto
SPA React 19, Vite, Material UI v9. Portal del empleado en puerto 30081.
Auth: **AuthContext personalizado con ROPC** (formulario de login propio → POST directo al token endpoint de Keycloak). NO usa ReactKeycloakProvider ni redirección PKCE.
Módulos: Dashboard, Perfil, Documentos, Solicitudes, Mi Equipo (managers), Comunicados, Beneficios, Nómina.

---

## Prompt 1: AuthContext con ROPC (Resource Owner Password Credentials)

```
Genera el sistema de autenticación para el Portal Colaborador de PeoplePortal usando
React 19 y un enfoque ROPC directo (sin redirección PKCE).

Requiero:

1. src/keycloak.js
   - Instancia Keycloak con: url=VITE_KEYCLOAK_URL||'http://localhost:30080',
     realm='peopleportal', clientId='peopleportal-frontend'
   - NO llama a keycloak.init() — se usa solo como proxy de token para el interceptor Axios

2. src/context/AuthContext.jsx
   - AuthProvider con estado: { isAuthenticated, user (tokenParsed), loading }
   - función login(username, password): hace POST al endpoint de token Keycloak con
     grant_type=password, guarda access_token/refresh_token en sessionStorage
   - función logout(): limpia sessionStorage, redirige al login
   - applyTokensToKeycloak(tokenData): inyecta el token en el objeto keycloak.js
     para que el interceptor Axios pueda leerlo de keycloak.token
   - Auto-refresh del token cuando quedan menos de 30s para expirar
   - Claves sessionStorage: 'pp-colab-token' y 'pp-colab-refresh'

3. src/pages/Login/LoginPage.jsx
   - Formulario con campos usuario y contraseña
   - Llama a auth.login() del contexto
   - Muestra error si login falla

4. Modificar App.jsx para:
   - Envolver con <AuthProvider>
   - Mostrar <LoginPage> si !isAuthenticated
   - Mostrar <Layout> con las rutas si isAuthenticated
```

---

## Prompt 2: Layout principal con glassmorphism, DiceAvatar y modo oscuro

```
Genera el componente Layout.jsx para el Portal Colaborador de PeoplePortal usando
Material UI v9. El layout incluye:

1. AppBar con efecto glassmorphism:
   - background: linear-gradient rgba con backdropFilter: blur(16px)
   - Título dinámico basado en la ruta activa (useLocation)
   - Icono de notificaciones con badge (unreadCount del NotificationsContext)
   - Selector de tema (light/dark/system) con menú
   - Nombre del usuario + DiceAvatar (componente que usa dicebear.com/7.x/lorelei/svg
     con seed=email del usuario) — el mismo avatar que aparece en el módulo de Perfil

2. Drawer lateral con navegación:
   - Logo "PeoplePortal" con gradiente azul (linear-gradient #60A5FA, #3B82F6)
   - Ítems: Dashboard, Mi Perfil, Mis Documentos, Solicitudes, Comunicados, Beneficios, Nómina
   - Ítem "Mi Equipo" visible solo si el usuario tiene rol 'jefe_inmediato'
     (roles desde auth.user.realm_access.roles)
   - Ítem activo: borderLeft '4px solid', background gradient
   - Hover: translateX(3px)

3. DiceAvatar component (src/components/DiceAvatar.jsx):
   - Props: seed (string), size (number), sx (object)
   - Genera URL: https://api.dicebear.com/7.x/lorelei/svg?seed=EMAIL&backgroundColor=...
   - Renderiza MUI Avatar con src={url}

4. Área de contenido principal con padding responsivo
```

---

## Prompt 3: Página Dashboard del Colaborador

```
Genera el componente Dashboard.jsx para el portal del colaborador de PeoplePortal usando
React 19, Material UI v9 y DiceAvatar.

El dashboard muestra:
1. Saludo personalizado con el nombre del usuario (useAuth().user)
   y su DiceAvatar circular (seed=email, tamaño 90px)
2. Tarjetas de estadísticas (Grid): Solicitudes Pendientes, Documentos,
   Comunicados Activos
3. Sección de Comunicados Recientes (últimos 3)
4. Usa getMyProfile para el perfil y getDashboard para los KPIs
5. Skeleton de carga (MUI Skeleton) mientras se obtienen los datos
```

---

## Prompt 4: Módulo de Solicitudes (Vacaciones, Constancias, Vouchers)

```
Genera el componente Requests.jsx para el portal colaborador con:
1. Tabs: Vacaciones | Constancias | Vouchers
2. Por cada tab: formulario inline (sin modal) con los campos del tipo de solicitud
   - Vacaciones: startDate (date), endDate (date), reason (text, requerido)
     validación: fechas deben ser futuras, endDate >= startDate
   - Constancia: certificateType (select: Trabajo/Salario/Vacaciones/Otro), reason
   - Voucher: period (select meses), year (number), reason
3. Botón "Enviar Solicitud" → POST /api/requests/vacation|certificate|voucher
4. Tabla paginada de mis solicitudes con filtro de estado
5. Botón "Cancelar" en solicitudes con estado 'Submitted'
6. useFormik + Yup para validación en cada tab
```

---

## Prompt 5: Módulo Mi Equipo (solo jefe_inmediato)

```
Genera el componente TeamRequests.jsx para el portal colaborador:
1. Solo visible para usuarios con rol 'jefe_inmediato'
2. Lista de solicitudes del equipo: GET /api/manager/requests
3. Para cada solicitud Submitted/InReview: botones "Aprobar" y "Rechazar"
4. Dialog de aprobación/rechazo con campo opcional hrComment
5. PATCH /api/manager/requests/{id}/status con { status, hrComment }
6. toast.success/error con el resultado
```

---

## Prompt 6: Módulo Nómina (comprobantes de pago)

```
Genera el componente Nomina.jsx para el portal colaborador:
1. Título "Mis Comprobantes de Nómina" (Typography h5, MonetizationOnIcon)
2. GET /api/nomina/me para obtener los registros
3. Tabla con columnas: Período, Tipo (Chip con color), Estado (Chip), Notas, Fecha
4. Filtro por tipo (ComprobanteDepago/Bonificacion/Adelanto/Aguinaldo/etc.)
5. Si status='AvailableForDownload' y tiene fileUrl: botón "Descargar"
6. Skeleton de carga y estado vacío con ícono
7. NominaType labels en español: ComprobanteDepago='Comprobante de Pago', etc.
```

---

## Prompt 1: Configuración de Keycloak en React

```
Genera la configuración completa de Keycloak para una aplicación React 19 + Vite usando
las librerías keycloak-js y @react-keycloak/web.

Incluye:
1. Archivo keycloak.js que instancia Keycloak con:
   url: import.meta.env.VITE_KEYCLOAK_URL
   realm: import.meta.env.VITE_KEYCLOAK_REALM
   clientId: import.meta.env.VITE_KEYCLOAK_CLIENT_ID

2. Configuración en main.jsx envolviendo la app con ReactKeycloakProvider:
   - initOptions: { onLoad: 'login-required', pkceMethod: 'S256' }
   - onTokens handler para guardar el token

3. Hook useAuth personalizado que expone:
   - isAuthenticated: boolean
   - userName: string (desde tokenParsed.name o preferred_username)
   - roles: string[] (desde tokenParsed.realm_access.roles)
   - token: string
   - logout(): void

4. Variables de entorno .env.example con todos los VITE_ requeridos
```

---

## Prompt 2: Layout principal con Material UI y drawer navegación

```
Genera el componente Layout.jsx para el Portal del Colaborador de PeoplePortal usando
Material UI v9 (MUI). El layout debe incluir:

1. AppBar superior con:
   - Logo/título "PeoplePortal" a la izquierda
   - Nombre del usuario (desde useKeycloak) a la derecha
   - Botón de cerrar sesión

2. Drawer lateral (permanente en desktop, temporal en móvil) con los ítems de navegación:
   - Dashboard (icono DashboardIcon) → /dashboard
   - Mis Solicitudes (icono AssignmentIcon) → /requests
   - Documentos (icono DescriptionIcon) → /documents
   - Comunicados (icono CampaignIcon) → /announcements
   - Beneficios (icono StarIcon) → /benefits
   - Mi Perfil (icono PersonIcon) → /profile

3. El ítem activo debe resaltarse usando useLocation() de react-router-dom
4. Área de contenido principal con padding apropiado
5. Completamente responsive (breakpoint md)
```

---

## Prompt 3: Página Dashboard del Colaborador

```
Genera el componente Dashboard.jsx para el portal del colaborador de PeoplePortal usando
React 19 y Material UI. El dashboard debe mostrar:

1. Saludo personalizado: "Bienvenido, {nombre}" usando el token de Keycloak

2. Tarjetas de estadísticas (Grid 3 columnas):
   - Solicitudes Pendientes (naranja, AssignmentIcon)
   - Documentos Disponibles (azul, DescriptionIcon)
   - Comunicados Activos (morado, CampaignIcon)
   Con Skeleton de carga mientras se obtienen los datos

3. Sección "Comunicados Recientes" (últimos 3):
   - Cada comunicado en un Paper con título, preview del cuerpo y fecha

4. Sección "Resumen de Beneficios" (Grid 2 columnas junto a comunicados):
   - Lista de beneficios disponibles con nombre y descripción

5. Datos obtenidos desde GET /api/dashboard via axios (apiClient.js)
6. Manejo de error: Alert informativo si el API falla
7. Estado de carga con Skeleton components

Archivo: src/pages/Dashboard/Dashboard.jsx
```

---

## Prompt 4: Página de Solicitudes del Colaborador

```
Genera el componente Requests.jsx para el portal del colaborador de PeoplePortal que permita:

1. Listar las solicitudes del empleado autenticado en una DataGrid de MUI con columnas:
   - Tipo (chip con color según tipo)
   - Estado (chip con color: Pending=amarillo, Approved=verde, Rejected=rojo)
   - Comentarios (truncado a 50 chars)
   - Fecha de solicitud (formateada en español)
   - Notas del revisor

2. Botón "Nueva Solicitud" que abre un Dialog con formulario:
   - Select para Tipo (VacationRequest, PermitRequest, CertificateRequest, SalaryAdvance, Other)
   - TextField para Comentarios (multiline, max 1000 chars, contador de caracteres)
   - Botón Cancelar y Enviar

3. Al enviar: POST /api/requests y refrescar la lista
4. Manejo de loading y errores con Snackbar
5. Validación del formulario antes de enviar

Archivo: src/pages/Requests/Requests.jsx
```

---

## Prompt 5: Cliente HTTP con axios y token automático

```
Genera el apiClient.js para el Frontend Colaborador de PeoplePortal usando axios que:

1. Crea una instancia axios con baseURL: import.meta.env.VITE_API_BASE_URL

2. Interceptor de request que:
   - Obtiene el token actual de Keycloak (keycloak.token)
   - Lo adjunta como header Authorization: Bearer <token>
   - Si el token está por expirar (tokenExpiresIn < 30s), lo refresca primero

3. Interceptor de response que:
   - En error 401 → llama keycloak.logout()
   - En error 403 → redirige a /access-denied
   - En cualquier otro error → lo propaga normalmente

4. Exporta funciones específicas del dashboard:
   - getDashboard(): GET /api/dashboard
   
Archivo: src/api/client.js
```
