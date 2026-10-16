# CampusConnect

Aplicación móvil universitaria para la **Universidad Tecnológica del Valle del Mezquital (UTVM)**, Ixmiquilpan, Hidalgo. Proyecto de la materia *Desarrollo Móvil Integral*.

**Autor:** Julio César Montoya Romero · Ing. en Desarrollo y Gestión de Software, 10° B

## Descargar la app (Android)

1. Entra a **[Releases](https://github.com/Julio10Mon/campusconnect/releases/latest)**.
2. Descarga el archivo `app-release.apk` desde la sección *Assets*.
3. Ábrelo en tu celular Android y acepta **"Instalar apps desconocidas"** si te lo pide.
4. Toca **Instalar**.

> Requiere Android 8.0 (API 26) o superior.

## Funciones

- Avisos y eventos universitarios, con fotografías opcionales
- Calendario y mapa del campus
- Perfil de usuario (foto, carrera, descripción)
- Inicio de sesión con correo/contraseña, Google y Facebook
- Notificaciones push (Firebase Cloud Messaging)
- Panel de administrador para gestionar usuarios

## Tecnologías

Flutter · Dart · Firebase (Auth, Firestore, FCM) · Riverpod · go_router · Clean Architecture + MVVM

La estructura del proyecto está en [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md).

## Ejecutar el proyecto

```bash
git clone https://github.com/Julio10Mon/campusconnect.git
cd campusconnect
flutter pub get
flutter run
```

Para compilar el APK de release se necesita un keystore propio y el archivo `android/key.properties` (no incluido por seguridad).

## Flujo de versionamiento

Se sigue el flujo individual recomendado: rama `main` estable + ramas `feature/*` por funcionalidad, commits descriptivos (`feat:`, `fix:`, `docs:`, `chore:`), integración con `merge --no-ff` y *tags* para cada entrega.

| Rama | Uso |
|------|-----|
| `main` | Versión estable y funcional |
| `develop` | Integración de pruebas |
| `feature/*` | Una por funcionalidad o tarea |

Versiones publicadas: ver [CHANGELOG.md](CHANGELOG.md) y la pestaña *Releases*.

## Seguridad

Excluidos del repositorio: `key.properties`, `*.jks`, `*.keystore` y credenciales.

## Política de privacidad

https://julio10mon.github.io/campusconnect/privacy.html
