import 'package:flutter/material.dart';
import 'motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/campus_time.dart';
import '../../data/models/event_model.dart';
import '../providers/academic_providers.dart';
import '../providers/app_providers.dart';
import 'adaptive_image.dart';

/// Tarjeta de evento con botón real de guardar.
class EventCard extends ConsumerWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final wall = CampusTime.toWall(event.fecha);
    final dia = DateFormat('d', 'es_MX').format(wall);
    final mes = DateFormat('MMM', 'es_MX').format(wall).toUpperCase();
    final hora = DateFormat('HH:mm', 'es_MX').format(wall);
    final past = event.isPast();
    final accent = past ? colors.onSurfaceVariant : colors.secondary;

    final saved = ref.watch(savedEventIdsProvider).maybeWhen(data: (ids) => ids.contains(event.id), orElse: () => false);

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
              padding: const EdgeInsets.fromLTRB(14, 14, 6, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mes, style: TextStyle(color: accent, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                        Text(dia, style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w800, height: 1.1)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.titulo, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(event.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 14,
                          runSpacing: 4,
                          children: [
                            _MetaTag(icon: Icons.schedule_rounded, label: hora),
                            _MetaTag(icon: Icons.place_outlined, label: event.ubicacion),
                            if (past) const _MetaTag(icon: Icons.history_rounded, label: 'Finalizado'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: saved ? 'Quitar de guardados' : 'Guardar evento',
                    icon: AnimatedSwitcher(
                      duration: Motion.fast,
                      transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                      child: Icon(
                        saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        key: ValueKey(saved),
                        color: saved ? colors.primary : colors.onSurfaceVariant,
                      ),
                    ),
                    onPressed: () => toggleSavedEvent(context, ref, event.id, saved),
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

/// Guarda o quita un evento de los guardados del usuario actual.
Future<void> toggleSavedEvent(BuildContext context, WidgetRef ref, String eventId, bool currentlySaved) async {
  final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
  if (uid == null) return;
  final repo = ref.read(academicRepositoryProvider);
  final messenger = ScaffoldMessenger.of(context);
  try {
    if (currentlySaved) {
      await repo.unsaveEvent(uid, eventId);
    } else {
      await repo.saveEvent(uid, eventId);
      messenger.showSnackBar(const SnackBar(content: Text('Evento guardado en tu perfil.')));
    }
  } catch (_) {
    messenger.showSnackBar(const SnackBar(content: Text('No se pudo actualizar tus guardados. Inténtalo de nuevo.')));
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
        Flexible(child: Text(label, style: Theme.of(context).textTheme.labelMedium, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
