import '../../domain/repositories/academic_repository.dart';
import '../datasources/academic_remote_datasource.dart';
import '../models/calendar_info_model.dart';
import '../models/event_model.dart';
import '../models/map_info_model.dart';
import '../models/notice_model.dart';

/// Repositorio académico
class AcademicRepositoryImpl implements AcademicRepository {
  final AcademicRemoteDataSource _dataSource;

  AcademicRepositoryImpl(this._dataSource);

  // Avisos
  @override
  Stream<List<NoticeModel>> watchNotices() => _dataSource.watchNotices();
  @override
  Future<NoticeModel> getNoticeById(String id) => _dataSource.getNoticeById(id);
  @override
  Future<void> createNotice(NoticeModel notice) => _dataSource.createNotice(notice);
  @override
  Future<void> updateNotice(NoticeModel notice) => _dataSource.updateNotice(notice);
  @override
  Future<void> deleteNotice(String id) => _dataSource.deleteNotice(id);

  // Eventos
  @override
  Stream<List<EventModel>> watchEvents() => _dataSource.watchEvents();
  @override
  Future<EventModel> getEventById(String id) => _dataSource.getEventById(id);
  @override
  Future<void> createEvent(EventModel event) => _dataSource.createEvent(event);
  @override
  Future<void> updateEvent(EventModel event) => _dataSource.updateEvent(event);
  @override
  Future<void> deleteEvent(String id) => _dataSource.deleteEvent(id);

  // Mapa
  @override
  Stream<MapInfoModel> watchMapInfo() => _dataSource.watchMapInfo();
  @override
  Future<void> setMapInfo(MapInfoModel info) => _dataSource.setMapInfo(info);

  // Calendario
  @override
  Stream<CalendarInfoModel> watchCalendarInfo() => _dataSource.watchCalendarInfo();
  @override
  Future<void> setCalendarInfo(CalendarInfoModel info) => _dataSource.setCalendarInfo(info);
}
