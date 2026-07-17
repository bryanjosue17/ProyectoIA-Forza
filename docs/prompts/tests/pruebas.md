# Prompt — Testing Unitario e Integración

## Contexto
Proyectos:
- Backend: xUnit, Moq, FluentAssertions, MediatR
- Frontend Colaborador/RRHH: Vitest, React Testing Library, jsdom
- Auth: AuthContext personalizado con ROPC (NO @react-keycloak/web)

---

## Prompt 1: Pruebas unitarias para Handler CQRS (Backend)

```
Genera las pruebas unitarias usando xUnit, Moq y FluentAssertions para el
CreateEmployeeCommandHandler de PeoplePortal.Application.

Cubre los siguientes escenarios:
1. Handle_Should_CreateEmployee_WhenCommandIsValid: verifica que el repositorio.AddAsync
   sea llamado, SaveChangesAsync sea llamado una vez, y el DTO retornado tenga los datos.
2. Handle_Should_ThrowArgumentException_WhenContractTypeIsInvalid
3. Handle_Should_ThrowInvalidOperationException_WhenKeycloakIdAlreadyExists
4. Validator_Should_HaveError_WhenCodeIsEmpty
5. Validator_Should_HaveError_WhenEmailIsInvalid

Usa el patrón Arrange-Act-Assert. Genera mocks de IEmployeeRepository.
```

---

## Prompt 2: Tests unitarios de componentes React (con AuthContext mock)

```
Genera pruebas unitarias para el componente Dashboard.jsx del Portal Colaborador
usando Vitest y React Testing Library.

Importante: el componente usa useAuth() del AuthContext propio (NO useKeycloak).
Genera el mock:

vi.mock('../context/AuthContext', () => ({
  useAuth: () => ({
    user: { name: 'Test User', email: 'test@example.com', realm_access: { roles: ['employee'] } },
    isAuthenticated: true,
    loading: false,
    logout: vi.fn(),
  }),
  AuthProvider: ({ children }) => children,
}));

También mockea el axios client y los módulos API.

Tests:
1. 'renders welcome message with user name'
2. 'shows skeleton loaders while loading is true'
3. 'displays dashboard stats after data loads' (mock getDashboard)
```

---

## Prompt 3: Tests de keycloak.js (URL de fallback)

```
Genera tests unitarios para src/keycloak.js usando Vitest:

vi.mock('keycloak-js', () => ({
  default: vi.fn(function(config) { return { ...config }; }),
}));

Tests:
1. 'uses VITE_KEYCLOAK_URL when set': setea import.meta.env.VITE_KEYCLOAK_URL='http://keycloak:8080'
   y verifica que keycloak-js fue llamado con url='http://keycloak:8080'
2. 'falls back to http://localhost:30080 when VITE_KEYCLOAK_URL is not set'
   (el default en el código es 'http://localhost:30080', NO 8080)
3. 'has correct realm and clientId': realm='peopleportal', clientId='peopleportal-frontend'

Usar beforeEach(() => { vi.resetModules(); delete import.meta.env.VITE_KEYCLOAK_URL; })
```

```
Genera las pruebas unitarias usando xUnit, Moq y FluentAssertions para el 
CreateHrRequestCommandHandler de PeoplePortal.Application.

Cubre los siguientes escenarios:
1. Handle_Should_CreateRequestAndReturnId_WhenCommandIsValid: verifica que el ID
   se genere, el repositorio sea llamado, y SaveChangesAsync sea llamado una vez.
2. Handle_Should_ThrowNotFoundException_WhenEmployeeDoesNotExist: usando un mock
   de IApplicationDbContext donde el empleado no exista.
3. Validator_Should_HaveError_WhenCommentsExceedLimit: prueba unitaria del 
   CreateHrRequestCommandValidator comprobando la longitud máxima.

Usa el patrón Arrange-Act-Assert.
```

---

## Prompt 2: Smoke Tests para Componentes React (Frontend)

```
Genera pruebas unitarias/smoke tests para el componente Dashboard.jsx de PeoplePortal
(React 19) usando Vitest y React Testing Library.

El componente requiere el mock de @react-keycloak/web porque usa useKeycloak().

Crea los siguientes tests:
1. "renders without crashing": renderiza el Dashboard dentro de un MemoryRouter
   usando un mock de useKeycloak que retorne { keycloak: { tokenParsed: { given_name: 'Test' } } }.
2. "shows skeleton loaders initially": verifica que muestre Skeletons si loading es true.
3. "displays correct summary values": haz mock de getDashboard (axios) para retornar
   datos fijos y verifica que screen.findByText encuentre los valores correctos en pantalla.

Envuelve las aserciones asíncronas en act() para evitar advertencias de React 18.
Configura testTimeout en 20000ms si usas findByText.
```
