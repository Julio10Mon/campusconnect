import 'package:campusconnect/domain/validators/publication_fingerprint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fecha = DateTime.utc(2026, 11, 3, 16, 0);

  group('PublicationFingerprint.event', () {
    test('es igual para el mismo evento aunque cambien mayúsculas, acentos o espacios', () {
      final a = PublicationFingerprint.event(titulo: 'Feria de Ciencia', fecha: fecha, ubicacion: 'Edificio A');
      final b = PublicationFingerprint.event(titulo: '  feria  de ciéncia ', fecha: fecha, ubicacion: 'edificio a');
      expect(a, b);
    });

    test('ignora los segundos de la fecha', () {
      final a = PublicationFingerprint.event(titulo: 'X', fecha: fecha, ubicacion: 'Y');
      final b = PublicationFingerprint.event(titulo: 'X', fecha: fecha.add(const Duration(seconds: 30)), ubicacion: 'Y');
      expect(a, b);
    });

    test('eventos parecidos pero con otra hora NO se consideran duplicados', () {
      final a = PublicationFingerprint.event(titulo: 'Taller', fecha: fecha, ubicacion: 'Edificio D');
      final b = PublicationFingerprint.event(titulo: 'Taller', fecha: fecha.add(const Duration(hours: 2)), ubicacion: 'Edificio D');
      expect(a, isNot(b));
    });

    test('mismo título y hora en otra ubicación NO es duplicado', () {
      final a = PublicationFingerprint.event(titulo: 'Taller', fecha: fecha, ubicacion: 'Edificio D');
      final b = PublicationFingerprint.event(titulo: 'Taller', fecha: fecha, ubicacion: 'Edificio E');
      expect(a, isNot(b));
    });

    test('es un hash válido para usar como id de documento', () {
      final h = PublicationFingerprint.event(titulo: 'X', fecha: fecha, ubicacion: 'Y');
      expect(h, matches(RegExp(r'^[0-9a-f]{64}$')));
    });
  });

  group('PublicationFingerprint.notice', () {
    test('el mismo aviso el mismo día es duplicado; otro día no', () {
      final d1 = DateTime.utc(2026, 10, 14, 10);
      final a = PublicationFingerprint.notice(titulo: 'Aviso', descripcion: 'Texto', autorUid: 'u1', dia: d1);
      final b = PublicationFingerprint.notice(titulo: 'Aviso', descripcion: 'Texto', autorUid: 'u1', dia: d1.add(const Duration(hours: 3)));
      final c = PublicationFingerprint.notice(titulo: 'Aviso', descripcion: 'Texto', autorUid: 'u1', dia: d1.add(const Duration(days: 1)));
      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
