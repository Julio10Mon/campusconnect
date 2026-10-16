import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/validators/event_schedule_validator.dart';
import '../../domain/validators/publication_fingerprint.dart';
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

  /// Crea un aviso de forma idempotente: el id del documento es la huella del
  /// contenido, así que un doble envío no puede generar dos registros.
  Future<void> createNotice(NoticeModel notice) async {
    final huella = PublicationFingerprint.notice(
      titulo: notice.titulo,
      descripcion: notice.descripcion,
      autorUid: notice.autorUid,
      dia: DateTime.now(),
    );
    final ref = _firestore.collection('avisos').doc(huella);
    final data = notice.toMap()..['huella'] = huella;
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) throw const DuplicatePublicationException();
      tx.set(ref, data);
    });
  }

  Future<void> updateNotice(NoticeModel notice) {
    // No se sobrescribe la huella original al editar.
    return _firestore.collection('avisos').doc(notice.id).update(notice.toMap()..remove('huella'));
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
        .map((s) => _dedupeEvents(s.docs.map(EventModel.fromDoc).toList()));
  }

  /// Oculta (sin borrar) registros idénticos que ya existieran en la base de
  /// datos: mismo título, minuto y ubicación. Se conserva el primero.
  List<EventModel> _dedupeEvents(List<EventModel> events) {
    final seen = <String>{};
    final result = <EventModel>[];
    for (final e in events) {
      final key = PublicationFingerprint.event(titulo: e.titulo, fecha: e.fecha, ubicacion: e.ubicacion);
      if (seen.add(key)) result.add(e);
    }
    return result;
  }

  Future<EventModel> getEventById(String id) async {
    final doc = await _firestore.collection('eventos').doc(id).get();
    if (!doc.exists) {
      throw Exception('El evento solicitado ya no está disponible.');
    }
    return EventModel.fromDoc(doc);
  }

  /// Crea un evento de forma idempotente y validada.
  ///
  /// * La fecha debe ser futura (se vuelve a comprobar aquí, no solo en el
  ///   formulario).
  /// * El id del documento es la huella (título + minuto + ubicación), de modo
  ///   que un doble envío cae sobre el mismo documento y se rechaza.
  /// * También se revisan eventos anteriores sin huella con el mismo contenido.
  Future<void> createEvent(EventModel event) async {
    EventScheduleValidator.ensureValid(event.fecha);
    final huella = PublicationFingerprint.event(
      titulo: event.titulo,
      fecha: event.fecha,
      ubicacion: event.ubicacion,
    );
    if (await _existsDuplicate(event, huella, excludeId: null)) {
      throw const DuplicatePublicationException();
    }
    final ref = _firestore.collection('eventos').doc(huella);
    final data = event.toMap()..['huella'] = huella;
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) throw const DuplicatePublicationException();
      tx.set(ref, data);
    });
  }

  /// Actualiza un evento. Si cambia la fecha, debe ser futura.
  Future<void> updateEvent(EventModel event) async {
    final ref = _firestore.collection('eventos').doc(event.id);
    final current = await ref.get();
    final originalFecha = (current.data()?['fecha'] as Timestamp?)?.toDate();
    EventScheduleValidator.ensureValid(event.fecha, originalFecha: originalFecha);

    final huella = PublicationFingerprint.event(
      titulo: event.titulo,
      fecha: event.fecha,
      ubicacion: event.ubicacion,
    );
    if (await _existsDuplicate(event, huella, excludeId: event.id)) {
      throw const DuplicatePublicationException();
    }
    final data = event.toMap()..['huella'] = huella;
    await ref.update(data);
  }

  /// ¿Existe otro evento idéntico (mismo título, minuto y ubicación)?
  Future<bool> _existsDuplicate(EventModel event, String huella, {required String? excludeId}) async {
    final snap = await _firestore
        .collection('eventos')
        .where('titulo', isEqualTo: event.titulo.trim())
        .limit(25)
        .get();
    for (final doc in snap.docs) {
      if (doc.id == excludeId) continue;
      final other = EventModel.fromDoc(doc);
      final otherHuella = PublicationFingerprint.event(
        titulo: other.titulo,
        fecha: other.fecha,
        ubicacion: other.ubicacion,
      );
      if (otherHuella == huella) return true;
    }
    return false;
  }

  // Guardados (favoritos): el id del documento es el id del evento, por lo que
  // guardar dos veces es imposible por construcción.
  Stream<Set<String>> watchSavedEventIds(String uid) {
    return _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('guardados')
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toSet());
  }

  Future<void> saveEvent(String uid, String eventId) {
    return _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('guardados')
        .doc(eventId)
        .set({'eventoId': eventId, 'guardadoEn': FieldValue.serverTimestamp()});
  }

  Future<void> unsaveEvent(String uid, String eventId) {
    return _firestore.collection('usuarios').doc(uid).collection('guardados').doc(eventId).delete();
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
