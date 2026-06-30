#!/usr/bin/env bash
set -euo pipefail

BUILD=false
SKIP_MIGRATIONS=false
IMAGE_TAG="latest"
K8S_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/k8s"

usage() {
    echo "Usage: $0 [--build] [--skip-migrations] [--tag <tag>]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build) BUILD=true ;;
        --skip-migrations) SKIP_MIGRATIONS=true ;;
        --tag) IMAGE_TAG="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

if [ "$BUILD" = true ]; then
    echo "===== Building images ====="
    docker compose -f docker-compose.yml build
fi

echo "===== Deploying PeoplePortal to Kubernetes ====="

# Infrastructure
echo -e "\n[Phase 1] Deploying infrastructure..."
for f in namespace configmap secret apisix-configmap sqlserver nats keycloak; do
    echo "  Applying ${f}.yaml..."
    kubectl apply -f "${K8S_DIR}/${f}.yaml"
done

echo "Waiting for SQL Server..."
kubectl wait --for=condition=ready pod -l app=sqlserver -n peopleportal --timeout=300s

echo "Waiting for Keycloak..."
kubectl wait --for=condition=ready pod -l app=keycloak -n peopleportal --timeout=300s

# Migrations
if [ "$SKIP_MIGRATIONS" = false ]; then
    echo -e "\n[Phase 2] Running migrations..."
    kubectl apply -f "${K8S_DIR}/migration-job.yaml"
    kubectl wait --for=condition=complete job/peopleportal-migrations -n peopleportal --timeout=180s
fi

# Applications
echo -e "\n[Phase 3] Deploying applications..."
for f in api frontend-colaborador frontend-rrhh apisix; do
    echo "  Applying ${f}.yaml..."
    kubectl apply -f "${K8S_DIR}/${f}.yaml"
done

# Ingress
if [ -f "${K8S_DIR}/ingress.yaml" ]; then
    echo -e "\n[Phase 4] Applying Ingress..."
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
