import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/calendar_info_model.dart';
import '../models/event_model.dart';
import '../models/map_info_model.dart';
import '../models/notice_model.dart';

/// Datasource académico
class AcademicRemoteDataSource {
  final FirebaseFirestore _firestore;

  AcademicRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Avisos
  Stream<List<NoticeModel>> watchNotices() {
    return _firestore
        .collection('avisos')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((s) => s.docs.map(NoticeModel.fromDoc).toList());
  }

  Future<NoticeModel> getNoticeById(String id) async {
    final doc = await _firestore.collection('avisos').doc(id).get();
    if (!doc.exists) {
      throw Exception('El aviso solicitado ya no está disponible.');
    }
    return NoticeModel.fromDoc(doc);
  }

  Future<void> createNotice(NoticeModel notice) {
    return _firestore.collection('avisos').add(notice.toMap());
  }

  Future<void> updateNotice(NoticeModel notice) {
    return _firestore.collection('avisos').doc(notice.id).update(notice.toMap());
  }

  Future<void> deleteNotice(String id) {
    return _firestore.collection('avisos').doc(id).delete();
  }

  // Eventos
  Stream<List<EventModel>> watchEvents() {
    return _firestore
        .collection('eventos')
        .orderBy('fecha')
        .snapshots()
        .map((s) => s.docs.map(EventModel.fromDoc).toList());
  }

  Future<EventModel> getEventById(String id) async {
    final doc = await _firestore.collection('eventos').doc(id).get();
    if (!doc.exists) {
      throw Exception('El evento solicitado ya no está disponible.');
    }
    return EventModel.fromDoc(doc);
  }

  Future<void> createEvent(EventModel event) {
    return _firestore.collection('eventos').add(event.toMap());
  }

  Future<void> updateEvent(EventModel event) {
    return _firestore.collection('eventos').doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String id) {
    return _firestore.collection('eventos').doc(id).delete();
  }

  // Mapa
  Stream<MapInfoModel> watchMapInfo() {
    return _firestore
        .collection('configuracion')
        .doc('mapa')
        .snapshots()
        .map((doc) => doc.exists ? MapInfoModel.fromDoc(doc) : const MapInfoModel());
  }

  Future<void> setMapInfo(MapInfoModel info) {
    return _firestore.collection('configuracion').doc('mapa').set(info.toMap());
  }

  // Calendario
  Stream<CalendarInfoModel> watchCalendarInfo() {
    return _firestore
        .collection('configuracion')
        .doc('calendario')
        .snapshots()
        .map((doc) => doc.exists ? CalendarInfoModel.fromDoc(doc) : const CalendarInfoModel());
  }

  Future<void> setCalendarInfo(CalendarInfoModel info) {
    return _firestore.collection('configuracion').doc('calendario').set(info.toMap());
  }
}
