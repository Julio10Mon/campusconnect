import '../../data/models/calendar_info_model.dart';
import '../../data/models/event_model.dart';
import '../../data/models/map_info_model.dart';
import '../../data/models/notice_model.dart';

/// Contrato académico
abstract class AcademicRepository {
  // Avisos
  Stream<List<NoticeModel>> watchNotices();
  Future<NoticeModel> getNoticeById(String id);
  Future<void> createNotice(NoticeModel notice);
  Future<void> updateNotice(NoticeModel notice);
  Future<void> deleteNotice(String id);

  // Eventos
  Stream<List<EventModel>> watchEvents();
  Future<EventModel> getEventById(String id);
  Future<void> createEvent(EventModel event);
  Future<void> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);

  // Mapa
  Stream<MapInfoModel> watchMapInfo();
  Future<void> setMapInfo(MapInfoModel info);

  // Calendario
  Stream<CalendarInfoModel> watchCalendarInfo();
  Future<void> setCalendarInfo(CalendarInfoModel info);
}
