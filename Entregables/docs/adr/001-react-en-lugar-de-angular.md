# ADR-001: Uso de React 19 en lugar de Angular

**Estado:** Aceptado  
**Fecha:** 2026-06  
**Autores:** Equipo PeoplePortal

---

## Contexto

El skeleton de referencia del capstone (Forza Tech Academy) indicaba Angular como framework frontend. Antes del inicio del desarrollo, el equipo evaluó las opciones disponibles y sus implicaciones técnicas.

## Decisión

Se utilizará **React 19 + Vite** para ambos frontends (Portal Colaborador y Panel RRHH) en lugar de Angular.

## Razones

| Factor | Angular | React 19 + Vite |
|---|---|---|
| Curva de aprendizaje del equipo | Alta | Baja (equipo con experiencia previa) |
| Velocidad de desarrollo | Moderada | Alta |
| Ecosistema de UI | Angular Material | MUI v9 (mayor comunidad) |
| Build tooling | Angular CLI | Vite (más rápido) |
| Tamaño de bundle | Mayor | Menor |
| Flexibilidad de arquitectura | Opinionated | Flexible |

## Consecuencias positivas

- Menor tiempo de onboarding del equipo.
- Hot Module Replacement más rápido con Vite.
- MUI v9 con soporte nativo para React 19 (Concurrent Features).
- Tests con Vitest (mismo ecosistema Vite, sin configuración extra).

## Consecuencias negativas / riesgos

- Desviación del skeleton de referencia → requirió documentación formal y aprobación del líder técnico.
- Sin `NgRx` → manejo de estado con hooks de React y contexto, suficiente para el alcance MVP.

## Aprobación

Aprobada por el líder técnico previo al inicio del desarrollo. Referenciada en el `README.md` raíz del proyecto.
