# docs/ — Índice de Documentación

Para la descripción completa del proyecto ver [`/README.md`](../README.md).

```
docs/
├── tecnico/          arquitectura, base-de-datos, despliegue, flujos, seguridad, playwright
├── proyecto/         plan-implementacion, video-demo
├── manuales/         rrhh, colaborador
├── propuesta/        Brief PDF+DOCX, entregables-finales PDF
├── adr/              001-react-en-lugar-de-angular
└── prompts/          catálogo de prompts por categoría
```


| Submódulo | Documentación interna |
|---|---|
| Backend (.NET 9) | [PeoplePortal-BackEnd/docs/](https://github.com/bryanjosue17/PeoplePortal-BackEnd/tree/main/docs) |
| Frontend Colaborador | [PeoplePortal-FrontEnd-Colaborador/docs/](https://github.com/bryanjosue17/PeoplePortal-FrontEnd-Colaborador/tree/main/docs) |
| Frontend RRHH | [PeoplePortal-FrontEnd-RRHH/docs/](https://github.com/bryanjosue17/PeoplePortal-FrontEnd-RRHH/tree/main/docs) |

---

## 📐 tecnico/

Documentación técnica del sistema completo.

| Documento | Descripción |
|---|---|
| [tecnico/arquitectura.md](./tecnico/arquitectura.md) | Diagrama C4 Nivel 1 y 2, componentes, puertos K8s |
| [tecnico/base-de-datos.md](./tecnico/base-de-datos.md) | Modelo Entidad-Relación (ER Diagram) |
| [tecnico/flujos.md](./tecnico/flujos.md) | Diagramas de secuencia: login, solicitudes, aprobaciones |
| [tecnico/despliegue.md](./tecnico/despliegue.md) | Guía de despliegue end-to-end: GHCR → K8s → verificación |
| [tecnico/seguridad.md](./tecnico/seguridad.md) | Mapeo OWASP Top 10 |
| [tecnico/playwright.md](./tecnico/playwright.md) | Pruebas E2E con Playwright: instalación, ejecución, capturas |

---

## 📋 proyecto/

Estado e hitos del proyecto.

| Documento | Descripción |
|---|---|
| [proyecto/plan-implementacion.md](./proyecto/plan-implementacion.md) | Checklist de completado, pendientes y criterio de cierre |
| [proyecto/video-demo.md](./proyecto/video-demo.md) | Enlace al video demostrativo (5–8 min) |

---

## 📖 manuales/

Manuales técnicos por portal.

| Documento | Descripción |
|---|---|
| [manuales/rrhh.md](./manuales/rrhh.md) | Manual técnico del Panel de Administración RRHH |
| [manuales/colaborador.md](./manuales/colaborador.md) | Manual técnico del Portal del Colaborador |

---

## 📁 propuesta/

Archivos de propuesta del curso.

| Archivo | Descripción |
|---|---|
| [propuesta/Brief_Capstone_ForzaTechAcademy_v1.pdf](./propuesta/Brief_Capstone_ForzaTechAcademy_v1.pdf) | Propuesta original del proyecto (PDF) |
| [propuesta/Brief_Capstone_ForzaTechAcademy_v1.docx](./propuesta/Brief_Capstone_ForzaTechAcademy_v1.docx) | Propuesta original del proyecto (Word) |
| [propuesta/entregables-finales.pdf](./propuesta/entregables-finales.pdf) | Documento de entregables finales del curso |

---

## 🧠 prompts/

Catálogo de prompts de IA utilizados durante el desarrollo.  
Ver [prompts/README.md](./prompts/README.md) para el índice completo.

---

## 📌 adr/

Architectural Decision Records.

| Documento | Descripción |
|---|---|
| [adr/001-react-en-lugar-de-angular.md](./adr/001-react-en-lugar-de-angular.md) | Por qué se eligió React 19 sobre Angular |

