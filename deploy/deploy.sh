#!/usr/bin/env bash
set -euo pipefail

BUILD=false
SKIP_MIGRATIONS=false
IMAGE_TAG=""
ENVIRONMENT="develop"  # develop = imagen :develop (local Docker Desktop) | production = :main
GHCR="ghcr.io/bryanjosue17"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL_K8S="$ROOT/k8s"
BACKEND_K8S="$ROOT/PeoplePortal-BackEnd/k8s"
COLAB_K8S="$ROOT/PeoplePortal-FrontEnd-Colaborador/k8s"
RRHH_K8S="$ROOT/PeoplePortal-FrontEnd-RRHH/k8s"

usage() {
    echo "Usage: $0 [--build] [--skip-migrations] [--tag <tag>]"
    echo ""
    echo "  --build             Legacy: build images locally instead of using GHCR"
    echo "  --skip-migrations   Skip the database migration job"
    echo "  --environment <env> Image environment: develop (default) or production"
    echo "  --tag <tag>         Force a specific image tag (overrides --environment)"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build)            BUILD=true ;;
        --skip-migrations)  SKIP_MIGRATIONS=true ;;
        --environment)      ENVIRONMENT="$2"; shift ;;
        --tag)              IMAGE_TAG="$2"; shift ;;
        -h|--help)          usage ;;
        *)                  echo "Unknown option: $1"; usage ;;
    esac
    shift
done

# ── Resolver tags de imagen ────────────────────────────────────────────────────
get_ci_sha() {
    gh run list --repo "bryanjosue17/$1" --branch main --status success --limit 1 \
        --json headSha --jq ".[0].headSha[0:7]" 2>/dev/null || echo "main"
}

if [ "$BUILD" = true ]; then
    LOCAL_TAG="${IMAGE_TAG:-$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo 'latest')}"
    echo "Mode: LOCAL build  tag=$LOCAL_TAG"
    echo "===== Building all PeoplePortal images ====="

    echo -e "\n[1/4] Building peopleportal-api:${LOCAL_TAG}..."
    docker compose -f "$ROOT/docker-compose.yml" build api

    echo -e "\n[2/4] Building peopleportal-api-migrations:${LOCAL_TAG}..."
    docker compose -f "$ROOT/docker-compose.yml" build migrations

    echo -e "\n[3/4] Building peopleportal-frontend-colaborador:${LOCAL_TAG}..."
    pushd "$ROOT/PeoplePortal-FrontEnd-Colaborador" > /dev/null
    docker build --no-cache \
        --build-arg VITE_API_URL="" \
        --build-arg VITE_KEYCLOAK_URL="http://localhost:30080" \
        -t "peopleportal-frontend-colaborador:${LOCAL_TAG}" .
    popd > /dev/null

    echo -e "\n[4/4] Building peopleportal-frontend-rrhh:${LOCAL_TAG}..."
    pushd "$ROOT/PeoplePortal-FrontEnd-RRHH" > /dev/null
    docker build --no-cache \
        --build-arg VITE_API_URL="" \
        --build-arg VITE_KEYCLOAK_URL="http://localhost:30080" \
        -t "peopleportal-frontend-rrhh:${LOCAL_TAG}" .
    popd > /dev/null

    COLAB_IMAGE="peopleportal-frontend-colaborador:${LOCAL_TAG}"
    RRHH_IMAGE="peopleportal-frontend-rrhh:${LOCAL_TAG}"
    API_IMAGE="peopleportal-api:${LOCAL_TAG}"
    echo -e "\n===== Build complete! ====="
else
    echo "Mode: GHCR  environment=$ENVIRONMENT"
fi

echo -e "\n===== Deploying PeoplePortal to Kubernetes (env=$ENVIRONMENT) ====="

# ── Phase 1: Global infrastructure ───────────────────────────────────────────
echo -e "\n[Phase 1] Global infrastructure (namespace, secrets, Keycloak, APISIX)..."
for f in namespace.yaml secret.yaml keycloak-realm-configmap.yaml keycloak.yaml apisix-configmap.yaml apisix.yaml; do
    echo "  Applying $f..."
    kubectl apply -f "$GLOBAL_K8S/$f"
done

# ── Phase 2: Backend services ─────────────────────────────────────────────────
echo -e "\n[Phase 2] Backend services (PostgreSQL, NATS, configmap)..."
for f in configmap.yaml postgres.yaml nats.yaml; do
    echo "  Applying $f..."
    kubectl apply -f "$BACKEND_K8S/$f"
done

echo "Waiting for Keycloak to be ready..."
kubectl wait --for=condition=ready pod -l app=keycloak -n peopleportal --timeout=300s

# ── Phase 3: Database migrations (via Kustomize overlay) ──────────────────────
if [ "$SKIP_MIGRATIONS" = false ]; then
    echo -e "\n[Phase 3] Running database migrations (overlay: $ENVIRONMENT)..."
    kubectl delete job peopleportal-migrations --ignore-not-found -n peopleportal > /dev/null
    kubectl apply -k "$BACKEND_K8S/overlays/$ENVIRONMENT"
    kubectl wait --for=condition=complete job/peopleportal-migrations \
        -n peopleportal --timeout=180s
fi

# ── Phase 4: API (via Kustomize overlay) ──────────────────────────────────────
echo -e "\n[Phase 4] Deploying API (overlay: $ENVIRONMENT)..."
kubectl apply -k "$BACKEND_K8S/overlays/$ENVIRONMENT"
echo "  Rolling out API pods..."
kubectl rollout restart deployment/peopleportal-api -n peopleportal

# ── Phase 5: Frontends (via Kustomize overlay) ────────────────────────────────
echo -e "\n[Phase 5] Deploying Frontends (overlay: $ENVIRONMENT)..."

# Crear/actualizar imagePullSecret para GHCR
echo "  Updating GHCR imagePullSecret..."
GH_TOKEN=$(gh auth token 2>/dev/null || true)
if [ -n "$GH_TOKEN" ]; then
    kubectl create secret docker-registry ghcr-secret \
        --docker-server=ghcr.io \
        --docker-username=bryanjosue17 \
        --docker-password="$GH_TOKEN" \
        --namespace=peopleportal \
        --dry-run=client -o yaml | kubectl apply -f - > /dev/null
fi

kubectl apply -k "$COLAB_K8S/overlays/$ENVIRONMENT"
kubectl apply -k "$RRHH_K8S/overlays/$ENVIRONMENT"

# rollout restart fuerza nuevos pods que tiran imagen con imagePullPolicy:Always
echo "  Rolling out frontend pods (env=$ENVIRONMENT)..."
kubectl rollout restart deployment/frontend-colaborador -n peopleportal
kubectl rollout restart deployment/frontend-rrhh        -n peopleportal

# ── Phase 6: Ingress (optional) ───────────────────────────────────────────────
if [ -f "$GLOBAL_K8S/ingress.yaml" ]; then
    echo -e "\n[Phase 6] Applying Ingress..."
    kubectl apply -f "$GLOBAL_K8S/ingress.yaml"
fi

# ── Wait for readiness ────────────────────────────────────────────────────────
echo -e "\nWaiting for all pods to be ready..."
kubectl wait --for=condition=ready pod -l app=peopleportal-api -n peopleportal --timeout=120s
kubectl rollout status deployment/frontend-colaborador          -n peopleportal --timeout=120s
kubectl rollout status deployment/frontend-rrhh                -n peopleportal --timeout=120s

echo -e "\n===== Deployment complete! ====="
echo ""
echo "Services:"
echo "  Frontend Colaborador : http://localhost:30081"
echo "  Frontend RRHH        : http://localhost:30082"
echo "  Keycloak             : http://localhost:30080"
echo "  APISIX Gateway       : http://localhost:30090"
echo "  API Backend          : http://localhost:30099"
echo ""
echo "To check status:"
echo "  kubectl get pods -n peopleportal"
echo "  kubectl get svc  -n peopleportal"
echo ""
echo "To view logs:"
echo "  kubectl logs -n peopleportal deploy/peopleportal-api -f"

    kubectl apply -f "${K8S_DIR}/ingress.yaml"
fi

echo "Waiting for all pods..."
kubectl wait --for=condition=ready pod -l app=peopleportal-api -n peopleportal --timeout=120s
kubectl wait --for=condition=ready pod -l app=frontend-colaborador -n peopleportal --timeout=120s
kubectl wait --for=condition=ready pod -l app=frontend-rrhh -n peopleportal --timeout=120s

echo -e "\n===== Deployment complete! ====="
echo ""
echo "Services:"
echo "  Frontend Colaborador: http://localhost:30081"
echo "  Frontend RRHH:        http://localhost:30082"
echo "  Keycloak:             http://localhost:30080"
echo "  APISIX Gateway:       http://localhost:30090"
