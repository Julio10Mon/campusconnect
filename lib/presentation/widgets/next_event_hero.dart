import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/campus_time.dart';
import '../../core/utils/date_labels.dart';
import '../../data/models/event_model.dart';

/// Pieza central de Inicio: el próximo evento, con el día en grande.
class NextEventHero extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  const NextEventHero({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final wall = CampusTime.toWall(event.fecha);
    final when = '${DateLabels.relativeDay(event.fecha)}, ${DateLabels.time(event.fecha)}';

    return Semantics(
      button: true,
      label: 'Próximo evento: ${event.titulo}. $when. ${event.ubicacion}. Toca para ver los detalles.',
      child: Material(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.lg - 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${wall.day}',
                          style: text.headlineMedium?.copyWith(color: AppColors.orange, fontSize: 56, height: 1),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateLabels.monthShort(event.fecha),
                          style: text.titleSmall?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.titulo,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpace.md - 4),
                      _Line(icon: Icons.schedule_rounded, label: when),
                      const SizedBox(height: 6),
                      _Line(icon: Icons.place_outlined, label: event.ubicacion),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Line({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: 0.88);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
