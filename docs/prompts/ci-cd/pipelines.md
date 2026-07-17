# Prompt — CI/CD y Workflows

## Contexto
Monorepo con submódulos. Cada submódulo tiene su propio workflow de GitHub Actions.
Análisis de código con Codacy, escaneo de vulnerabilidades con Trivy.
Imágenes publicadas en GHCR (`ghcr.io/bryanjosue17/...`) con tags `{branch}` y `{short-sha}`.

---

## Prompt 1: CI Pipeline completo para Frontend React + Vite (con GHCR)

```
Genera el workflow ci.yml para un proyecto React 19 + Vite (PeoplePortal-FrontEnd-RRHH)
con 2 jobs:

1. build-test (push/PR a cualquier rama):
   - checkout
   - setup Node.js 20
   - npm ci
   - npm run lint (oxlint, falla si hay errores)
   - npm run test:coverage (Vitest con cobertura, upload a Codacy)
   - npm run build (verifica que Vite compila)

2. docker (solo en push a develop o main, depende de build-test exitoso):
   - checkout
   - setup Docker Buildx
   - Login a GHCR con GITHUB_TOKEN
   - Calcular tags: BRANCH_TAG=nombre-de-rama, SHORT_SHA=7 primeros chars del SHA
   - Build y push imagen: ghcr.io/{owner}/peopleportal-frontend-rrhh:{BRANCH_TAG}
     y ghcr.io/{owner}/peopleportal-frontend-rrhh:{SHORT_SHA}
   - Build args: VITE_API_URL='' VITE_KEYCLOAK_URL=''
     (URLs se configuran en K8s/nginx, no en la imagen)

Variables de entorno del repo: CODACY_PROJECT_TOKEN
```

---

## Prompt 2: CI Pipeline para Backend .NET 9 (con Trivy + GHCR)

```
Genera ci.yml para el backend .NET 9 de PeoplePortal con:

1. build-test:
   - checkout
   - setup .NET 9
   - dotnet restore + build
   - dotnet test --collect:'XPlat Code Coverage'
   - Upload cobertura a Codacy
   - Trivy scan del código fuente (HIGH,CRITICAL)

2. docker (push a develop/main):
   - Build imagen peopleportal-api con Dockerfile multi-stage
   - Build imagen peopleportal-api-migrations (misma base, target=migrations)
   - Push ambas a ghcr.io/{owner}/... con tags {branch} y {short-sha}
   - Login con GITHUB_TOKEN

3. Trivy scan de la imagen resultante (post-push)
```

---

## Prompt 3: Workflow de actualizar submódulos en el monorepo

```
Genera un workflow para el repositorio raíz ProyectoIA-Forza que actualice
automáticamente los punteros de submódulos cuando alguno de los repos hijos
hace push a su rama main o develop.

El workflow debe:
1. Hacer checkout con submodules: recursive
2. Para cada submódulo: git -C {submodule} fetch origin && git -C {submodule} checkout {rama}
3. Hacer commit de los nuevos punteros si cambiaron
4. Push a la rama correspondiente del monorepo

Usar matrix para manejar develop y main por separado.
```

```
Genera un workflow de GitHub Actions (ci.yml) para un proyecto React 19 + Vite
(PeoplePortal-FrontEnd-RRHH) que se ejecute en push y pull_request a develop y main.

El pipeline debe contener 2 jobs:

1. build-and-test:
   - runs-on: ubuntu-latest
   - checkout del código
   - setup de Node.js 22
   - npm ci
   - npm test (ejecutar Vitest)
   - npm run build (verificar que el build de Vite pasa correctamente)

2. security-scan:
   - runs-on: ubuntu-latest
   - checkout del código
   - ejecutar aquasecurity/trivy-action para escanear el directorio raíz buscando
     vulnerabilidades en package-lock.json de severidad HIGH,CRITICAL.
```
