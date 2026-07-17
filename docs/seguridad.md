# Seguridad — PeoplePortal BackEnd

## Mapeo OWASP Top 10

| # | Riesgo OWASP | Descripción del riesgo | Mitigación implementada |
|---|---|---|---|
| A01 | Broken Access Control | Usuarios acceden a recursos no autorizados | Keycloak con roles (`employee`, `jefe_inmediato`, `hr`, `nomina`, `admin`); policies por endpoint; validación de `employeeId` vs JWT `sub` |
| A02 | Cryptographic Failures | Datos sensibles expuestos en tránsito o reposo | JWT firmado por Keycloak; HTTPS en producción; `RequireHttpsMetadata` activo fuera de `Development`; secrets en K8s Secrets / env vars |
| A03 | Injection | SQL injection / code injection | EF Core parametriza todas las consultas; sin raw SQL; FluentValidation valida entradas antes de llegar al dominio |
| A04 | Insecure Design | Lógica de negocio insegura | Domain entities con factory methods que validan invariantes; CQRS separa commands de queries; sin lógica en controladores |
| A05 | Security Misconfiguration | Configuraciones inseguras o expuestas | APISIX como único punto de entrada externo; CORS configurado explícitamente; `environment-specific configs`; sin Swagger en producción |
| A06 | Vulnerable Components | Dependencias con vulnerabilidades conocidas | Trivy scan en CI/CD en cada PR; NuGet packages actualizados; dependabot activo |
| A07 | Authentication Failures | Autenticación débil o bypasseable | Frontends usan ROPC directo al endpoint de token de Keycloak (formulario propio); JWT Bearer con validación de `audience + issuer + signing key`; tokens de corta vida con refresh automático |
| A08 | Integrity Failures | Integridad de datos o software comprometida | EF Core migrations versionadas; Conventional Commits; branch protection en `develop` y `main` |
| A09 | Logging & Monitoring Failures | Falta de monitoreo o logs | NATS eventos de dominio auditables; health checks en `/health`; logs estructurados con ILogger |
| A10 | SSRF | Server-Side Request Forgery | El backend no realiza requests a URLs externas controladas por el cliente |

---

## Gestión de secretos

| Regla | Detalle |
|---|---|
| **Nunca en el repositorio** | `.env`, connection strings y tokens excluidos por `.gitignore` |
| **Variables de entorno** | Siempre vía env vars o K8s Secrets |
| **Connection strings** | Sin hardcode — lanzan excepción si la env var no existe |
| **JWT secrets** | Manejados por Keycloak; la API solo valida, no firma |
| **SA_PASSWORD / POSTGRES_PASSWORD** | Solo en K8s Secret (`secret.yaml`) o en env local, nunca committed |

---

## Políticas de autorización (Program.cs)

```csharp
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("EmployeePolicy", p => p.RequireRole("employee"));
    options.AddPolicy("ManagerPolicy", p => p.RequireRole("jefe_inmediato"));
    options.AddPolicy("HrPolicy",      p => p.RequireRole("hr"));
    options.AddPolicy("NominaPolicy",  p => p.RequireRole("nomina"));
    options.AddPolicy("AdminPolicy",   p => p.RequireRole("admin"));
});
```

Los roles se extraen del claim `realm_access.roles` del JWT de Keycloak y se mapean a `ClaimTypes.Role` en `OnTokenValidated`.
