import '../data/models/event_model.dart';
import '../data/models/notice_model.dart';

/// Contenido de la pantalla de inicio, calculado a partir de datos reales.
class HomeFeed {
  /// Próximo evento (el destacado).
  final EventModel? nextEvent;

  /// Otros eventos de los próximos 7 días (sin incluir el destacado).
  final List<EventModel> thisWeek;

  /// Cuántos eventos próximos quedan fuera de la semana.
  final int laterCount;

  /// Hasta 3 avisos, del más reciente al más antiguo.
  final List<NoticeModel> recentNotices;

  const HomeFeed({
    required this.nextEvent,
    required this.thisWeek,
    required this.laterCount,
    required this.recentNotices,
  });

  static HomeFeed build({
    required List<EventModel> events,
    required List<NoticeModel> notices,
    DateTime? now,
    int maxNotices = 3,
  }) {
    final reference = (now ?? DateTime.now()).toUtc();
    final weekLimit = reference.add(const Duration(days: 7));

    final upcoming = events.where((e) => e.fecha.toUtc().isAfter(reference)).toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    final next = upcoming.isEmpty ? null : upcoming.first;
    final rest = upcoming.skip(1).toList();
    final week = rest.where((e) => !e.fecha.toUtc().isAfter(weekLimit)).toList();

    final recent = [...notices]..sort((a, b) => b.fecha.compareTo(a.fecha));

    return HomeFeed(
      nextEvent: next,
      thisWeek: week,
      laterCount: rest.length - week.length,
      recentNotices: recent.take(maxNotices).toList(),
    );
  }
}
