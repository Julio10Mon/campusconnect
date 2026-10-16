import 'package:campusconnect/core/constants/campus_locations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Catálogo de ubicaciones', () {
    test('incluye 12 edificios, 2 canchas y la opción otra', () {
      expect(CampusLocations.edificios.length, 12);
      expect(CampusLocations.deportivas.length, 2);
      expect(CampusLocations.all.last.id, CampusLocations.otherId);
    });

    test('los ids son únicos y estables', () {
      final ids = CampusLocations.all.map((l) => l.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('busca por letra, con el edificio exacto primero', () {
      final r = CampusLocations.search('h');
      expect(r.first.id, 'edificio-h');
    });

    test('busca por nombre sin importar acentos ni mayúsculas', () {
      expect(CampusLocations.search('CAFETERIA').single.id, 'edificio-i');
      expect(CampusLocations.search('biblioteca').map((l) => l.id), contains('edificio-a'));
    });

    test('los nombres coinciden con el letrero oficial', () {
      String nombre(String letra) => CampusLocations.edificios.firstWhere((l) => l.letra == letra).nombre;
      expect(nombre('F'), 'P.E. de Mecánica Industrial');
      expect(nombre('K'), 'P.E. de Mecatrónica y Energía Turbo-Solar');
      expect(nombre('I'), 'Cafetería');
      expect(nombre('L'), 'P.E. de Turismo y Gastronomía');
      expect(nombre('C'), 'Dirección de Vinculación / Auditorio Centenario');
    });

    test('busca por área y por tipo de espacio', () {
      expect(CampusLocations.search('turismo').map((l) => l.id), containsAll(['edificio-h', 'edificio-l']));
      expect(CampusLocations.search('laboratorio').map((l) => l.id), contains('edificio-h'));
      expect(CampusLocations.search('mecatronica').single.id, 'edificio-k');
      expect(CampusLocations.search('deportiva').map((l) => l.id), containsAll(['cancha-futbol', 'cancha-techada']));
    });

    test('busca las canchas', () {
      expect(CampusLocations.search('futbol').single.id, 'cancha-futbol');
      expect(CampusLocations.search('techada').single.id, 'cancha-techada');
    });

    test('búsqueda vacía devuelve todo el catálogo', () {
      expect(CampusLocations.search('').length, CampusLocations.all.length);
    });

    test('sin coincidencias devuelve lista vacía', () {
      expect(CampusLocations.search('zzzz'), isEmpty);
    });

    test('resolve reconoce texto antiguo que coincide con el catálogo', () {
      expect(CampusLocations.resolve(text: 'Cancha de Fútbol')?.id, 'cancha-futbol');
      expect(CampusLocations.resolve(text: 'Salón 12'), isNull);
      expect(CampusLocations.resolve(id: 'edificio-d')?.id, 'edificio-d');
    });
  });
}
