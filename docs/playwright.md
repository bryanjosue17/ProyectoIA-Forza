# PeoplePortal — E2E Testing con Playwright

## Visión General

El proyecto utiliza **Playwright Test** (`@playwright/test` v1.61.1) para pruebas E2E (End-to-End) en ambos frontends. Las pruebas simulan flujos completos de usuario: autenticación, navegación, llenado de formularios, envío y verificación de resultados.

No se utilizan MCP servers, plugins ni herramientas adicionales para Playwright. No hay Dockerización de los tests (se ejecutan directamente contra los servicios desplegados en Kubernetes local).

---

## Stack

| Componente | Librería | Versión |
|---|---|---|
| Core | `@playwright/test` | ^1.61.1 |
| Navegador | Microsoft Edge (canal msedge) | — |
| Lenguaje | JavaScript (ESM, type: module) | — |

### Dependencias secundarias (desarrollo)

Ambos frontends incluyen `@playwright/test` como `devDependency`. No hay dependencias transversales de Playwright con otros módulos del proyecto.

---

## Estructura de Archivos

```
PeoplePortal-FrontEnd-{RRHH,Colaborador}/
├── e2e-tests/
│   ├── full-flows.spec.js       ← Flujo completo (todos los módulos)
│   ├── login.spec.js            ← Pruebas de autenticación
│   └── pages/                   ← Page Object Models
│       ├── LoginPage.js
│       ├── DashboardPage.js
│       ├── EmployeesPage.js      (solo RRHH)
│       ├── DocumentsPage.js
│       ├── ApprovalsPage.js      (solo RRHH)
│       ├── AnnouncementsPage.js  (solo RRHH)
│       ├── BenefitsPage.js       (solo RRHH)
│       ├── NominaPage.js
│       ├── UserManagementPage.js (solo RRHH)
│       ├── ReportsPage.js        (solo RRHH)
│       ├── ProfilePage.js        (solo Colaborador)
│       ├── RequestsPage.js       (solo Colaborador)
│       └── TeamRequestsPage.js   (solo Colaborador)
├── playwright.config.js         ← Configuración de Playwright
├── .gitignore                   ← Ignora: test-results/, playwright-report/, blob-report/
└── package.json                 ← @playwright/test en devDependencies
```

### Page Object Model (POM)

Cada página sigue el mismo patrón:

```
class NombrePage {
  constructor(page)           // Recibe page de Playwright
  async verifyLoaded()         // Espera que el heading sea visible
  async interact({ onFormReady })  // Llena formulario y envía
}
```

- `verifyLoaded()` — garantiza que el módulo cargó antes de interactuar
- `interact({ onFormReady })` — callback opcional para capturar el formulario lleno antes del submit

---

## Configuración

### playwright.config.js

| Parámetro | RRHH | Colaborador |
|---|---|---|
| `baseURL` | `http://localhost:30082` | `http://localhost:30081` |
| `testDir` | `./e2e-tests` | `./e2e-tests` |
| `workers` | 1 (serial) | 1 (serial) |
| `retries` | 0 (2 en CI) | 0 (2 en CI) |
| `reporter` | html | html |
| `trace` | `on` | `on` |
| `screenshot` | `only-on-failure` | `only-on-failure` |
| `viewport` | 1920×1080 (en spec) | 1920×1080 (en spec) |
| `slowMo` | 600ms (en spec) | 600ms (en spec) |
| Proyecto | Microsoft Edge | Microsoft Edge |

### .gitignore (adiciones para Playwright)

```
/test-results/
/playwright-report/
/blob-report/
/playwright/.cache/
/playwright/.auth/
```

---

## Instalación

Los tests E2E se instalan junto con las dependencias del proyecto:

```bash
# Desde la raíz del frontend correspondiente
cd PeoplePortal-FrontEnd-RRHH
npm install    # Instala @playwright/test automáticamente
npx playwright install msedge   # Descarga Microsoft Edge para Playwright
```

Los navegadores de Playwright se instalan por separado:

```bash
# Ver navegadores instalados
npx playwright install --list

# Instalar solo Microsoft Edge
npx playwright install msedge

# Instalar todos los navegadores soportados
npx playwright install
```

---

## Ejecución

```bash
# Desde la raíz del frontend (NO desde e2e-tests/)
cd PeoplePortal-FrontEnd-RRHH   # o PeoplePortal-FrontEnd-Colaborador

# Ejecutar el flujo completo
npx playwright test full-flows.spec.js

# Ejecutar test de login
npx playwright test login.spec.js

# Ejecutar todos los tests E2E
npx playwright test

# Modo UI (navegador interactivo)
npx playwright test --ui

# En modo debug (Pause en cada acción)
npx playwright test --debug
```

### Requisitos previos

1. Los 4 servicios deben estar desplegados y accesibles:
   - Portal Colaborador en `http://localhost:30081`
   - Portal RRHH en `http://localhost:30082`
   - Keycloak en `http://localhost:30080`
   - API Backend en `http://localhost:30099`

2. Las credenciales de prueba deben existir en Keycloak:
   - RRHH: `admin / admin123`
   - Colaborador: `testmanager / test123`

3. Ejecutar desde la raíz del proyecto frontend (no desde `e2e-tests/`) para que Playwright lea el `playwright.config.js` con la `baseURL` configurada.

---

## Reportes

```bash
# Ver reporte HTML de la última ejecución
npx playwright show-report

# Los reportes se guardan en:
# playwright-report/index.html
```

Cada ejecución genera:
- **Reporte HTML** con árbol de tests, tiempo, capturas y traces
- **Traces** (`.zip`) en `test-results/` — permiten reproducir cada acción en el Trace Viewer
- **Screenshots** solo en caso de fallo (config: `screenshot: 'only-on-failure'`)

---

## Capturas de Pantalla

Además de los screenshots automáticos por fallo, los tests de flujo completo (`full-flows.spec.js`) generan capturas explícitas en cada paso:

- En `full-flows.spec.js`, la función `shot(label)` captura:
  - Una imagen adjunta al reporte HTML (`test.info().attach`)
  - Una imagen en `docs/{app}/screenshots/{label}.png`

Las capturas de formulario lleno se toman justo antes del submit mediante el callback `onFormReady`.

### Screenshots generados

#### Portal RRHH (17 capturas)

| Archivo | Contenido |
|---|---|
| `01-dashboard.png` | Dashboard post-login |
| `02-empleados-form.png` | Modal de creación de empleado con campos llenos |
| `02-empleados.png` | Toast de empleado creado |
| `03-documentos-form.png` | Modal de subida de documento con campos llenos |
| `03-documentos.png` | Documento subido exitosamente |
| `04-solicitudes-form.png` | Filtro de solicitudes aplicado |
| `04-solicitudes.png` | Solicitud aprobada |
| `05-comunicados-form.png` | Modal de nuevo comunicado lleno |
| `05-comunicados.png` | Comunicado creado |
| `06-beneficios-form.png` | Modal de nuevo beneficio lleno |
| `06-beneficios.png` | Beneficio creado |
| `07-nomina-form.png` | Modal de registro de nómina lleno |
| `07-nomina.png` | Registro creado |
| `08-usuarios-form.png` | Modal de nuevo usuario lleno |
| `08-usuarios.png` | Usuario creado |
| `09-reportes.png` | Reportes cargados |
| `10-dashboard-final.png` | Dashboard al finalizar |

#### Portal Colaborador (12 capturas)

| Archivo | Contenido |
|---|---|
| `01-dashboard.png` | Dashboard post-login |
| `02-perfil-form.png` | Formulario de edición de perfil lleno |
| `02-perfil.png` | Perfil actualizado |
| `03-documentos.png` | Documentos personales |
| `04-solicitudes-vac-form.png` | Formulario de vacaciones lleno |
| `04-solicitudes-const-form.png` | Formulario de constancia lleno |
| `04-solicitudes.png` | Solicitud creada |
| `05-mi-equipo.png` | Solicitudes del equipo (managers) |
| `06-comunicados.png` | Comunicados visibles |
| `07-beneficios.png` | Diálogo de canje |
| `08-nomina.png` | Recibos de nómina |
| `09-dashboard-final.png` | Dashboard final |

---

## Trazas (Traces)

La configuración `trace: 'on'` genera un trace `.zip` por cada test, incluso si pasa. Se pueden visualizar con:

```bash
npx playwright show-trace test-results/.../trace.zip
```

El Trace Viewer muestra:
- Línea de tiempo de acciones del navegador
- Estados del DOM antes/después de cada acción
- Logs de consola y errores de red
- Screenshots por paso

---

---

## Resolución de Problemas

| Problema | Causa | Solución |
|---|---|---|
| `Cannot navigate to invalid URL` | Ejecución desde `e2e-tests/` | Ejecutar desde la raíz del frontend |
| `@playwright/test: not found` | Dependencias no instaladas | `npm install` |
| `MS Edge not found` | Navegador no instalado | `npx playwright install msedge` |
| `401 en llamadas API` | Token Keycloak expirado | `kubectl rollout restart deployment peopleportal-api` |
| `Timeout en waitFor` | Servicio no disponible | Verificar que el pod correspondiente esté corriendo |

---

## Documentación Relacionada

- Manual Técnico RRHH: [`docs/rrhh/manual-tecnico.md`](./rrhh/manual-tecnico.md)
- Manual Técnico Colaborador: [`docs/colaborador/manual-tecnico.md`](./colaborador/manual-tecnico.md)
- Guía de despliegue: [`docs/despliegue.md`](./despliegue.md)
- Arquitectura global: [`docs/arquitectura.md`](./arquitectura.md)
- Referencia oficial: [https://playwright.dev/docs/intro](https://playwright.dev/docs/intro)
