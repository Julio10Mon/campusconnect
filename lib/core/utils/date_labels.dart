import 'campus_time.dart';

/// Etiquetas de fecha en español de México, siempre en hora del campus.
/// No depende de `intl`, por lo que no requiere inicializar datos de idioma.
class DateLabels {
  DateLabels._();

  static const _days = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  static const _daysLong = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
  static const _months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
  static const _monthsLong = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  /// "Hoy", "Mañana" o "vie 16 oct".
  static String relativeDay(DateTime instant, {DateTime? now}) {
    final wall = CampusTime.toWall(instant);
    final today = CampusTime.nowWall(now);
    final dayDiff = DateTime.utc(wall.year, wall.month, wall.day)
        .difference(DateTime.utc(today.year, today.month, today.day))
        .inDays;
    if (dayDiff == 0) return 'Hoy';
    if (dayDiff == 1) return 'Mañana';
    return '${_days[wall.weekday - 1]} ${wall.day} ${_months[wall.month - 1]}';
  }

  /// "miércoles 14 de octubre" (recibe una hora de pared del campus).
  static String longDate(DateTime wall) {
    return '${_daysLong[wall.weekday - 1]} ${wall.day} de ${_monthsLong[wall.month - 1]}';
  }

  /// "09:05" a partir de un instante.
  static String time(DateTime instant) {
    final wall = CampusTime.toWall(instant);
    return '${wall.hour.toString().padLeft(2, '0')}:${wall.minute.toString().padLeft(2, '0')}';
  }

  /// Mes abreviado ("oct") de un instante, en hora del campus.
  static String monthShort(DateTime instant) => _months[CampusTime.toWall(instant).month - 1];
}
