import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo aviso
class NoticeModel {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String? autor;
  final String? autorUid;
  final String? fotoBase64;

  /// Huella para detectar duplicados exactos.
  final String? huella;

  const NoticeModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    this.autor,
    this.autorUid,
    this.fotoBase64,
    this.huella,
  });

  factory NoticeModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NoticeModel(
      id: doc.id,
      titulo: data['titulo'] as String? ?? '',
      descripcion: data['descripcion'] as String? ?? '',
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      autor: data['autor'] as String?,
      autorUid: data['autorUid'] as String?,
      fotoBase64: data['fotoBase64'] as String?,
      huella: data['huella'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': Timestamp.fromDate(fecha),
      'autor': autor,
      'autorUid': autorUid,
      'fotoBase64': fotoBase64,
      'huella': huella,
    };
  }
}
