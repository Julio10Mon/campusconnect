/// Escala de espacios y radios compartida por toda la app.
class AppSpace {
  AppSpace._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Margen lateral de las pantallas.
  static const double gutter = 20;
}

class AppRadius {
  AppRadius._();

  /// Chips, campos pequeños.
  static const double sm = 10;

  /// Botones, campos de texto, filas.
  static const double md = 14;

  /// Tarjetas y piezas destacadas.
  static const double lg = 20;
}
