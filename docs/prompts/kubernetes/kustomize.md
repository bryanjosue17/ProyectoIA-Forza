# Prompt — Kustomize Overlays por Entorno

## Contexto
K8s local con Docker Desktop. Imágenes en GHCR (`ghcr.io/bryanjosue17/...`).
Necesitamos separar imágenes por entorno:
- `develop` overlay → imágenes con tag `:develop` (Docker Desktop local)
- `production` overlay → imágenes con tag `:main` (producción)

---

## Prompt 1: Estructura base/overlays para un Frontend React

```
Genera la estructura Kustomize base+overlays para el frontend frontend-colaborador
de PeoplePortal.

Estructura de directorios:
k8s/
├── base/
│   ├── kustomization.yaml   → resources: [deployment.yaml, service.yaml]
│   ├── deployment.yaml      → imagen base: ghcr.io/bryanjosue17/peopleportal-frontend-colaborador:develop
│   └── service.yaml         → NodePort 30081
└── overlays/
    ├── develop/
    │   └── kustomization.yaml → images patch: newTag=develop
    └── production/
        └── kustomization.yaml → images patch: newTag=main

El deployment incluye imagePullSecrets: [{name: ghcr-secret}] e imagePullPolicy: Always.
El overlay usa el campo 'images' de Kustomize para parchear el tag:
images:
  - name: ghcr.io/bryanjosue17/peopleportal-frontend-colaborador
    newTag: develop

Uso:
kubectl apply -k k8s/overlays/develop/    # local
kubectl apply -k k8s/overlays/production/ # producción
```

---

## Prompt 2: Kustomize base para BackEnd (API + migrations)

```
Genera la estructura Kustomize para el BackEnd de PeoplePortal que incluye
dos recursos con imagen: api.yaml (Deployment) y migration-job.yaml (Job).

k8s/
├── base/
│   ├── kustomization.yaml   → resources: [api.yaml, migration-job.yaml]
│   ├── api.yaml             → imagen ghcr.io/bryanjosue17/peopleportal-api:develop
│   └── migration-job.yaml   → imagen ghcr.io/bryanjosue17/peopleportal-api-migrations:develop
└── overlays/
    ├── develop/
    │   └── kustomization.yaml → patches para api y migrations a :develop
    └── production/
        └── kustomization.yaml → patches para api y migrations a :main

Nota: Los archivos de infra (configmap.yaml, postgres.yaml, nats.yaml) NO tienen
imagen propia, se aplican con kubectl apply -f directamente y no necesitan overlays.

Para migraciones: el Job de K8s es idempotente (apply en job completado → unchanged).
Para forzar re-ejecución: kubectl delete job peopleportal-migrations --ignore-not-found
```

---

## Prompt 3: Script de despliegue con parámetro de entorno

```
Actualiza el script deploy.ps1 para que acepte un parámetro -Environment develop|production
(por defecto: develop) y use kubectl apply -k con el overlay correspondiente.

Flujo:
1. Infra global: kubectl apply -f k8s/{namespace,secret,keycloak,...}
2. BackEnd infra: kubectl apply -f PeoplePortal-BackEnd/k8s/{configmap,postgres,nats}
3. Esperar Keycloak ready
4. Migraciones (si -SkipMigrations no está): 
   kubectl delete job ... --ignore-not-found
   kubectl apply -k PeoplePortal-BackEnd/k8s/overlays/$Environment
   kubectl wait --for=condition=complete job/peopleportal-migrations
5. API: kubectl apply -k PeoplePortal-BackEnd/k8s/overlays/$Environment
   kubectl rollout restart deployment/peopleportal-api
6. Frontends:
   Crear/renovar ghcr-secret con gh auth token
   kubectl apply -k PeoplePortal-FrontEnd-Colaborador/k8s/overlays/$Environment
   kubectl apply -k PeoplePortal-FrontEnd-RRHH/k8s/overlays/$Environment
   kubectl rollout restart deployment/frontend-colaborador
   kubectl rollout restart deployment/frontend-rrhh
7. Esperar rollout status

El rollout restart es necesario porque con branch tags estables (:develop/:main),
K8s no detecta cambio de imagen aunque el CI haya publicado nueva versión.
imagePullPolicy:Always garantiza que el nuevo pod baje la imagen más reciente del tag.
```
