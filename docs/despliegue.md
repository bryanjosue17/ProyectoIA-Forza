# PeoplePortal — Guía de Despliegue Completa

## Prerrequisitos

| Herramienta | Versión mínima |
|---|---|
| Docker Desktop | Con Kubernetes habilitado |
| `kubectl` | Contexto `docker-desktop` configurado |
| PowerShell | 7+ (Windows) o bash (Linux/Mac) |
| Git | Con soporte submódulos |

---

## 1. Clonar el repositorio

```bash
# Con submódulos en un solo paso
git clone --recurse-submodules https://github.com/bryanjosue17/ProyectoIA-Forza.git

# Si ya clonaste sin submódulos
git submodule update --init --recursive
```

---

## 2. Imágenes Docker (GHCR)

Las imágenes se publican automáticamente en **GitHub Container Registry** por el CI de cada repositorio al hacer push a `main` o `develop`.

| Imagen GHCR | Repo fuente |
|---|---|
| `ghcr.io/bryanjosue17/peopleportal-api:main` | `PeoplePortal-BackEnd/` |
| `ghcr.io/bryanjosue17/peopleportal-api-migrations:main` | `PeoplePortal-BackEnd/` |
| `ghcr.io/bryanjosue17/peopleportal-frontend-colaborador:main` | `PeoplePortal-FrontEnd-Colaborador/` |
| `ghcr.io/bryanjosue17/peopleportal-frontend-rrhh:main` | `PeoplePortal-FrontEnd-RRHH/` |

Tags disponibles: `main` (rama), `develop` (rama) y `{short-sha}` (7 caracteres del commit).

> **Build local (legacy):** Si necesitas construir sin CI, usa `deploy/build.ps1` o `deploy/deploy.ps1 -Build`.

---

## 3. Despliegue completo (scripts automáticos)

```powershell
# DESARROLLO local (Docker Desktop) — imágenes :develop
.\deploy\deploy.ps1
.\deploy\deploy.ps1 -SkipMigrations

# PRODUCCIÓN — imágenes :main
.\deploy\deploy.ps1 -Environment production

# MODO LOCAL legacy — build en tu máquina
.\deploy\deploy.ps1 -Build

# Linux / macOS
bash deploy/deploy.sh                          # develop (por defecto)
bash deploy/deploy.sh --environment production  # produccion
bash deploy/deploy.sh --build                   # build local
```

> **Kustomize:** Los manifiestos usan overlays por entorno:
> - `overlays/develop/` → imagen `:develop` (Docker Desktop local)
> - `overlays/production/` → imagen `:main` (producción)
> El script aplica `kubectl apply -k overlays/{env}/` + `rollout restart`.

---

## 4. Despliegue manual paso a paso

```bash
# ── Infraestructura global ────────────────────────────────────────────────────
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/keycloak-realm-configmap.yaml
kubectl apply -f k8s/keycloak.yaml
kubectl apply -f k8s/apisix-configmap.yaml
kubectl apply -f k8s/apisix.yaml

# ── Backend ───────────────────────────────────────────────────────────────────
kubectl apply -f PeoplePortal-BackEnd/k8s/configmap.yaml
kubectl apply -f PeoplePortal-BackEnd/k8s/postgres.yaml
kubectl apply -f PeoplePortal-BackEnd/k8s/nats.yaml

# ── Migraciones (esperar a que terminen) ──────────────────────────────────────
kubectl apply -f PeoplePortal-BackEnd/k8s/migration-job.yaml
kubectl wait --for=condition=complete job/peopleportal-migrations \
  -n peopleportal --timeout=180s

# ── API ───────────────────────────────────────────────────────────────────────
kubectl apply -f PeoplePortal-BackEnd/k8s/api.yaml

# ── Frontends (via Kustomize) ────────────────────────────────────────────────
# Crear imagePullSecret para GHCR
GH_TOKEN=$(gh auth token)
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io --docker-username=bryanjosue17 \
  --docker-password="$GH_TOKEN" --namespace=peopleportal \
  --dry-run=client -o yaml | kubectl apply -f -

# develop (Docker Desktop local)
kubectl apply -k PeoplePortal-FrontEnd-Colaborador/k8s/overlays/develop/
kubectl apply -k PeoplePortal-FrontEnd-RRHH/k8s/overlays/develop/

# production
# kubectl apply -k PeoplePortal-FrontEnd-Colaborador/k8s/overlays/production/
# kubectl apply -k PeoplePortal-FrontEnd-RRHH/k8s/overlays/production/

kubectl rollout restart deployment/frontend-colaborador -n peopleportal
kubectl rollout restart deployment/frontend-rrhh        -n peopleportal
kubectl rollout status   deployment/frontend-colaborador -n peopleportal
kubectl rollout status   deployment/frontend-rrhh        -n peopleportal

# ── API + Migrations (via Kustomize) ───────────────────────────────────────
kubectl delete job peopleportal-migrations --ignore-not-found -n peopleportal
kubectl apply -k PeoplePortal-BackEnd/k8s/overlays/develop/
kubectl wait --for=condition=complete job/peopleportal-migrations \
  -n peopleportal --timeout=180s
kubectl rollout restart deployment/peopleportal-api -n peopleportal
kubectl rollout status   deployment/peopleportal-api -n peopleportal

# ── Ingress (opcional) ────────────────────────────────────────────────────────
kubectl apply -f k8s/ingress.yaml
```

---

## 5. Verificar estado

```bash
kubectl get pods     -n peopleportal
kubectl get services -n peopleportal
kubectl get jobs     -n peopleportal
```

---

## 6. Verificar con tests E2E

```bash
# Ejecutar pruebas E2E del Portal Colaborador
cd PeoplePortal-FrontEnd-Colaborador
npx playwright install msedge
npx playwright test e2e-tests/full-flows.spec.js --headed

# Ejecutar pruebas E2E del Portal RRHH
cd ../PeoplePortal-FrontEnd-RRHH
npx playwright install msedge
npx playwright test e2e-tests/full-flows.spec.js --headed
```

Ver reporte HTML con resultados y capturas por paso:
```bash
npx playwright show-report
```

Ver documentación completa en [`docs/playwright.md`](./playwright.md).

## 7. URLs de acceso

| Servicio | URL |
|---|---|
| Portal Colaborador | http://localhost:30081 |
| Panel RRHH | http://localhost:30082 |
| Keycloak Admin | http://localhost:30080/admin |
| API (via APISIX) | http://localhost:30090/api |
| API Swagger | http://localhost:30099/swagger/index.html |

### Credenciales de acceso

| Portal / Herramienta | Usuario | Contraseña | Roles |
|---|---|---|---|
| **Keycloak Admin Console** | `admin` | `admin` | — |
| **Panel RRHH** | `admin` | `admin123` | `hr`, `admin` |
| **Portal Colaborador** | `testmanager` | `test123` | `employee`, `jefe_inmediato` |

> Las credenciales de prueba están preconfiguradas en el realm `peopleportal` que se importa automáticamente al arrancar Keycloak (`--import-realm`).  
> Para crear usuarios adicionales: Keycloak Admin → Realm `peopleportal` → Users → Add user.

---

## 8. Limpiar entorno

```bash
kubectl delete namespace peopleportal
```

---

## 9. CI/CD (GitHub Actions)

Cada submódulo tiene su propio `.github/workflows/ci.yml` con dos jobs:

| Job | Acciones |
|---|---|
| `build-test` | restore/install → build → lint → tests con cobertura → Codacy → Trivy |
| `docker` | build imagen → push a GHCR (tags: branch + short-sha) |

> El deploy a K8s **no** ocurre en CI (los runners de GitHub no acceden al cluster Docker Desktop local).
