# PeoplePortal — Documentación Global

Bienvenido al directorio de documentación del **repositorio raíz** de PeoplePortal.  
Aquí vive únicamente documentación que aplica al **sistema completo** (infraestructura, arquitectura global, despliegue, E2E testing).

Cada submódulo tiene su propia carpeta `docs/` con su documentación interna:

| Subproyecto | Documentación |
|---|---|
| Backend (.NET 9) | [PeoplePortal-BackEnd/docs/](https://github.com/bryanjosue17/PeoplePortal-BackEnd/tree/main/docs) |
| Frontend Colaborador (React 19) | [PeoplePortal-FrontEnd-Colaborador/docs/](https://github.com/bryanjosue17/PeoplePortal-FrontEnd-Colaborador/tree/main/docs) |
| Frontend RRHH (React 19) | [PeoplePortal-FrontEnd-RRHH/docs/](https://github.com/bryanjosue17/PeoplePortal-FrontEnd-RRHH/tree/main/docs) |

---

## Documentación global

| Documento | Descripción |
|---|---|
| [arquitectura.md](./arquitectura.md) | Diagrama del sistema completo: componentes, puertos K8s, roles Keycloak |
| [base-de-datos.md](./base-de-datos.md) | Modelo Entidad-Relación (ER Diagram) |
| [flujos.md](./flujos.md) | Diagramas de secuencia: login, solicitudes, aprobaciones |
| [despliegue.md](./despliegue.md) | Guía de despliegue end-to-end: build → K8s → verificación |
| [seguridad.md](./seguridad.md) | Mapeo OWASP Top 10 |
| [playwright.md](./playwright.md) | Pruebas E2E con Playwright: instalación, ejecución, POM, capturas |
| [video-demo.md](./video-demo.md) | Video demostrativo del sistema en funcionamiento (5–8 min) |
| [plan-implementacion.md](./plan-implementacion.md) | Estado del proyecto: completado, pendiente y criterios de cierre |
| [ENTREGABLES.md](./ENTREGABLES.md) | Checklist de entregables del curso con enlaces a artefactos |
| [adr/001-react-en-lugar-de-angular.md](./adr/001-react-en-lugar-de-angular.md) | Decision Record: por qué se usa React 19 en lugar de Angular |

## Manuales técnicos por aplicación

| Aplicación | Documento |
|---|---|
| Portal RRHH (Administración) | [`rrhh/manual-tecnico.md`](./rrhh/manual-tecnico.md) |
| Portal Colaborador (Empleados) | [`colaborador/manual-tecnico.md`](./colaborador/manual-tecnico.md) |
