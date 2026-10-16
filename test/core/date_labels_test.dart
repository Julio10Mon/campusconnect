import 'package:campusconnect/core/utils/date_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 14 oct 2026, 12:00 en el campus (miércoles)
  final now = DateTime.utc(2026, 10, 14, 18, 0);

  group('DateLabels.relativeDay', () {
    test('hoy', () {
      expect(DateLabels.relativeDay(DateTime.utc(2026, 10, 15, 3, 0), now: now), 'Hoy'); // 21:00 campus del día 14
    });
    test('mañana', () {
      expect(DateLabels.relativeDay(DateTime.utc(2026, 10, 15, 16, 0), now: now), 'Mañana');
    });
    test('otro día muestra día de la semana, número y mes', () {
      expect(DateLabels.relativeDay(DateTime.utc(2026, 10, 16, 16, 0), now: now), 'vie 16 oct');
    });
    test('un día pasado no se llama hoy', () {
      expect(DateLabels.relativeDay(DateTime.utc(2026, 10, 13, 16, 0), now: now), 'mar 13 oct');
    });
  });

  group('DateLabels.longDate', () {
    test('formato largo en español', () {
      expect(DateLabels.longDate(DateTime.utc(2026, 10, 14)), 'miércoles 14 de octubre');
    });
  });

  group('DateLabels.time', () {
    test('hora con cero a la izquierda en hora del campus', () {
      expect(DateLabels.time(DateTime.utc(2026, 10, 14, 15, 5)), '09:05');
    });
  });
}
