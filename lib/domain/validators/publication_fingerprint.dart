import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/utils/text_utils.dart';

/// Huella (hash) que identifica una publicación para detectar duplicados
/// exactos. Solo coincide si TODOS los datos clave son iguales: dos eventos
/// parecidos pero distintos (otra hora, otra ubicación) no se bloquean.
class PublicationFingerprint {
  PublicationFingerprint._();

  /// Evento: título + minuto exacto + ubicación.
  static String event({required String titulo, required DateTime fecha, required String ubicacion}) {
    final minute = fecha.toUtc().millisecondsSinceEpoch ~/ 60000;
    return _hash([TextUtils.normalize(titulo), '$minute', TextUtils.normalize(ubicacion)]);
  }

  /// Aviso: título + descripción + autor + día (no se bloquea repetirlo otro día).
  static String notice({
    required String titulo,
    required String descripcion,
    required String? autorUid,
    required DateTime dia,
  }) {
    final day = dia.toUtc();
    return _hash([
      TextUtils.normalize(titulo),
      TextUtils.normalize(descripcion),
      autorUid ?? '',
      '${day.year}-${day.month}-${day.day}',
    ]);
  }

  static String _hash(List<String> parts) {
    return sha256.convert(utf8.encode(parts.join('|'))).toString();
  }
}
