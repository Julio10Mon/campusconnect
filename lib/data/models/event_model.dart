import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo evento
class EventModel {
  final String id;
  final String titulo;
  final String descripcion;

  /// Texto mostrado de la ubicación (siempre presente; compatible con eventos antiguos).
  final String ubicacion;

  /// Id estable del catálogo de ubicaciones, o `otra`. Nulo en eventos antiguos.
  final String? ubicacionId;

  /// Instante absoluto del evento.
  final DateTime fecha;
  final String? autorUid;
  final String? fotoBase64;

  /// Huella para detectar duplicados exactos.
  final String? huella;

  const EventModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.fecha,
    this.ubicacionId,
    this.autorUid,
    this.fotoBase64,
    this.huella,
  });

  /// ¿Ya terminó (su fecha quedó atrás)?
  bool isPast([DateTime? now]) => !fecha.toUtc().isAfter((now ?? DateTime.now()).toUtc());

  factory EventModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EventModel(
      id: doc.id,
      titulo: data['titulo'] as String? ?? '',
      descripcion: data['descripcion'] as String? ?? '',
      ubicacion: data['ubicacion'] as String? ?? '',
      ubicacionId: data['ubicacionId'] as String?,
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      autorUid: data['autorUid'] as String?,
      fotoBase64: data['fotoBase64'] as String?,
      huella: data['huella'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'ubicacionId': ubicacionId,
      'fecha': Timestamp.fromDate(fecha),
      'autorUid': autorUid,
      'fotoBase64': fotoBase64,
      'huella': huella,
    };
  }
}
