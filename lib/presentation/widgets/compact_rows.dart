import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_labels.dart';
import '../../data/models/event_model.dart';
import '../../data/models/notice_model.dart';

/// Contenedor de filas compactas separadas por una línea fina.
class RowGroup extends StatelessWidget {
  final List<Widget> children;
  const RowGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(Divider(height: 1, indent: AppSpace.md, endIndent: AppSpace.md, color: colors.outline));
      items.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: items),
    );
  }
}

/// Fila de evento: día y hora a la izquierda, título y lugar a la derecha.
class EventRow extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  const EventRow({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final day = DateLabels.relativeDay(event.fecha);
    final time = DateLabels.time(event.fecha);

    return Semantics(
      button: true,
      label: '${event.titulo}. $day, $time. ${event.ubicacion}',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 76,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(time, style: text.titleMedium?.copyWith(color: colors.secondary)),
                      Text(day, style: text.labelSmall),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.titulo, style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(event.ubicacion, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de aviso: título, extracto y cuándo se publicó.
class NoticeRow extends StatelessWidget {
  final NoticeModel notice;
  final VoidCallback onTap;
  const NoticeRow({super.key, required this.notice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final when = DateLabels.relativeDay(notice.fecha);

    return Semantics(
      button: true,
      label: '${notice.titulo}. Publicado $when.',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notice.titulo, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(notice.descripcion, style: text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Text(when, style: text.labelSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
