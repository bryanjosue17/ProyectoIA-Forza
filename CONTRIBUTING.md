# Contribuir a ProyectoIA-Forza

Gracias por querer contribuir. Este documento describe el flujo recomendado para trabajar en el repositorio raíz con submódulos.

1. Ramas
   - `main`: rama por defecto, contiene releases estables.
   - `develop`: rama de integración donde se hace trabajo diario y PRs.

2. Flujo de trabajo general
   - Clona el repositorio raíz con submódulos:

     ```bash
     git clone --recurse-submodules https://github.com/bryanjosue17/ProyectoIA-Forza.git
     cd ProyectoIA-Forza
     git checkout develop
     ```

   - Si ya clonaste sin submódulos:

     ```bash
     git submodule update --init --recursive
     ```

   - Para trabajar en un submódulo:

     ```bash
     cd PeoplePortal-BackEnd
     git checkout develop
     git pull origin develop
     # crear rama feature
     git checkout -b feature/mi-cambio
     # hacer cambios, commit, push
     git push origin feature/mi-cambio
     ```

   - Abrir Pull Request desde la rama del submódulo hacia `develop` del submódulo.

   - Una vez mergeado el PR en el submódulo, desde la raíz del repositorio:

     ```bash
     git submodule foreach 'git fetch origin && git checkout develop && git pull origin develop'
     git add PeoplePortal-BackEnd PeoplePortal-FrontEnd-Colaborador PeoplePortal-FrontEnd-RRHH
     git commit -m "Update submodule refs"
     git push origin develop
     ```

3. Revisión y protección de ramas
   - La rama `develop` está protegida: requiere PR para merges y revisiones.

4. Estilo de commits
   - Usa mensajes claros: `Tipo: descripción breve` (ej. `Fix: corregir validación de token`).

5. Notas
   - Los submódulos conservan su propio historial y políticas; revisa sus `README` y reglas internas.

Gracias por contribuir — si necesitas plantillas de PR o convenciones adicionales, proponlo en un issue.
