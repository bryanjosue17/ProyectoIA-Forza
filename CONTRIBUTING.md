# Contribuir a ProyectoIA-Forza

Gracias por contribuir. Este documento describe el flujo de trabajo recomendado para el repositorio raíz y sus submódulos.

---

## Ramas

| Rama | Propósito |
|---|---|
| `main` | Rama estable — solo recibe merges desde `develop` |
| `develop` | Rama de integración — trabajo diario y PRs |
| `feat/<nombre>` | Features nuevas, se crean desde `develop` |
| `fix/<nombre>` | Correcciones de bugs, se crean desde `develop` |

---

## Flujo de trabajo

### 1. Clonar con submódulos

```bash
git clone --recurse-submodules https://github.com/bryanjosue17/ProyectoIA-Forza.git
cd ProyectoIA-Forza
git checkout develop
```

### 2. Trabajar en un submódulo

```bash
cd PeoplePortal-BackEnd   # o FrontEnd-Colaborador / FrontEnd-RRHH
git checkout develop
git pull origin develop
git checkout -b feat/mi-cambio
# ... hacer cambios ...
git add .
git commit -m "feat(api): descripción del cambio"
git push origin feat/mi-cambio
```

### 3. Abrir Pull Request

Abrir PR en el repositorio del **submódulo** desde `feat/mi-cambio` hacia `develop`.  
Requisitos para merge:
- CI/CD pipeline en verde (build + tests + lint + Codacy + Trivy)
- Code review de al menos 1 persona
- Sin issues Críticos ni Altos en Codacy

### 4. Actualizar referencia en la raíz

Una vez mergeado el PR en el submódulo:

```bash
# Desde la raíz del repositorio
git submodule foreach 'git fetch origin && git checkout develop && git pull origin develop'
git add PeoplePortal-BackEnd PeoplePortal-FrontEnd-Colaborador PeoplePortal-FrontEnd-RRHH
git commit -m "chore: update submodule refs"
git push origin develop
```

---

## Conventional Commits

Formato: `<tipo>(<alcance>): <descripción breve>`

| Tipo | Uso |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `refactor` | Cambio de código sin nueva funcionalidad ni bug fix |
| `test` | Agregar o modificar tests |
| `docs` | Cambios en documentación |
| `chore` | Mantenimiento, CI/CD, configuraciones |
| `style` | Formato o linting (sin cambio de lógica) |
| `perf` | Mejora de rendimiento |

### Ejemplos

```
feat(api): add employee profile endpoint
fix(db): correct migration column type
docs(readme): update setup instructions
chore(ci): add trivy scan to pipeline
test(requests): add handler unit tests
```

---

## Protección de ramas

- La rama `develop` está protegida en los 3 repositorios de código.
- Se requiere PR + aprobación para hacer merge.
- No se permiten force-push en `develop` ni `main`.

---

## Notas sobre submódulos

- Cada submódulo mantiene su propio historial de commits, ramas y políticas.
- Revisa el `README.md` de cada submódulo para ver sus instrucciones específicas.
- Los submódulos tienen su propia carpeta `docs/` con documentación técnica interna.
