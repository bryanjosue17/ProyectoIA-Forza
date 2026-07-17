#!/usr/bin/env bash
set -euo pipefail

BUILD=false
SKIP_MIGRATIONS=false
IMAGE_TAG="latest"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL_K8S="$ROOT/k8s"
BACKEND_K8S="$ROOT/PeoplePortal-BackEnd/k8s"
COLAB_K8S="$ROOT/PeoplePortal-FrontEnd-Colaborador/k8s"
RRHH_K8S="$ROOT/PeoplePortal-FrontEnd-RRHH/k8s"

usage() {
    echo "Usage: $0 [--build] [--skip-migrations] [--tag <tag>]"
    echo ""
    echo "  --build             Build Docker images before deploying"
    echo "  --skip-migrations   Skip the database migration job"
    echo "  --tag <tag>         Docker image tag (default: latest)"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build)            BUILD=true ;;
        --skip-migrations)  SKIP_MIGRATIONS=true ;;
        --tag)              IMAGE_TAG="$2"; shift ;;
        -h|--help)          usage ;;
        *)                  echo "Unknown option: $1"; usage ;;
    esac
    shift
done

# ── Build ─────────────────────────────────────────────────────────────────────
if [ "$BUILD" = true ]; then
    echo "===== Building all PeoplePortal images ====="

    echo -e "\n[1/4] Building peopleportal-api:${IMAGE_TAG}..."
    docker compose -f "$ROOT/docker-compose.yml" build api

    echo -e "\n[2/4] Building peopleportal-api-migrations:${IMAGE_TAG}..."
    docker compose -f "$ROOT/docker-compose.yml" build migrations

    echo -e "\n[3/4] Building peopleportal-frontend-colaborador:${IMAGE_TAG}..."
    pushd "$ROOT/PeoplePortal-FrontEnd-Colaborador" > /dev/null
    docker build --no-cache \
        --build-arg VITE_API_URL="" \
        --build-arg VITE_KEYCLOAK_URL="http://localhost:30080" \
        -t "peopleportal-frontend-colaborador:${IMAGE_TAG}" .
    popd > /dev/null

    echo -e "\n[4/4] Building peopleportal-frontend-rrhh:${IMAGE_TAG}..."
    pushd "$ROOT/PeoplePortal-FrontEnd-RRHH" > /dev/null
    docker build --no-cache \
        --build-arg VITE_API_URL="" \
        --build-arg VITE_KEYCLOAK_URL="http://localhost:30080" \
        -t "peopleportal-frontend-rrhh:${IMAGE_TAG}" .
    popd > /dev/null

    echo -e "\n===== Build complete! ====="
fi

echo -e "\n===== Deploying PeoplePortal to Kubernetes ====="

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

# ── Phase 3: Database migrations ──────────────────────────────────────────────
if [ "$SKIP_MIGRATIONS" = false ]; then
    echo -e "\n[Phase 3] Running database migrations..."
    kubectl apply -f "$BACKEND_K8S/migration-job.yaml"
    kubectl wait --for=condition=complete job/peopleportal-migrations \
        -n peopleportal --timeout=180s
fi

# ── Phase 4: API ──────────────────────────────────────────────────────────────
echo -e "\n[Phase 4] Deploying API..."
kubectl apply -f "$BACKEND_K8S/api.yaml"

# ── Phase 5: Frontends ────────────────────────────────────────────────────────
echo -e "\n[Phase 5] Deploying Frontends..."
kubectl apply -f "$COLAB_K8S/frontend-colaborador.yaml"
kubectl apply -f "$RRHH_K8S/frontend-rrhh.yaml"

# rollout restart forces pods to pick up the newly built :latest image,
# because imagePullPolicy: Never + same tag means kubectl apply alone
# does NOT trigger a pod replacement.
echo "  Rolling out frontend pods to apply new images..."
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
