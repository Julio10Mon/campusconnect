import 'package:flutter/material.dart';

/// Bloque de fecha (mes y día) para tarjetas y detalles de eventos.
class DateBadge extends StatelessWidget {
  final String day;
  final String month;
  final Color color;
  final double size;
  final bool solid;

  const DateBadge({
    super.key,
    required this.day,
    required this.month,
    required this.color,
    this.size = 56,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = solid ? Colors.white : color;
    return Semantics(
      label: '$day de $month',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: solid ? color : color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(month, style: TextStyle(color: foreground, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
              Text(day, style: TextStyle(color: foreground, fontSize: size * 0.36, fontWeight: FontWeight.w800, height: 1.1)),
            ],
          ),
        ),
      ),
    );
  }
}
