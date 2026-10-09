import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo evento
class EventModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final DateTime fecha;
  final String? autorUid;
  final String? fotoBase64;

  const EventModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.fecha,
    this.autorUid,
    this.fotoBase64,
  });

  factory EventModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return EventModel(
      id: doc.id,
      titulo: data['titulo'] as String? ?? '',
      descripcion: data['descripcion'] as String? ?? '',
      ubicacion: data['ubicacion'] as String? ?? '',
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      autorUid: data['autorUid'] as String?,
      fotoBase64: data['fotoBase64'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'fecha': Timestamp.fromDate(fecha),
      'autorUid': autorUid,
      'fotoBase64': fotoBase64,
    };
  }
}
