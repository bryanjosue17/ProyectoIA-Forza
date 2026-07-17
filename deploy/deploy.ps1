param(
    [switch]$Build,           # Legacy: construir imagenes localmente en lugar de usar GHCR
    [string]$ImageTag = "",
    [ValidateSet("develop","production")]
    [string]$Environment = "develop",  # develop = imagen :develop (local); production = :main
    [switch]$SkipMigrations
)

$ErrorActionPreference = "Stop"
$Root       = Split-Path $PSScriptRoot -Parent
$GlobalK8s  = Join-Path $Root "k8s"
$BackEndK8s = Join-Path $Root "PeoplePortal-BackEnd\k8s"
$ColabK8s   = Join-Path $Root "PeoplePortal-FrontEnd-Colaborador\k8s"
$RrhhK8s    = Join-Path $Root "PeoplePortal-FrontEnd-RRHH\k8s"
$GHCR       = "ghcr.io/bryanjosue17"

# ── Resolver tags de imagen ──────────────────────────────────────────────────
function Get-CiSha {
    param([string]$Repo)
    $sha = (gh run list --repo "bryanjosue17/$Repo" --branch main --status success --limit 1 `
            --json headSha --jq ".[0].headSha[0:7]" 2>$null) -replace '\s',''
    if ($sha) { return $sha } else { return "main" }
}

if ($Build) {
    # Modo legacy: build local con git SHA del repo raíz
    if (-not $ImageTag) {
        $ImageTag = (git -C $Root rev-parse --short HEAD 2>$null) -replace '\s',''
        if (-not $ImageTag) { $ImageTag = "latest" }
    }
    Write-Host "Image tag: $ImageTag  Environment: $Environment" -ForegroundColor DarkGray
    & (Join-Path $PSScriptRoot "build.ps1") -ImageTag $ImageTag
    $ColabImage = "peopleportal-frontend-colaborador:${ImageTag}"
    $RrhhImage  = "peopleportal-frontend-rrhh:${ImageTag}"
    $ApiImage   = "peopleportal-api:${ImageTag}"
} else {
    # Modo GHCR: usa el SHA del ultimo CI exitoso en main de cada repo
    Write-Host "Mode: GHCR  (fetching latest CI SHAs...)" -ForegroundColor DarkGray
    $ColabSha = if ($ImageTag) { $ImageTag } else { Get-CiSha "PeoplePortal-FrontEnd-Colaborador" }
    $RrhhSha  = if ($ImageTag) { $ImageTag } else { Get-CiSha "PeoplePortal-FrontEnd-RRHH" }
    $ApiSha   = if ($ImageTag) { $ImageTag } else { Get-CiSha "PeoplePortal-BackEnd" }
    $ColabImage = "${GHCR}/peopleportal-frontend-colaborador:${ColabSha}"
    $RrhhImage  = "${GHCR}/peopleportal-frontend-rrhh:${RrhhSha}"
    $ApiImage   = "${GHCR}/peopleportal-api:${ApiSha}"
    Write-Host "  colaborador : $ColabImage" -ForegroundColor DarkGray
    Write-Host "  rrhh        : $RrhhImage"  -ForegroundColor DarkGray
    Write-Host "  api         : $ApiImage"   -ForegroundColor DarkGray
}

Write-Host "===== Deploying PeoplePortal to Kubernetes =====" -ForegroundColor Cyan

# ── Phase 1: Global infrastructure ─────────────────────────────────────────
Write-Host "`n[Phase 1] Global infrastructure (namespace, secrets, Keycloak, APISIX)..." -ForegroundColor Yellow
@(
    (Join-Path $GlobalK8s "namespace.yaml"),
    (Join-Path $GlobalK8s "secret.yaml"),
    (Join-Path $GlobalK8s "keycloak-realm-configmap.yaml"),
    (Join-Path $GlobalK8s "keycloak.yaml"),
    (Join-Path $GlobalK8s "apisix-configmap.yaml"),
    (Join-Path $GlobalK8s "apisix.yaml")
) | ForEach-Object { Write-Host "  Applying $_..." -ForegroundColor Gray; kubectl apply -f $_ }

# ── Phase 2: Backend services (NATS, configmap) ─────────────────────────────
Write-Host "`n[Phase 2] Backend services (NATS, configmap)..." -ForegroundColor Yellow
@(
    (Join-Path $BackEndK8s "configmap.yaml"),
    (Join-Path $BackEndK8s "nats.yaml")
) | ForEach-Object { Write-Host "  Applying $_..." -ForegroundColor Gray; kubectl apply -f $_ }

Write-Host "Waiting for Keycloak to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=keycloak -n peopleportal --timeout=300s

# ── Phase 3: Database migrations ──────────────────────────────────────────
if (-not $SkipMigrations) {
    Write-Host "`n[Phase 3] Running database migrations (overlay: $Environment)..." -ForegroundColor Yellow
    # Eliminar job previo (completado) para permitir re-ejecución limpia
    kubectl delete job peopleportal-migrations --ignore-not-found -n peopleportal | Out-Null
    kubectl apply -k (Join-Path $BackEndK8s "overlays\$Environment")
    kubectl wait --for=condition=complete job/peopleportal-migrations -n peopleportal --timeout=180s
}

# ── Phase 4: API ───────────────────────────────────────────────────────────
Write-Host "`n[Phase 4] Deploying API (overlay: $Environment)..." -ForegroundColor Yellow
kubectl apply -k (Join-Path $BackEndK8s "overlays\$Environment")
Write-Host "  Rolling out API pods..." -ForegroundColor Gray
kubectl rollout restart deployment/peopleportal-api -n peopleportal

# ── Phase 5: Frontends ────────────────────────────────────────────────────
Write-Host "`n[Phase 5] Deploying Frontends (overlay: $Environment)..." -ForegroundColor Yellow

# Crear/actualizar imagePullSecret para GHCR
Write-Host "  Updating GHCR imagePullSecret..." -ForegroundColor Gray
$GhToken = (gh auth token 2>$null) -replace '\s',''
if ($GhToken) {
    kubectl create secret docker-registry ghcr-secret `
        --docker-server=ghcr.io `
        --docker-username=bryanjosue17 `
        --docker-password=$GhToken `
        --namespace=peopleportal `
        --dry-run=client -o yaml | kubectl apply -f - | Out-Null
}

# Aplicar overlays via Kustomize
kubectl apply -k (Join-Path $ColabK8s "overlays\$Environment")
kubectl apply -k (Join-Path $RrhhK8s  "overlays\$Environment")

# rollout restart fuerza nuevos pods que tiran imagen con imagePullPolicy:Always
Write-Host "  Rolling out frontend pods (env=$Environment)..." -ForegroundColor Gray
kubectl rollout restart deployment/frontend-colaborador -n peopleportal
kubectl rollout restart deployment/frontend-rrhh        -n peopleportal

# ── Phase 6: Ingress (optional) ────────────────────────────────────────────
$ingressPath = Join-Path $GlobalK8s "ingress.yaml"
if (Test-Path $ingressPath) {
    Write-Host "`n[Phase 6] Applying Ingress..." -ForegroundColor Yellow
    kubectl apply -f $ingressPath
}

Write-Host "`nWaiting for all pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=peopleportal-api     -n peopleportal --timeout=120s
kubectl rollout status deployment/frontend-colaborador              -n peopleportal --timeout=120s
kubectl rollout status deployment/frontend-rrhh                    -n peopleportal --timeout=120s

Write-Host "`n===== Deployment complete! =====" -ForegroundColor Green
Write-Host ""
Write-Host "Services:" -ForegroundColor Cyan
Write-Host "  Frontend Colaborador: http://localhost:30081" -ForegroundColor White
Write-Host "  Frontend RRHH:        http://localhost:30082" -ForegroundColor White
Write-Host "  Keycloak:             http://localhost:30080" -ForegroundColor White
Write-Host "  APISIX Gateway:       http://localhost:30090" -ForegroundColor White
Write-Host ""
Write-Host "To check status:" -ForegroundColor Cyan
Write-Host "  kubectl get pods -n peopleportal" -ForegroundColor White
Write-Host "  kubectl get svc -n peopleportal" -ForegroundColor White
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Cyan
Write-Host "  kubectl logs -n peopleportal deploy/peopleportal-api -f" -ForegroundColor White
