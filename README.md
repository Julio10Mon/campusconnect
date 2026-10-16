<div align="center">

# CampusConnect

**La vida del campus en tu bolsillo: avisos, eventos, calendario y mapa de la UTVM.**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%C2%B7%20Firestore%20%C2%B7%20FCM-FFCA28?logo=firebase&logoColor=black)
![Plataforma](https://img.shields.io/badge/Android-8.0%2B-3DDC84?logo=android&logoColor=white)
![Versión](https://img.shields.io/badge/versi%C3%B3n-1.2.0-0F766E)

[Descargar APK](https://github.com/Julio10Mon/campusconnect/releases/latest) ·
[Arquitectura](docs/ARQUITECTURA.md) ·
[Flujo de Git](docs/FLUJO_GIT.md) ·
[Changelog](CHANGELOG.md) ·
[Política de privacidad](https://julio10mon.github.io/campusconnect/privacy.html)

</div>

---

## Acerca del proyecto

**CampusConnect** es una aplicación móvil para la comunidad de la **Universidad Tecnológica del Valle del Mezquital (UTVM)**, en Ixmiquilpan, Hidalgo. Reúne en un solo lugar los avisos oficiales, los eventos del campus, un calendario mensual y el mapa de ubicaciones, para que nadie se pierda lo que pasa en la universidad.

Es un proyecto de la materia **Desarrollo Móvil Integral**, desarrollado de forma individual.

| | |
|---|---|
| **Autor** | Julio César Montoya Romero |
| **Carrera** | Ingeniería en Desarrollo y Gestión de Software, 10.º cuatrimestre, grupo B |
| **Universidad** | Universidad Tecnológica del Valle del Mezquital (UTVM) |

## Funciones

**Para toda la comunidad**
- **Inicio** con el próximo evento destacado, los eventos de la semana y los avisos recientes.
- **Avisos** con fotografía opcional. La fecha de publicación se registra automáticamente.
- **Eventos** con búsqueda, filtros (próximos, finalizados, todos) y filtro por ubicación.
- **Guardar eventos** para consultarlos después desde el perfil.
- **Explorar:** calendario mensual con los eventos del campus y mapa de ubicaciones.
- **Perfil** con foto, carrera, descripción y estadísticas de tu actividad.
- **Inicio de sesión** con correo y contraseña, Google o Facebook.
- **Notificaciones push** mediante Firebase Cloud Messaging.
- **Interfaz en español** con selectores de fecha y hora (formato de 24 horas) y animaciones que respetan la opción *reducir animaciones* del sistema.

**Para administradores**
- Panel para activar o desactivar usuarios y asignar roles.
- Edición del calendario y del mapa del campus.

## Descargar la app (Android)

1. Entra a la sección **[Releases](https://github.com/Julio10Mon/campusconnect/releases/latest)**.
2. En *Assets*, descarga el archivo `app-release.apk`.
3. Ábrelo en tu celular Android y, si te lo pide, permite **Instalar apps desconocidas**.
4. Toca **Instalar**.

> **Requisitos:** Android 8.0 (API 26) o superior.
> Al instalar el APK fuera de una tienda, Google Play Protect puede mostrar una advertencia. Es normal: la app está firmada con una llave propia y no proviene de Google Play.

## Tecnologías

| Área | Herramientas |
|------|--------------|
| Framework | Flutter y Dart |
| Estado | Riverpod |
| Navegación | go_router |
| Backend | Firebase Authentication, Cloud Firestore y Cloud Messaging |
| Arquitectura | Clean Architecture + MVVM |
| Tipografía | Bricolage Grotesque y Public Sans (google_fonts) |
| Pruebas | flutter_test |

## Arquitectura

El código se organiza en tres capas con dependencias en un solo sentido:

```
lib/
├── core/            Tema, constantes, rutas, utilidades y servicios
├── domain/          Contratos de repositorio, casos de uso y validadores (Dart puro)
├── data/            Modelos, fuentes de datos (Firebase) e implementaciones
└── presentation/    Pantallas, widgets y providers de Riverpod
```

Flujo de datos: `Pantalla → Provider → Caso de uso → Repositorio → Firebase`.
El detalle está en [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md).

### Decisiones de diseño

- **Sin publicaciones duplicadas.** El identificador de cada aviso o evento es una huella del contenido; la creación es idempotente (transacción) y el botón se bloquea mientras se publica.
- **Fechas coherentes.** No se pueden programar eventos en el pasado. Todo se calcula con la hora del campus (UTC−6).
- **Ubicaciones oficiales.** El selector usa los 12 edificios y las 2 canchas del letrero del campus, con búsqueda sin distinguir acentos.

## Ejecutar el proyecto

**Requisitos previos:** Flutter 3.x con Dart 3.x, Android Studio o VS Code, y un dispositivo o emulador Android.

```bash
git clone https://github.com/Julio10Mon/campusconnect.git
cd campusconnect
flutter pub get
flutter run
```

### Pruebas y análisis

```bash
flutter analyze
flutter test
```

### Compilar el APK de lanzamiento

Se necesita una llave de firma propia. Copia `android/key.properties.example` como `android/key.properties`, completa tus datos y ejecuta:

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

## Flujo de versionamiento

Se sigue un flujo individual: una rama `main` estable y ramas `feature/*` por funcionalidad. Los commits son descriptivos (`feat:`, `fix:`, `docs:`, `test:`, `chore:`), la integración se hace con `merge --no-ff` y cada entrega lleva una etiqueta `vX.Y.Z`.

| Rama | Uso |
|------|-----|
| `main` | Versión estable y funcional |
| `develop` | Integración de pruebas |
| `feature/*` | Una por funcionalidad o tarea |
| `docs/*` | Cambios de documentación |

| Versión | Contenido |
|---------|-----------|
| `v0.1.0` | Estructura inicial del proyecto |
| `v0.2.0` | Autenticación |
| `v0.3.0` | Avisos y eventos |
| `v1.0.0` | Funcionalidad completa y pruebas |
| `v1.2.0` | Nombres oficiales, avisos sin fecha manual, español y animaciones |

Consulta el detalle en [CHANGELOG.md](CHANGELOG.md) y en [docs/FLUJO_GIT.md](docs/FLUJO_GIT.md).

## Seguridad

- No se versionan la llave de firma (`*.jks`, `*.keystore`), `android/key.properties` ni archivos `.env`; hay un ejemplo sin datos reales en `android/key.properties.example`.
- `google-services.json` y `firebase_options.dart` contienen identificadores públicos del proyecto Firebase, no contraseñas. La protección real está en las reglas de Firestore (propuesta en `firestore.rules.propuesta`) y en restringir la llave de API en Google Cloud.

## Política de privacidad

Consulta la [política de privacidad](https://julio10mon.github.io/campusconnect/privacy.html) de la aplicación.

## Autor

**Julio César Montoya Romero** — [@Julio10Mon](https://github.com/Julio10Mon)
Proyecto académico de la UTVM, Ixmiquilpan, Hidalgo.
