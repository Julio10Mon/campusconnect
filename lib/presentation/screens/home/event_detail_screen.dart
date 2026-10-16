import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/campus_time.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/academic_providers.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/adaptive_image.dart';
import '../../widgets/event_card.dart' show toggleSavedEvent;
import '../../widgets/state_placeholders.dart';
import 'event_form_screen.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evento'),
        actions: [
          eventAsync.maybeWhen(
            data: (event) {
              final saved = ref.watch(savedEventIdsProvider).maybeWhen(data: (ids) => ids.contains(event.id), orElse: () => false);
              return IconButton(
                tooltip: saved ? 'Quitar de guardados' : 'Guardar evento',
                icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                onPressed: () => toggleSavedEvent(context, ref, event.id, saved),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          eventAsync.maybeWhen(
            data: (event) => userAsync.maybeWhen(
              data: (user) {
                final canManage = user.rol == UserRole.admin || user.uid == event.autorUid;
                if (!canManage) return const SizedBox.shrink();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: AppStrings.edit,
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => EventFormScreen(event: event)),
                        );
                        // Recarga el detalle con los cambios guardados.
                        ref.invalidate(eventByIdProvider(eventId));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: AppStrings.delete,
                      onPressed: () => _confirmDelete(context, ref, event),
                    ),
                  ],
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: eventAsync.when(
        loading: () => const LoadingState(),
        error: (error, _) => ErrorStateView(
          error: error,
          onRetry: () => ref.invalidate(eventByIdProvider(eventId)),
        ),
        data: (event) {
          final fecha = DateFormat("EEEE d 'de' MMMM yyyy, HH:mm", 'es_MX').format(CampusTime.toWall(event.fecha));
          final colors = Theme.of(context).colorScheme;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.fotoBase64 != null)
                  AdaptiveImage(base64Image: event.fotoBase64!, maxHeight: 380, borderRadius: BorderRadius.zero),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.isPast())
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Chip(
                            avatar: Icon(Icons.history_rounded, size: 16),
                            label: Text('Evento finalizado'),
                          ),
                        ),
                      Text(event.titulo, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          _MetaRow(icon: Icons.schedule_rounded, label: fecha, colors: colors),
                          _MetaRow(icon: Icons.place_outlined, label: event.ubicacion, colors: colors),
                        ],
                      ),
                      const Divider(height: 36),
                      Text(event.descripcion, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, EventModel event) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.confirmDeleteTitle),
        content: const Text(AppStrings.confirmDeleteMessage),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text(AppStrings.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(academicRepositoryProvider).deleteEvent(event.id);
                messenger.showSnackBar(const SnackBar(content: Text('Evento eliminado.')));
                if (context.mounted) context.pop();
              } catch (_) {
                messenger.showSnackBar(const SnackBar(content: Text('No se pudo eliminar el evento.')));
              }
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colors;
  const _MetaRow({required this.icon, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: colors.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
