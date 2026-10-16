# Arquitectura

CampusConnect usa **Clean Architecture + MVVM** con **Riverpod** para el estado.

| Capa | Responsabilidad |
|------|-----------------|
| `presentation` | Pantallas (widgets) y ViewModels / providers de Riverpod |
| `domain` | Entidades, contratos de repositorio y casos de uso (Dart puro) |
| `data` | Repositorios, modelos y acceso a Firebase (Auth, Firestore, FCM) |

Flujo: `Pantalla → ViewModel → Caso de uso → Repositorio → Firebase`.

Navegación con `go_router`. Servicios en la nube: Firebase Authentication, Cloud Firestore y Cloud Messaging.

## Estructura de carpetas

```
lib/
├── core/            constants, errors, routes, services, theme, utils
├── domain/          repositories, usecases, validators, home_feed
├── data/            datasources, models, repositories
└── presentation/    providers, screens, widgets
```
