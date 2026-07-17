# Prompt — Seguridad y OWASP

## Contexto
Aplicación PeoplePortal. Mapeo contra OWASP Top 10 (2021).
Auth: **AuthContext con ROPC** (formulario login propio → Keycloak token endpoint).
JWT Bearer para API. APISIX como Gateway.

---

## Prompt 1: Mapeo OWASP Top 10

```
Actúa como un experto en ciberseguridad. Analiza la arquitectura de PeoplePortal y genera
un documento Markdown (seguridad.md) que mapee las protecciones del sistema contra los riesgos
del OWASP Top 10 (2021).

Arquitectura relevante:
- .NET 9 API con EF Core, parámetros fuertemente tipados, FluentValidation
- Keycloak 24: JWT Bearer. Auth en frontends: ROPC (formulario propio, token directo)
- APISIX Gateway: oculta servicios internos, CORS configurado
- React 19: escapa HTML por defecto, sin dangerouslySetInnerHTML
- Trivy para escaneo de vulnerabilidades en contenedores (CI/CD)
- GHCR (imágenes públicas, firmadas automáticamente por GitHub Actions)
- Secretos K8s para credenciales de base de datos y Keycloak

Cubre las categorías: A01 (Broken Access Control), A02 (Cryptographic Failures),
A03 (Injection), A05 (Security Misconfiguration), A07 (Identification and Authentication Failures),
A08 (Software and Data Integrity Failures).
```
