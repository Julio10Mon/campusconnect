import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Imágenes base64
class ImageUtils {
  ImageUtils._();

  static final ImagePicker _picker = ImagePicker();

  /// Elegir y comprimir
  static Future<String?> pickAndEncodeImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 70,
    );
    if (file == null) return null;

    final Uint8List bytes = await file.readAsBytes();

    // Límite 1 MiB
    const maxBytes = 700 * 1024;
    if (bytes.lengthInBytes > maxBytes) {
      throw Exception(
        'La imagen es demasiado grande incluso comprimida. Prueba con otra foto.',
      );
    }

    return base64Encode(bytes);
  }
}
