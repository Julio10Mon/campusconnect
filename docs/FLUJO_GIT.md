# Flujo de versionamiento (desarrollo individual)

CampusConnect se desarrolla de forma individual con un flujo simple: una rama
`main` estable y ramas de trabajo `feature/*` por funcionalidad. Así el
historial es claro, los cambios se prueban antes de integrarse y se puede
volver a una versión anterior.

## Ramas

| Rama | Uso |
|------|-----|
| `main` | Versión estable y funcional. Solo recibe cambios ya probados. |
| `develop` | Rama de integración heredada del inicio del proyecto. |
| `feature/*` | Una por funcionalidad o tarea relevante (por ejemplo `feature/correcciones`, `feature/panel-administrador`). |

## Ciclo de trabajo

```bash
# 1. Actualizar main
git switch main
git pull origin main

# 2. Crear la rama de la funcionalidad
git switch -c feature/nombre-corto

# 3. Desarrollar y guardar cambios con commits pequeños y descriptivos
git add <archivos>
git commit -m "feat: descripcion corta de lo que cambia"

# 4. Subir la rama a GitHub (respaldo)
git push -u origin feature/nombre-corto

# 5. Probar
flutter analyze
flutter test

# 6. Integrar: abrir un Pull Request hacia main y fusionarlo con
#    "Create a merge commit" (equivale a git merge --no-ff)

# 7. Etiquetar la entrega
git tag -a v1.1.0 -m "Descripcion de la entrega"
git push origin v1.1.0
```

## Convención de commits

`feat:` funcionalidad nueva · `fix:` corrección · `docs:` documentación ·
`chore:` mantenimiento · `test:` pruebas · `refactor:` reorganización sin
cambiar el comportamiento.

## Configuración mínima aplicada

| Elemento | Cómo se cumple en este repositorio |
|----------|------------------------------------|
| Rama principal | `main` estable; se integra solo mediante Pull Request. |
| Ramas de trabajo | Una por funcionalidad (`feature/*`). |
| Commits | Frecuentes, pequeños y con prefijo (`feat:`, `docs:`, `chore:`). |
| Pruebas | `flutter analyze` y `flutter test` antes de integrar. |
| Respaldo | Las ramas se suben a GitHub con `git push`. |
| Versiones | Tags `vX.Y.Z` y *Releases* con el APK adjunto. |
| Seguridad | `.gitignore` excluye `key.properties`, `*.jks`, `*.keystore` y `.env`. |

## Seguridad

- Nunca se versionan la llave de firma (`*.jks`), `android/key.properties` ni
  archivos `.env`. Hay un ejemplo sin datos reales en `android/key.properties.example`.
- `android/app/google-services.json` y `lib/firebase_options.dart` **sí** están
  en el repositorio: contienen identificadores públicos del proyecto Firebase
  (no son contraseñas) y permiten que otra persona compile la app. La
  protección real está en las reglas de seguridad de Firestore
  (`firestore.rules.propuesta`) y en restringir la llave de API en Google Cloud.

## Descargar la app

Los APK se publican en la sección **Releases** del repositorio, nunca dentro
del código (la carpeta `build/` está ignorada).
