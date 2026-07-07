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

## 2. Build de imágenes Docker

```powershell
# Desde la raíz del repositorio
cd deploy
.\build.ps1
```

Genera 4 imágenes locales:

| Imagen | Fuente |
|---|---|
| `peopleportal-api:latest` | `PeoplePortal-BackEnd/` |
| `peopleportal-api-migrations:latest` | `PeoplePortal-BackEnd/` |
| `peopleportal-frontend-colaborador:latest` | `PeoplePortal-FrontEnd-Colaborador/` |
| `peopleportal-frontend-rrhh:latest` | `PeoplePortal-FrontEnd-RRHH/` |

---

## 3. Despliegue completo (scripts automáticos)

```powershell
cd deploy

# Build + deploy en un solo paso
.\deploy.ps1 -Build

# Solo apply de manifiestos (si ya tienes las imágenes)
.\deploy.ps1
```

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

# ── Frontends ─────────────────────────────────────────────────────────────────
kubectl apply -f PeoplePortal-FrontEnd-Colaborador/k8s/frontend-colaborador.yaml
kubectl apply -f PeoplePortal-FrontEnd-RRHH/k8s/frontend-rrhh.yaml

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
# Ejecutar pruebas E2E del Portal RRHH
cd PeoplePortal-FrontEnd-RRHH
npx playwright install msedge
npx playwright test full-flows.spec.js

# Ejecutar pruebas E2E del Portal Colaborador
cd ../PeoplePortal-FrontEnd-Colaborador
npx playwright install msedge
npx playwright test full-flows.spec.js
```

Los tests generan reporte HTML (`playwright show-report`) y capturas de pantalla en `docs/{app}/screenshots/`.  
Ver documentación completa en [`docs/playwright.md`](./playwright.md).

## 7. URLs de acceso

| Servicio | URL |
|---|---|
| Portal Colaborador | http://localhost:30081 |
| Panel RRHH | http://localhost:30082 |
| Keycloak Admin | http://localhost:30080/admin |
| API (via APISIX) | http://localhost:30090/api |
| API Swagger | http://localhost:30099/swagger/index.html |

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
