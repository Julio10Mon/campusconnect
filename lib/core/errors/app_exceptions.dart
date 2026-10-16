/// Error de negocio con mensaje listo para mostrarse al usuario.
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Se intentó publicar algo que ya existe.
class DuplicatePublicationException extends AppException {
  const DuplicatePublicationException()
      : super('Esta publicación ya existe. Verifica la información antes de continuar.');
}

/// La fecha/hora del evento no es válida.
class InvalidScheduleException extends AppException {
  const InvalidScheduleException()
      : super('La fecha y hora del evento deben ser posteriores al momento actual.');
}

/// Convierte cualquier error en texto apto para el usuario.
String friendlyError(Object error) {
  if (error is AppException) return error.message;
  final text = error.toString();
  if (text.contains('permission-denied')) {
    return 'No tienes permiso para realizar esta acción.';
  }
  if (text.contains('unavailable') || text.contains('network')) {
    return 'Sin conexión. Revisa tu Internet e inténtalo de nuevo.';
  }
  return 'No se pudo completar la acción. Inténtalo de nuevo.';
}
