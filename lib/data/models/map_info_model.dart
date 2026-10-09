import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo mapa
class MapInfoModel {
  final String? imagenBase64;
  final String? texto;

  const MapInfoModel({this.imagenBase64, this.texto});

  factory MapInfoModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MapInfoModel(
      imagenBase64: data['imagenBase64'] as String?,
      texto: data['texto'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'imagenBase64': imagenBase64, 'texto': texto};
  }
}
