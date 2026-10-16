import '../utils/text_utils.dart';

/// Tipo de ubicación.
enum LocationKind { edificio, deportiva, otra }

/// Ubicación del catálogo oficial del campus.
class CampusLocation {
  /// Identificador estable (no cambiar una vez publicado).
  final String id;
  final String nombre;
  final String? letra;
  final LocationKind tipo;
  final List<String> palabrasClave;

  const CampusLocation({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.letra,
    this.palabrasClave = const [],
  });

  /// Texto que se guarda y se muestra en tarjetas y detalles.
  String get etiqueta => tipo == LocationKind.edificio ? 'Edificio $letra — $nombre' : nombre;

  String get _haystack => TextUtils.normalize(
        [etiqueta, letra ?? '', tipo == LocationKind.edificio ? 'edificio' : '', ...palabrasClave].join(' '),
      );
}

/// Catálogo oficial de ubicaciones.
class CampusLocations {
  CampusLocations._();

  /// Id de la opción personalizada.
  static const String otherId = 'otra';

  // Nombres tomados del letrero oficial del campus ("P.E." = programa educativo).
  static const List<CampusLocation> edificios = [
    CampusLocation(id: 'edificio-a', letra: 'A', tipo: LocationKind.edificio, nombre: 'Biblioteca "Mtro. Agustín Cadena Rubio"', palabrasClave: ['biblioteca']),
    CampusLocation(id: 'edificio-b', letra: 'B', tipo: LocationKind.edificio, nombre: 'Rectoría y Áreas Administrativas', palabrasClave: ['rectoria', 'administrativo']),
    CampusLocation(id: 'edificio-c', letra: 'C', tipo: LocationKind.edificio, nombre: 'Dirección de Vinculación / Auditorio Centenario', palabrasClave: ['vinculacion', 'auditorio']),
    CampusLocation(id: 'edificio-d', letra: 'D', tipo: LocationKind.edificio, nombre: 'P.E. de Tecnologías de la Información', palabrasClave: ['ti', 'tecnologias', 'programa educativo']),
    CampusLocation(id: 'edificio-e', letra: 'E', tipo: LocationKind.edificio, nombre: 'P.E. Tecnología de Alimentos', palabrasClave: ['alimentos', 'programa educativo']),
    CampusLocation(id: 'edificio-f', letra: 'F', tipo: LocationKind.edificio, nombre: 'P.E. de Mecánica Industrial', palabrasClave: ['mecanica', 'programa educativo']),
    CampusLocation(id: 'edificio-g', letra: 'G', tipo: LocationKind.edificio, nombre: 'P.E. de Administración', palabrasClave: ['administracion', 'programa educativo']),
    CampusLocation(id: 'edificio-h', letra: 'H', tipo: LocationKind.edificio, nombre: 'Laboratorios Gastronomía y Turismo', palabrasClave: ['laboratorio', 'laboratorios']),
    CampusLocation(id: 'edificio-i', letra: 'I', tipo: LocationKind.edificio, nombre: 'Cafetería', palabrasClave: ['cafeteria', 'comedor']),
    CampusLocation(id: 'edificio-j', letra: 'J', tipo: LocationKind.edificio, nombre: 'Aulas Energía Turbo-Solar', palabrasClave: ['aula', 'aulas', 'turbosolar']),
    CampusLocation(id: 'edificio-k', letra: 'K', tipo: LocationKind.edificio, nombre: 'P.E. de Mecatrónica y Energía Turbo-Solar', palabrasClave: ['mecatronica', 'turbosolar', 'programa educativo']),
    CampusLocation(id: 'edificio-l', letra: 'L', tipo: LocationKind.edificio, nombre: 'P.E. de Turismo y Gastronomía', palabrasClave: ['turismo', 'programa educativo']),
  ];

  static const List<CampusLocation> deportivas = [
    CampusLocation(id: 'cancha-futbol', tipo: LocationKind.deportiva, nombre: 'Cancha de Fútbol', palabrasClave: ['futbol', 'deporte', 'instalaciones deportivas']),
    CampusLocation(id: 'cancha-techada', tipo: LocationKind.deportiva, nombre: 'Cancha Techada', palabrasClave: ['techada', 'deporte', 'instalaciones deportivas']),
  ];

  static const CampusLocation otra = CampusLocation(
    id: otherId,
    tipo: LocationKind.otra,
    nombre: 'Otra ubicación (especificar)',
    palabrasClave: ['personalizada', 'otro'],
  );

  /// Ubicaciones elegibles (sin "otra").
  static const List<CampusLocation> presets = [...edificios, ...deportivas];

  /// Catálogo completo, incluida "otra".
  static const List<CampusLocation> all = [...edificios, ...deportivas, otra];

  static CampusLocation? byId(String? id) {
    if (id == null) return null;
    for (final loc in all) {
      if (loc.id == id) return loc;
    }
    return null;
  }

  /// Compatibilidad con eventos anteriores: intenta reconocer el texto libre
  /// guardado antes del catálogo. Devuelve `null` si no coincide exactamente.
  static CampusLocation? resolve({String? id, String? text}) {
    final byIdMatch = byId(id);
    if (byIdMatch != null) return byIdMatch;
    if (text == null || text.trim().isEmpty) return null;
    final wanted = TextUtils.normalize(text);
    for (final loc in presets) {
      if (TextUtils.normalize(loc.etiqueta) == wanted || TextUtils.normalize(loc.nombre) == wanted) {
        return loc;
      }
    }
    return null;
  }

  /// Búsqueda por nombre, letra, área, instalación o tipo de espacio.
  /// Cada palabra escrita debe coincidir con el inicio de alguna palabra de
  /// la ubicación (o, si tiene 3+ letras, estar contenida en el texto).
  static List<CampusLocation> search(String query, {bool includeOther = true}) {
    final pool = includeOther ? all : presets;
    final tokens = TextUtils.normalize(query).split(' ').where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return pool;
    final results = pool.where((loc) {
      final hay = loc._haystack;
      final words = hay.split(RegExp(r'[^a-z0-9]+')).where((w) => w.isNotEmpty).toList();
      return tokens.every((t) {
        if (words.any((w) => w.startsWith(t))) return true;
        return t.length >= 3 && hay.contains(t);
      });
    }).toList();
    // Si se escribió una letra, el edificio con esa letra va primero.
    final letter = tokens.firstWhere((t) => t.length == 1, orElse: () => '');
    if (letter.isNotEmpty) {
      results.sort((a, b) {
        final aHit = a.letra?.toLowerCase() == letter ? 0 : 1;
        final bHit = b.letra?.toLowerCase() == letter ? 0 : 1;
        return aHit.compareTo(bHit);
      });
    }
    return results;
  }
}
