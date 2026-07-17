# Prompt — Tests E2E con Playwright (POM Pattern)

## Contexto
Tests end-to-end usando `@playwright/test` v1.61+. Navegador: Microsoft Edge.
Ambos portales desplegados en Kubernetes local:
- Colaborador: http://localhost:30081
- RRHH: http://localhost:30082
- Auth: formulario de login personalizado (NO redirección Keycloak)

---

## Prompt 1: Configuración de Playwright con Page Object Model

```
Genera la configuración completa de Playwright para el Portal Colaborador de PeoplePortal.

playwright.config.js:
- baseURL: http://localhost:30081
- testDir: ./e2e-tests
- workers: 1 (serial, porque las pruebas comparten estado del servidor)
- retries: 0 (local), 2 (CI)
- reporter: 'html'
- screenshot: 'on' (captura screenshot en cada test)
- trace: 'on' (genera trace.zip para Playwright Trace Viewer)
- project: Microsoft Edge (channel: 'msedge')

Genera también los Page Object Models base:
1. LoginPage.js: 
   - constructor: usernameInput (getByLabel), passwordInput (locator input[name=password]),
     signInButton (getByRole button 'Sign In')
   - async login(username, password): page.goto('/') + fill + click
   
2. DashboardPage.js:
   - heading: getByRole('heading', { name: /Bienvenido/i })
   - async navigateTo(moduleName): page.locator('nav').locator(text=/${moduleName}/i).first().click()
   - async verifyLoaded(): heading.waitFor({ state: 'visible', timeout: 15000 })

Credenciales de prueba:
- Colaborador: testmanager / test123 (tiene rol jefe_inmediato)
- RRHH admin: admin / admin123
```

---

## Prompt 2: Test E2E Full Flow (flujo completo Colaborador)

```
Genera el test E2E full-flows.spec.js para el Portal Colaborador de PeoplePortal
usando Playwright con el patrón Page Object Model.

El test "debe recorrer todos los flujos de forma secuencial y estructurada" debe:
1. Autenticarse con testmanager/test123
2. Perfil: hacer clic en Editar, llenar phone/site/emergencyContact/emergencyPhone, guardar
   → PUT /api/employees/me → verificar toast "Perfil actualizado exitosamente"
3. Documentos: buscar "contrato" en el buscador → GET /api/documents/me
4. Solicitudes (Vacaciones): llenar startDate/endDate/reason → Enviar Solicitud
   → POST /api/requests/vacation → toast "Solicitud creada exitosamente"
5. Solicitudes (Constancias): cambiar tab, seleccionar tipo=Trabajo, llenar reason → Enviar
   → POST /api/requests/certificate
6. Comunicados: verificar que carga → GET /api/announcements
7. Beneficios: verificar tarjetas → GET /api/benefits
8. Nómina: verificar tabla → GET /api/nomina/me
9. Dashboard: navegar al inicio

Configurar test.setTimeout(240000) y slowMo: 600 para visualización humana.
Capturar screenshots con shot(label) en cada paso usando test.info().attach().
```

---

## Prompt 3: Test E2E Full Flow (flujo completo RRHH)

```
Genera full-flows.spec.js para el Panel RRHH con los siguientes pasos:
1. Login: admin/admin123
2. Perfil: editar y guardar → PUT /api/employees/me
3. Empleados: click "Añadir Empleado" → llenar TODOS los campos requeridos
   (code, fullName=timestamp único, email=timestamp único, department, position, hireDate,
   contractType=Indefinido) → Guardar → POST /api/hr/employees → toast éxito
4. Documentos: buscar + subir documento (empleado, nombre, tipo, URL) → POST /api/hr/documents
5. Solicitudes: filtrar por tipo + aprobar la primera Submitted → PATCH /api/hr/requests/{id}/status
6. Comunicados: crear nuevo (título, tipo HR, expiración, cuerpo) → POST /api/hr/announcements
7. Beneficios: crear beneficio (nombre, tipo Salud, descripción) → POST /api/hr/benefits
8. Nómina: crear registro (empleado autocomplete, tipo, mes Junio, año 2026) → POST /api/hr/nomina
9. Usuarios: crear usuario (username, email, firstName, lastName, password) → POST /api/hr/users
10. Reportes: verificar que las gráficas cargan
11. Dashboard: volver al inicio

Importante: usar timestamps (Date.now()) en códigos y emails para idempotencia.
```
