import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/event_model.dart';
import 'adaptive_image.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final dia = DateFormat('d', 'es_MX').format(event.fecha);
    final mes = DateFormat('MMM', 'es_MX').format(event.fecha).toUpperCase();
    final hora = DateFormat('HH:mm', 'es_MX').format(event.fecha);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.fotoBase64 != null)
              AdaptiveImage(base64Image: event.fotoBase64!, maxHeight: 200, borderRadius: BorderRadius.zero),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bloque fecha
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mes, style: TextStyle(color: colors.secondary, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                        Text(dia, style: TextStyle(color: colors.secondary, fontSize: 20, fontWeight: FontWeight.w800, height: 1.1)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.titulo, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(event.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 14,
                          runSpacing: 4,
                          children: [
                            _MetaTag(icon: Icons.schedule_rounded, label: hora),
                            _MetaTag(icon: Icons.place_outlined, label: event.ubicacion),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelMedium, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
