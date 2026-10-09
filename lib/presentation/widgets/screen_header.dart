import 'package:flutter/material.dart';

/// Título AppBar
class ScreenHeaderTitle extends StatelessWidget {
  final String eyebrow;
  final String title;

  const ScreenHeaderTitle({super.key, required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.6),
        ),
        const SizedBox(height: 1),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
      ],
    );
  }
}
