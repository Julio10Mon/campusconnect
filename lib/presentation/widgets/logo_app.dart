import 'package:flutter/material.dart';

/// Logo app
class LogoApp extends StatelessWidget {
  /// Tamaño
  final double size;

  /// Radio esquinas
  final BorderRadius? borderRadius;

  const LogoApp({super.key, this.size = 48, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(size * 0.26),
      child: Image.asset(
        'assets/icon/icon.png',
        width: size,
        height: size,
        // BoxFit.contain
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
