import '../../core/errors/app_exceptions.dart';

/// Reglas de fecha y hora para programar eventos.
class EventScheduleValidator {
  EventScheduleValidator._();

  static const String pastMessage = 'La fecha y hora del evento deben ser posteriores al momento actual.';
  static const String missingMessage = 'Selecciona la fecha y hora del evento.';

  /// Devuelve un mensaje de error o `null` si la fecha es válida.
  ///
  /// [fecha] es un instante absoluto (la comparación se hace como instante,
  /// por lo que fecha y hora se evalúan juntas). [originalFecha] permite
  /// editar un evento ya existente (incluso uno pasado) sin cambiar su fecha.
  static String? validate(DateTime? fecha, {DateTime? now, DateTime? originalFecha}) {
    if (fecha == null) return missingMessage;
    if (originalFecha != null && fecha.isAtSameMomentAs(originalFecha)) return null;
    final reference = (now ?? DateTime.now()).toUtc();
    if (!fecha.toUtc().isAfter(reference)) return pastMessage;
    return null;
  }

  /// Lanza [InvalidScheduleException] si la fecha no es válida.
  static void ensureValid(DateTime? fecha, {DateTime? now, DateTime? originalFecha}) {
    if (validate(fecha, now: now, originalFecha: originalFecha) != null) {
      throw const InvalidScheduleException();
    }
  }
}
