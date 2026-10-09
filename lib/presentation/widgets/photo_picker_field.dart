import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/image_utils.dart';

/// Selector de foto
class PhotoPickerField extends StatelessWidget {
  final String? base64Image;
  final ValueChanged<String?> onChanged;
  final double height;
  final BorderRadius borderRadius;

  /// Ajuste de imagen
  final BoxFit fit;

  const PhotoPickerField({
    super.key,
    required this.base64Image,
    required this.onChanged,
    this.height = 180,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.fit = BoxFit.contain,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final encoded = await ImageUtils.pickAndEncodeImage(source: source);
      if (encoded != null) onChanged(encoded);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showSourceSheet(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(alignment: Alignment.centerLeft, child: Text('Foto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pick(context, ImageSource.camera);
              },
            ),
            if (base64Image != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.error),
                title: Text('Quitar foto', style: TextStyle(color: colors.error)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onChanged(null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ícono y texto
    final compact = height < 100;
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _showSourceSheet(context),
      child: Container(
        height: height,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: borderRadius,
          border: Border.all(color: colors.outline),
          image: base64Image != null
              ? DecorationImage(image: MemoryImage(base64Decode(base64Image!)), fit: fit)
              : null,
        ),
        child: base64Image == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Icon(Icons.add_a_photo_outlined, color: colors.primary, size: compact ? 18 : 26),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 10),
                        Text('Agregar foto (opcional)', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              )
            : Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black54,
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ),
      ),
    );
  }
}
