import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo calendario
class CalendarInfoModel {
  final String? imagenBase64;
  final String? texto;

  const CalendarInfoModel({this.imagenBase64, this.texto});

  factory CalendarInfoModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CalendarInfoModel(
      imagenBase64: data['imagenBase64'] as String?,
      texto: data['texto'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'imagenBase64': imagenBase64, 'texto': texto};
  }
}
