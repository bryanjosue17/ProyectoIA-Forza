# PeoplePortal — Documentación Global

Bienvenido al directorio de documentación del **repositorio raíz** de PeoplePortal.  
Aquí vive únicamente documentación que aplica al **sistema completo** (infraestructura, arquitectura global, despliegue).

Cada submódulo tiene su propia carpeta `docs/` con su documentación interna:

| Subproyecto | Documentación |
|---|---|
| Backend (.NET 9) | [`PeoplePortal-BackEnd/docs/`](../PeoplePortal-BackEnd/docs/README.md) |
| Frontend Colaborador (React 19) | [`PeoplePortal-FrontEnd-Colaborador/docs/`](../PeoplePortal-FrontEnd-Colaborador/docs/README.md) |
| Frontend RRHH (React 19) | [`PeoplePortal-FrontEnd-RRHH/docs/`](../PeoplePortal-FrontEnd-RRHH/docs/README.md) |

---

## 📐 Documentación global

| Documento | Descripción |
|---|---|
| [arquitectura.md](./arquitectura.md) | Diagrama del sistema completo: componentes, puertos K8s, roles Keycloak |
| [despliegue.md](./despliegue.md) | Guía de despliegue end-to-end: build → K8s → verificación |
| [plan-implementacion.md](./plan-implementacion.md) | Estado del proyecto: completado, pendiente y criterios de cierre |
| [adr/001-react-en-lugar-de-angular.md](./adr/001-react-en-lugar-de-angular.md) | Decision Record: por qué se usa React 19 en lugar de Angular |
