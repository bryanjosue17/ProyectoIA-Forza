# Prompt: Diagrama C4 del sistema

## Contexto
PeoplePortal — portal de autoservicio para colaboradores y RRHH.
Stack: .NET 9, React 19, Keycloak, APISIX, NATS, SQL Server.

## Prompt usado
"Genera un diagrama C4 en Mermaid para un sistema de autoservicio de RRHH.
Nivel 1 (Contexto): actores (Colaborador, Jefe, RRHH, Nómina, Admin), sistema PeoplePortal, integraciones externas (Keycloak, APISIX, NATS, SQL Server).
Nivel 2 (Contenedores): separar React SPA, .NET 9 API, NATS, SQL Server, Keycloak como contenedores distintos.
Usa flowchart LR para nivel 1 y flowchart TB para nivel 2."

## Resultado
Diagramas generados en `docs/arquitectura.md`, secciones C4 Nivel 1 y C4 Nivel 2.
Nomenclatura corregida: React SPA en lugar de Angular (stack real del proyecto).
