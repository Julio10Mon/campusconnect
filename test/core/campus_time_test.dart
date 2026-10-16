import 'package:campusconnect/core/utils/campus_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CampusTime (UTC-6)', () {
    test('convierte un instante UTC a hora de pared del campus', () {
      final wall = CampusTime.toWall(DateTime.utc(2026, 10, 14, 12, 30));
      expect([wall.year, wall.month, wall.day, wall.hour, wall.minute], [2026, 10, 14, 6, 30]);
    });

    test('cambio de día: 03:00 UTC es la noche anterior en el campus', () {
      final wall = CampusTime.toWall(DateTime.utc(2026, 10, 15, 3, 0));
      expect([wall.day, wall.hour], [14, 21]);
    });

    test('fromWall y toWall son inversas', () {
      final instant = CampusTime.fromWall(2026, 12, 31, 23, 59);
      expect(instant, DateTime.utc(2027, 1, 1, 5, 59));
      final back = CampusTime.toWall(instant);
      expect([back.year, back.month, back.day, back.hour, back.minute], [2026, 12, 31, 23, 59]);
    });
  });
}
