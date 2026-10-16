# Changelog

## [1.2.0] - 2026-10-15

### Cambiado
- Nombres de edificios según el letrero oficial del campus.
- Avisos: ya no piden fecha ni hora; se registra automáticamente al publicar.
- App completa en español (selectores de fecha/hora y diálogos), hora en formato 24 h.
- Animaciones: entrada escalonada en listas, escala al presionar, marcador animado,
  contadores del perfil, transición entre pestañas y entre pantallas. Respetan
  la opción "reducir animaciones" del sistema.

## [1.1.0] - 2026-10-14 - Correcciones de la profesora y rediseño
### Corregido
- Publicaciones duplicadas: el id del documento es una huella del contenido, la creación es idempotente (transacción), el botón se bloquea mientras se publica y los duplicados exactos ya existentes se ocultan en las listas sin borrarse. Mensaje: "Esta publicación ya existe. Verifica la información antes de continuar."
- Fecha y hora: ya no se pueden programar eventos en el pasado (validación en formulario, al guardar, en el repositorio y propuesta de reglas de Firestore). Se usa la hora del campus (UTC-6).

### Rediseño
- Pantalla Inicio con el próximo evento destacado, eventos de la semana y avisos recientes.
- Tipografías Bricolage Grotesque y Public Sans (google_fonts), escala de espacios y radios, títulos sin mayúsculas.
- Navegación de 5 pestañas; administración de usuarios movida a Perfil.

### Agregado
- Selector de ubicaciones con búsqueda (12 edificios, 2 canchas, "Otra ubicación").
- Pestaña "Explorar" con "Calendario de eventos" (mes real con eventos) y "Mapa de ubicaciones".
- Eventos: búsqueda, filtros Próximos/Finalizados/Todos y por ubicación.
- Perfil: estadísticas reales, mis eventos, mis avisos, eventos guardados, cambio de contraseña por correo.
- Guardar eventos (sin duplicados por construcción).
- Pruebas unitarias de fecha, ubicaciones y anti-duplicados.
- `firestore.rules.propuesta` (pendiente de revisar y publicar).

## [1.0.0] - 2026-10-13
### Agregado
- Autenticación con correo, Google y Facebook
- Avisos, eventos, calendario y mapa del campus
- Perfil de usuario y panel de administrador
- Notificaciones push con Firebase Cloud Messaging
- Política de privacidad publicada con GitHub Pages
- Publicación en Amazon Appstore (tabletas Fire)

### Cambiado
- APK firmado con llave de release propia (antes firmado en modo debug)
- Reglas ProGuard/R8 para Play Core
