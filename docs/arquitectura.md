# PeoplePortal — Arquitectura Global

## Visión general del sistema

PeoplePortal es una plataforma de autoservicio para colaboradores y RRHH, compuesta por tres servicios independientes coordinados a través de Kubernetes y un API Gateway.

```mermaid
flowchart TB
    subgraph Browser["Navegador del usuario"]
        ColabApp["PeoplePortal-FrontEnd-Colaborador\nReact 19 + Vite\n:30081"]
        RRHHApp["PeoplePortal-FrontEnd-RRHH\nReact 19 + Vite\n:30082"]
    end

    subgraph K8s["Kubernetes — namespace: peopleportal"]
        subgraph Auth["Autenticación"]
            KC["Keycloak 24\n:30080 (NodePort)"]
        end

        subgraph Gateway["API Gateway"]
            APISIX["APISIX\n:30090 (NodePort)"]
        end

        subgraph Backend["Backend"]
            API[".NET 9 API\nClean Architecture + CQRS"]
            NATS["NATS JetStream\n:4222"]
        end

        subgraph Data["Persistencia"]
            SQL["PostgreSQL 16\n:5432"]
        end
    end

    ColabApp -->|ROPC Login| KC
    RRHHApp  -->|ROPC Login| KC
    ColabApp -->|proxy nginx /api/| API
    RRHHApp  -->|proxy nginx /api/| API
    API      --> KC
    API      --> SQL
    API      --> NATS
    APISIX   --> API
```

---

## Diagrama C4 Nivel 2: Contenedores

Este diagrama detalla los contenedores principales del sistema, sus responsabilidades tecnológicas y cómo interactúan internamente dentro del clúster Kubernetes.

```mermaid
C4Context
    title Diagrama C4 Nivel 2 - Contenedores de PeoplePortal

    Person(colaborador, "Colaborador", "Empleado de la empresa.")
    Person(rrhh, "RRHH / Admin", "Personal de RRHH y Administradores.")

    System_Boundary(c1, "PeoplePortal (K8s Namespace: peopleportal)") {
        
        Container(spa_colab, "Portal Colaborador", "React 19, Vite", "Aplicación web SPA (Single Page Application) donde los empleados gestionan sus solicitudes.")
        Container(spa_rrhh, "Panel RRHH", "React 19, Vite", "Aplicación web SPA para la administración centralizada de empleados y documentos.")
        
        Container(apisix, "APISIX Gateway", "Apache APISIX", "API Gateway que enruta el tráfico hacia el backend y valida tokens de sesión.")
        
        Container(keycloak, "Servidor de Identidad", "Keycloak 24", "Servidor OIDC/OAuth2 para gestión de usuarios, login centralizado y roles (RBAC).")
        
        Container(api_backend, "PeoplePortal API", ".NET 9", "Backend monolito modular con Clean Architecture y CQRS (MediatR). Procesa la lógica de negocio.")
        
        ContainerDb(db, "Base de Datos", "PostgreSQL 16", "Almacenamiento relacional persistente (con PVC) de todos los datos del negocio.")
        
        ContainerQueue(nats, "NATS JetStream", "NATS", "Bus de mensajes (Event Bus) para comunicación asíncrona y publicación de eventos de dominio.")
    }

    Rel(colaborador, spa_colab, "Accede a", "HTTPS")
    Rel(rrhh, spa_rrhh, "Administra desde", "HTTPS")
    
    Rel(spa_colab, keycloak, "Autenticación (SSO)", "OIDC / PKCE S256")
    Rel(spa_rrhh, keycloak, "Autenticación (SSO)", "OIDC / PKCE S256")
    
    Rel(spa_colab, apisix, "Llamadas API REST", "JSON/HTTPS")
    Rel(spa_rrhh, apisix, "Llamadas API REST", "JSON/HTTPS")
    
    Rel(apisix, api_backend, "Enruta tráfico", "HTTP")
    
    Rel(api_backend, db, "Lee y Escribe", "EF Core / TCP")
    Rel(api_backend, nats, "Publica eventos de dominio", "NATS Client / TCP")
    Rel(api_backend, keycloak, "Valida firmas de JWT y consulta metadatos", "HTTP")
```

---

## Puertos NodePort (K8s local — Docker Desktop)

| Servicio | Puerto | URL |
|---|---|---|
| Keycloak | 30080 | `http://localhost:30080` |
| Frontend Colaborador | 30081 | `http://localhost:30081` |
| Frontend RRHH | 30082 | `http://localhost:30082` |
| APISIX Gateway | 30090 | `http://localhost:30090` |
| API Backend (Swagger) | 30099 | `http://localhost:30099/swagger/index.html` |

---

## Roles de Keycloak

| Rol | Descripción | Portal de acceso |
|---|---|---|
| `employee` | Colaborador — consulta su información y crea solicitudes | Colaborador |
| `jefe_inmediato` | Jefe — aprueba solicitudes de su equipo | Colaborador |
| `hr` | RRHH — acceso completo al panel administrativo | RRHH |
| `nomina` | Nómina — carga vouchers de pago | RRHH |
| `admin` | Administrador — usuarios, roles y configuración | RRHH |

---

## Estructura del repositorio raíz

```
ProyectoIA-Forza/
├── README.md                          ← Descripción general del proyecto
├── CONTRIBUTING.md                    ← Guía de contribución global
├── docker-compose.yml                 ← Build de imágenes
├── docs/                              ← Documentación global
│   ├── README.md
│   ├── arquitectura.md                ← Este archivo
│   ├── despliegue.md
│   ├── plan-implementacion.md
│   └── adr/                           ← Architecture Decision Records
│
├── k8s/                               ← Manifiestos globales
│   ├── namespace.yaml
│   ├── secret.yaml
│   ├── keycloak.yaml
│   ├── keycloak-realm-configmap.yaml
│   ├── apisix.yaml
│   ├── apisix-configmap.yaml
│   └── ingress.yaml
│
├── deploy/                            ← Scripts build + deploy
│   ├── build.ps1
│   └── deploy.ps1
│
├── PeoplePortal-BackEnd/              ← Submódulo: .NET 9 API
│   └── docs/ → ver PeoplePortal-BackEnd/docs/README.md
│
├── PeoplePortal-FrontEnd-Colaborador/ ← Submódulo: React portal empleado
│   └── docs/ → ver PeoplePortal-FrontEnd-Colaborador/docs/README.md
│
└── PeoplePortal-FrontEnd-RRHH/        ← Submódulo: React panel RRHH
    └── docs/ → ver PeoplePortal-FrontEnd-RRHH/docs/README.md
```

---

## Documentación por subproyecto

| Subproyecto | Documentación técnica |
|---|---|
| Backend | [PeoplePortal-BackEnd/docs/](../PeoplePortal-BackEnd/docs/README.md) |
| Frontend Colaborador | [PeoplePortal-FrontEnd-Colaborador/docs/](../PeoplePortal-FrontEnd-Colaborador/docs/README.md) |
| Frontend RRHH | [PeoplePortal-FrontEnd-RRHH/docs/](../PeoplePortal-FrontEnd-RRHH/docs/README.md) |
