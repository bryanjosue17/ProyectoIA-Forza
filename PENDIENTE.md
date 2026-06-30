# PeoplePortal — Checklist Pendiente

## 1. Seed Data (Alta)

Crear registros en PeoplePortalDb para que los usuarios test tengan empleados asociados.

**Pasos:**

1. Conectarse a `DESKTOP-UO9FHOJ\SQLEXPRESS` con SQL Auth (sa / YourStrong@Passw0rd)
2. Verificar que las migraciones crearon las tablas en `PeoplePortalDb`
3. Insertar empleados para los usuarios Keycloak existentes:
   - `testuser` → employee normal
   - `testmanager` → employee con jefe = testuser (o él es jefe)
   - `testhr` → employee con rol HR
   - `admin` → employee con rol admin
4. Insertar documentos, solicitudes, beneficios de prueba

**SQL seed script:**
```sql
USE PeoplePortalDb;
GO

INSERT INTO employees (id, keycloak_user_id, full_name, email, department, position, manager_id, hire_date, status, created_at, updated_at)
VALUES
    (NEWID(), 'testuser',    'Juan Pérez',      'juan@empresa.com',     'TI',        'Desarrollador',    NULL, '2024-01-15', 1, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'testmanager', 'María López',     'maria@empresa.com',   'TI',        'Tech Lead',        NULL, '2023-06-01', 1, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'testhr',      'Carlos Ruiz',     'carlos@empresa.com',  'RRHH',      'Analista RRHH',    NULL, '2023-03-10', 1, GETUTCDATE(), GETUTCDATE()),
    (NEWID(), 'admin',       'Admin Sistema',   'admin@empresa.com',   'Admin',     'Administrador',    NULL, '2024-01-01', 1, GETUTCDATE(), GETUTCDATE());
GO
```
> Nota: `keycloak_user_id` debe coincidir con el `sub` del JWT. Puedes obtenerlo decodificando el token en jwt.io o desde Keycloak Admin Console.

---

## 2. Probar Eventos NATS (Alta)

Verificar que al crear una solicitud (HR Request) se publique un evento en NATS.

**Pasos:**

1. Obtener token JWT desde Keycloak:
   ```powershell
   $body = @{
       client_id  = 'peopleportal-frontend'
       username   = 'testuser'
       password   = 'test123'
       grant_type = 'password'
   }
   $token = (Invoke-RestMethod -Uri 'http://localhost:30080/realms/peopleportal/protocol/openid-connect/token' -Method Post -Body $body).access_token
   ```

2. Crear una solicitud vía API:
   ```powershell
   $reqBody = @{
       employeeId = '<employee-guid-de-testuser>'
       type       = 'Vacaciones'
       reason     = 'Prueba NATS'
       startDate  = '2026-07-01'
       endDate    = '2026-07-05'
   } | ConvertTo-Json

   Invoke-RestMethod -Uri 'http://localhost:30081/api/hr-requests' -Method Post -Body $reqBody -ContentType 'application/json' -Headers @{Authorization = "Bearer $token"}
   ```

3. Verificar logs del API:
   ```powershell
   kubectl logs -n peopleportal deploy/peopleportal-api --tail=50
   ```
   Buscar mensajes como `Publishing event`, `hr.request.submitted` o `NatsEventBus`.

4. Opcional: conectar NATS CLI para ver el stream:
   ```powershell
   kubectl run nats-box -n peopleportal --image natsio/nats-box --rm -it --restart=Never -- nats str ls -s nats://nats-service:4222
   ```

---

## 3. Video Demo (Alta)

Grabar 5-8 min mostrando:

**Pasos:**

1. **Inicio (30s):** Mostrar `kubectl get pods -n peopleportal` → 7 pods OK
2. **Keycloak (1 min):** Navegar a http://localhost:30080/admin, mostrar realm `peopleportal`, clients, roles, users
3. **Frontend Colaborador (2 min):** Login con testuser/test123 en http://localhost:30081, mostrar dashboard, crear solicitud
4. **Frontend RRHH (1 min):** Login con testhr/test123 en http://localhost:30082, mostrar panel con solicitudes pendientes
5. **API (1 min):** Mostrar Swagger o llamada directa a `/api/dashboard` con token
6. **Cierre (30s):** Resumir: Clean Architecture, CQRS, NATS, K8s, 81 tests

Herramientas sugeridas: OBS Studio (gratuito), Loom, o Clipchamp.

---

## ~~4. APISIX client_secret (Media)~~ ✅

Configurado: client `peopleportal-api` tiene secret `fXvEaUeieNd3taTylb0LbBY4npbISmXC` en Keycloak, actualizado en `k8s/apisix-configmap.yaml`.

**Pasos:**

1. Ir a Keycloak Admin Console http://localhost:30080/admin
2. Realm: `peopleportal` → Clients → `peopleportal-apisix`
3. Cambiar `Client authentication` a **ON** (confidential)
4. En la pestaña `Credentials`, copiar el `Client secret`
5. Actualizar `k8s/apisix-configmap.yaml` con el secret:
   ```yaml
   client_secret: "<el-secret-copiado>"
   ```
6. Reaplicar:
   ```powershell
   kubectl delete pod -n peopleportal -l app=apisix
   kubectl apply -f k8s/apisix-configmap.yaml
   ```

---

## ~~5. Branch Protection en Submódulos (Media)~~ ✅

Activado en PeoplePortal-BackEnd, PeoplePortal-FrontEnd-Colaborador y PeoplePortal-FrontEnd-RRHH.

**Pasos:**

Para cada repo: `PeoplePortal-BackEnd`, `PeoplePortal-FrontEnd-Colaborador`, `PeoplePortal-FrontEnd-RRHH`:

```powershell
# Reemplazar <repo> con cada nombre
gh api repos/bryanjosue17/<repo>/branches/develop/protection --method PUT --input @'
{
  "required_status_checks": { "strict": true, "contexts": [] },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null
}
'@
```

---

## ~~6. CD Pipeline (Media)~~ ✅

Pipeline actualizado en `.github/workflows/ci.yml`: corrige path `k8s/api-deployment.yaml` → `k8s/api.yaml`, elimina `sqlserver.yaml`, añade `imagePullPolicy: Always`.

**Pasos:**

1. En el root `.github/workflows/ci.yml`, agregar job `deploy`:
   ```yaml
   deploy:
     needs: build-test
     if: github.ref == 'refs/heads/develop'
     runs-on: ubuntu-latest
     steps:
       - uses: actions/checkout@v4
         with:
           submodules: recursive
       - name: Build images
         run: |
           docker build -t ghcr.io/bryanjosue17/peopleportal-api:${{ github.sha }} ./PeoplePortal-BackEnd
           docker build -t ghcr.io/bryanjosue17/peopleportal-api-migrations:${{ github.sha }} -f PeoplePortal-BackEnd/Dockerfile --target migrations ./PeoplePortal-BackEnd
           docker build -t ghcr.io/bryanjosue17/peopleportal-frontend-colaborador:${{ github.sha }} ./PeoplePortal-FrontEnd-Colaborador
           docker build -t ghcr.io/bryanjosue17/peopleportal-frontend-rrhh:${{ github.sha }} ./PeoplePortal-FrontEnd-RRHH
       - name: Push to GHCR
         run: |
           echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
           docker push ghcr.io/bryanjosue17/peopleportal-api:${{ github.sha }}
           # ... push todas las imágenes
   ```

2. Configurar `imagePullPolicy: Always` en los manifiestos K8s (o usar tags dinámicos)
3. Agregar step de `kubectl set image` para actualizar deployments

---

## ~~7. Conventional Commits (Baja)~~ ✅

Archivo `.gitmessage` creado en la raíz. Ejecutar `git config commit.template .gitmessage` para activarlo.

**Pasos:**

1. Agregar `.gitmessage` template en cada repo:
   ```
   <type>(<scope>): <subject>
   <BLANK LINE>
   <body>
   ```
2. Configurar template:
   ```powershell
   git config commit.template .gitmessage
   ```
3. Tipos: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `build`, `ci`
4. Commits futuros deben seguir el formato (los ya hechos se pueden ignorar)
