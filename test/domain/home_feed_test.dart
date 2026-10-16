import 'package:campusconnect/data/models/event_model.dart';
import 'package:campusconnect/data/models/notice_model.dart';
import 'package:campusconnect/domain/home_feed.dart';
import 'package:flutter_test/flutter_test.dart';

EventModel ev(String id, DateTime fecha) => EventModel(
      id: id,
      titulo: 'Evento $id',
      descripcion: 'd',
      ubicacion: 'u',
      fecha: fecha,
    );

NoticeModel no(String id, DateTime fecha) => NoticeModel(id: id, titulo: 'Aviso $id', descripcion: 'd', fecha: fecha);

void main() {
  final now = DateTime.utc(2026, 10, 14, 18, 0);

  group('HomeFeed', () {
    test('sin eventos: no hay destacado ni semana', () {
      final feed = HomeFeed.build(events: const [], notices: const [], now: now);
      expect(feed.nextEvent, isNull);
      expect(feed.thisWeek, isEmpty);
      expect(feed.recentNotices, isEmpty);
    });

    test('el destacado es el próximo evento futuro más cercano', () {
      final feed = HomeFeed.build(
        events: [
          ev('pasado', now.subtract(const Duration(days: 1))),
          ev('lejano', now.add(const Duration(days: 20))),
          ev('cercano', now.add(const Duration(hours: 3))),
        ],
        notices: const [],
        now: now,
      );
      expect(feed.nextEvent!.id, 'cercano');
    });

    test('"esta semana" excluye el destacado, lo pasado y lo posterior a 7 días', () {
      final feed = HomeFeed.build(
        events: [
          ev('a', now.add(const Duration(hours: 1))),
          ev('b', now.add(const Duration(days: 2))),
          ev('c', now.add(const Duration(days: 6))),
          ev('d', now.add(const Duration(days: 9))),
          ev('x', now.subtract(const Duration(hours: 2))),
        ],
        notices: const [],
        now: now,
      );
      expect(feed.nextEvent!.id, 'a');
      expect(feed.thisWeek.map((e) => e.id), ['b', 'c']);
    });

    test('los eventos próximos más allá de la semana se cuentan aparte', () {
      final feed = HomeFeed.build(
        events: [ev('a', now.add(const Duration(days: 1))), ev('d', now.add(const Duration(days: 30)))],
        notices: const [],
        now: now,
      );
      expect(feed.thisWeek, isEmpty);
      expect(feed.laterCount, 1);
    });

    test('avisos recientes: máximo 3, del más nuevo al más antiguo', () {
      final feed = HomeFeed.build(
        events: const [],
        notices: [
          no('1', now.subtract(const Duration(days: 5))),
          no('2', now.subtract(const Duration(days: 1))),
          no('3', now.subtract(const Duration(days: 3))),
          no('4', now.subtract(const Duration(days: 9))),
        ],
        now: now,
      );
      expect(feed.recentNotices.map((n) => n.id), ['2', '3', '1']);
    });
  });
}
