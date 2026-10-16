# Arquitectura

CampusConnect usa **Clean Architecture + MVVM** con **Riverpod** para el estado.

| Capa | Responsabilidad |
|------|-----------------|
| `presentation` | Pantallas (widgets) y ViewModels / providers de Riverpod |
| `domain` | Entidades, contratos de repositorio y casos de uso (Dart puro) |
| `data` | Repositorios, modelos y acceso a Firebase (Auth, Firestore, FCM) |

Flujo: `Pantalla → ViewModel → Caso de uso → Repositorio → Firebase`.

Navegación con `go_router`. Servicios en la nube: Firebase Authentication, Cloud Firestore y Cloud Messaging.

## Estructura real de `lib/`

| Carpeta | Contenido |
|---------|-----------|
| `core/` | Tema (`app_theme`, `app_tokens`), constantes (colores, textos, catálogo de ubicaciones del campus), rutas, servicio de notificaciones, errores y utilidades (hora del campus, texto, fechas) |
| `data/` | `datasources` (Firebase), `models` (usuario, aviso, evento, mapa, calendario) y `repositories` (implementaciones) |
| `domain/` | Contratos de repositorio, casos de uso, validadores de horario y huella de publicaciones, y el armado del feed de inicio |
| `presentation/` | `screens` (auth, inicio, avisos, eventos, explorar, perfil, administración), `widgets` reutilizables (incluye `motion.dart` para animaciones) y `providers` de Riverpod |

## Decisiones de diseño

- **Publicaciones idempotentes:** el identificador del documento en Firestore es una huella (SHA-256) de los datos clave, y la creación se hace en una transacción que rechaza un documento ya existente. Así un doble toque no duplica.
- **Hora del campus:** los horarios se manejan con un desfase fijo (UTC-6) para que todos vean la misma hora.
- **Eventos guardados:** se almacenan por usuario en `usuarios/{uid}/guardados/{eventId}`.
- **Animaciones con criterio:** movimiento solo para jerarquía y respuesta, y se desactiva con "reducir animaciones".
