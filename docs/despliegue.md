# PeoplePortal — Guía de Despliegue

## Prerrequisitos

- Docker Desktop con Kubernetes habilitado
- `kubectl` configurado con contexto `docker-desktop`
- PowerShell 7+ (Windows) o bash (Linux/Mac)

## Orden de despliegue

### 1. Build de imágenes

```powershell
# Desde la raíz del repositorio
cd deploy
.\build.ps1
```

Esto genera las 4 imágenes locales:
- `peopleportal-api:latest`
- `peopleportal-api-migrations:latest`
- `peopleportal-frontend-colaborador:latest`
- `peopleportal-frontend-rrhh:latest`

### 2. Deploy completo

```powershell
cd deploy
.\deploy.ps1 -Build
```

O solo manifiestos (si ya tienes las imágenes):
```powershell
.\deploy.ps1
```

### 3. Deploy manual (paso a paso)

```bash
# Infraestructura global
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/keycloak-realm-configmap.yaml
kubectl apply -f k8s/keycloak.yaml
kubectl apply -f k8s/apisix-configmap.yaml
kubectl apply -f k8s/apisix.yaml

# Backend
cd PeoplePortal-BackEnd/k8s/configmap.yaml
kubectl apply -f PeoplePortal-BackEnd/k8s/nats.yaml

# SQL Server corre en local (Windows), no en K8s

# Migraciones
kubectl apply -f PeoplePortal-BackEnd/k8s/migration-job.yaml
kubectl wait --for=condition=complete job/peopleportal-migrations -n peopleportal --timeout=180s

# API
kubectl apply -f PeoplePortal-BackEnd/k8s/api.yaml

# Frontends
kubectl apply -f PeoplePortal-FrontEnd-Colaborador/k8s/frontend-colaborador.yaml
kubectl apply -f PeoplePortal-FrontEnd-RRHH/k8s/frontend-rrhh.yaml

# Ingress (opcional)
kubectl apply -f k8s/ingress.yaml
```

## Verificar estado

```bash
kubectl get pods -n peopleportal
kubectl get services -n peopleportal
```

## URLs de acceso

| Servicio | URL |
|---|---|
| Portal Colaborador | http://localhost:30081 |
| Panel RRHH | http://localhost:30082 |
| Keycloak Admin | http://localhost:30080/admin |
| API Swagger | (via APISIX :30090/api o port-forward) |

## Limpiar namespace

```bash
kubectl delete namespace peopleportal
```

## CI/CD

El pipeline en `BackEnd/.github/workflows/ci.yml` automatiza:
1. `build-test`: build .NET, tests, cobertura Codacy, escaneo Trivy
2. `deploy-local`: en rama `develop`, build de imágenes y `kubectl apply` de todos los manifiestos
