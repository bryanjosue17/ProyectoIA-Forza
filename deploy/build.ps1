param(
    [string]$ImageTag = "latest"
)

$ErrorActionPreference = "Stop"

Write-Host "===== Building all PeoplePortal images =====" -ForegroundColor Cyan

# Backend API
Write-Host "`n[1/4] Building peopleportal-api:${ImageTag}..." -ForegroundColor Yellow
docker compose -f ../docker-compose.yml build api

# Backend Migrations
Write-Host "`n[2/4] Building peopleportal-api-migrations:${ImageTag}..." -ForegroundColor Yellow
docker compose -f ../docker-compose.yml build migrations

# Frontend Colaborador
Write-Host "`n[3/4] Building peopleportal-frontend-colaborador:${ImageTag}..." -ForegroundColor Yellow
docker compose -f ../docker-compose.yml build frontend-colaborador

# Frontend RRHH
Write-Host "`n[4/4] Building peopleportal-frontend-rrhh:${ImageTag}..." -ForegroundColor Yellow
docker compose -f ../docker-compose.yml build frontend-rrhh

# Tag images
$images = @(
    "peopleportal-api",
    "peopleportal-api-migrations",
    "peopleportal-frontend-colaborador",
    "peopleportal-frontend-rrhh"
)

foreach ($img in $images) {
    if ($ImageTag -ne "latest") {
        docker tag "${img}:latest" "${img}:${ImageTag}"
    }
}

Write-Host "`n===== Build complete! =====" -ForegroundColor Green
Write-Host ""
Write-Host "Images built:" -ForegroundColor Cyan
foreach ($img in $images) {
    Write-Host "  - ${img}:${ImageTag}" -ForegroundColor White
}
