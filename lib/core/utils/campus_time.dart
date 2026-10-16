/// Zona horaria del campus (America/Mexico_City).
///
/// México eliminó el horario de verano en 2022, por lo que el desfase es
/// fijo: UTC-6. Se usa un desfase fijo para no depender de la zona horaria
/// configurada en el teléfono del usuario.
class CampusTime {
  CampusTime._();

  static const Duration offset = Duration(hours: -6);

  /// Convierte un instante absoluto a "hora de pared" del campus.
  /// El resultado es un DateTime en UTC cuyos campos (año, mes, día, hora…)
  /// son los que se ven en el reloj del campus.
  static DateTime toWall(DateTime instant) => instant.toUtc().add(offset);

  /// Hora de pared actual del campus.
  static DateTime nowWall([DateTime? now]) => toWall(now ?? DateTime.now());

  /// Convierte una hora de pared del campus a instante absoluto (UTC).
  static DateTime fromWall(int year, int month, int day, int hour, int minute) {
    return DateTime.utc(year, month, day, hour, minute).subtract(offset);
  }

  /// Igual que [fromWall] pero recibiendo un DateTime de pared.
  static DateTime wallToInstant(DateTime wall) {
    return fromWall(wall.year, wall.month, wall.day, wall.hour, wall.minute);
  }

  /// Misma fecha de calendario (en hora del campus)?
  static bool sameWallDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
