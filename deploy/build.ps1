param(
    [string]$ImageTag = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent

# Si no se provee tag, usar git short SHA para garantizar rolling update automático
if (-not $ImageTag) {
    $ImageTag = (git -C $Root rev-parse --short HEAD 2>$null) -replace '\s',''
    if (-not $ImageTag) { $ImageTag = "latest" }
}

Write-Host "Image tag: $ImageTag" -ForegroundColor DarkGray
Write-Host "===== Building all PeoplePortal images =====" -ForegroundColor Cyan

# Backend API
Write-Host "`n[1/4] Building peopleportal-api:${ImageTag}..." -ForegroundColor Yellow
docker compose -f "$Root/docker-compose.yml" build api

# Backend Migrations
Write-Host "`n[2/4] Building peopleportal-api-migrations:${ImageTag}..." -ForegroundColor Yellow
docker compose -f "$Root/docker-compose.yml" build migrations

# Frontend Colaborador — built directly from its directory to avoid Windows/WSL context staleness
Write-Host "`n[3/4] Building peopleportal-frontend-colaborador:${ImageTag}..." -ForegroundColor Yellow
Push-Location "$Root/PeoplePortal-FrontEnd-Colaborador"
docker build --no-cache `
    --build-arg VITE_API_URL="" `
    --build-arg VITE_KEYCLOAK_URL="http://localhost:30080" `
    -t "peopleportal-frontend-colaborador:${ImageTag}" .
Pop-Location

# Frontend RRHH — same approach
Write-Host "`n[4/4] Building peopleportal-frontend-rrhh:${ImageTag}..." -ForegroundColor Yellow
Push-Location "$Root/PeoplePortal-FrontEnd-RRHH"
docker build --no-cache `
    --build-arg VITE_API_URL="" `
    --build-arg VITE_KEYCLOAK_URL="http://localhost:30080" `
    -t "peopleportal-frontend-rrhh:${ImageTag}" .
Pop-Location

Write-Host "`n===== Build complete! =====" -ForegroundColor Green
Write-Host ""
Write-Host "Images built:" -ForegroundColor Cyan
@("peopleportal-api", "peopleportal-api-migrations", "peopleportal-frontend-colaborador", "peopleportal-frontend-rrhh") | ForEach-Object {
    Write-Host "  - ${_}:${ImageTag}" -ForegroundColor White
}
