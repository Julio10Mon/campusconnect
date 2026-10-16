import 'package:campusconnect/domain/validators/event_schedule_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 14, 18, 0); // 12:00 en el campus

  group('EventScheduleValidator', () {
    test('rechaza fechas de días anteriores', () {
      final r = EventScheduleValidator.validate(DateTime.utc(2026, 10, 13, 20), now: now);
      expect(r, EventScheduleValidator.pastMessage);
    });

    test('rechaza una hora anterior el mismo día', () {
      final r = EventScheduleValidator.validate(DateTime.utc(2026, 10, 14, 17, 59), now: now);
      expect(r, EventScheduleValidator.pastMessage);
    });

    test('rechaza exactamente el momento actual', () {
      expect(EventScheduleValidator.validate(now, now: now), isNotNull);
    });

    test('acepta un minuto en el futuro', () {
      expect(EventScheduleValidator.validate(DateTime.utc(2026, 10, 14, 18, 1), now: now), isNull);
    });

    test('acepta fechas futuras de otro día', () {
      expect(EventScheduleValidator.validate(DateTime.utc(2026, 10, 15, 14), now: now), isNull);
    });

    test('cambio de día: 23:59 de hoy en el campus ya pasó, 00:00 de mañana no', () {
      final lateNow = DateTime.utc(2026, 10, 15, 5, 59, 30); // 23:59:30 campus
      expect(EventScheduleValidator.validate(DateTime.utc(2026, 10, 15, 5, 59), now: lateNow), isNotNull);
      expect(EventScheduleValidator.validate(DateTime.utc(2026, 10, 15, 6, 0), now: lateNow), isNull);
    });

    test('fecha nula devuelve mensaje', () {
      expect(EventScheduleValidator.validate(null, now: now), EventScheduleValidator.missingMessage);
    });

    test('editar un evento pasado sin cambiar su fecha está permitido', () {
      final original = DateTime.utc(2026, 1, 1, 10);
      expect(EventScheduleValidator.validate(original, now: now, originalFecha: original), isNull);
    });

    test('editar un evento pasado cambiando a otra fecha pasada se rechaza', () {
      final original = DateTime.utc(2026, 1, 1, 10);
      expect(
        EventScheduleValidator.validate(DateTime.utc(2026, 2, 1, 10), now: now, originalFecha: original),
        isNotNull,
      );
    });

    test('ensureValid lanza excepción con el mensaje requerido', () {
      expect(
        () => EventScheduleValidator.ensureValid(DateTime.utc(2020), now: now),
        throwsA(predicate((e) => e.toString() == EventScheduleValidator.pastMessage)),
      );
    });
  });
}
