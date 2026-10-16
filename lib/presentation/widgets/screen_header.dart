import 'package:flutter/material.dart';

/// Título de AppBar: una sola línea, en el tipo de títulos de la app.
class ScreenHeaderTitle extends StatelessWidget {
  final String title;

  const ScreenHeaderTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
