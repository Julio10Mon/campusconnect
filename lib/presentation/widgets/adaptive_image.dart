import 'dart:convert';

import 'package:flutter/material.dart';
import 'fullscreen_image_viewer.dart';

/// Imagen completa
class AdaptiveImage extends StatelessWidget {
  final String base64Image;
  final double maxHeight;
  final BorderRadius borderRadius;
  final bool enableFullscreen;

  const AdaptiveImage({
    super.key,
    required this.base64Image,
    this.maxHeight = 320,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.enableFullscreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: enableFullscreen ? () => showFullscreenImage(context, base64Image) : null,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: maxHeight),
          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.memory(
                base64Decode(base64Image),
                fit: BoxFit.contain,
                width: double.infinity,
              ),
              if (enableFullscreen)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                    child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
