import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_model.dart';
import '../../providers/academic_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/adaptive_image.dart';
import '../../widgets/events_month_calendar.dart';
import '../../widgets/state_placeholders.dart';
import 'calendar_edit_screen.dart';

/// Calendario de eventos (solo consulta) + calendario académico en imagen.
/// Se muestra dentro de la pestaña "Explorar".
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);
    final calendarAsync = ref.watch(calendarInfoStreamProvider);
    final userAsync = ref.watch(currentUserProvider);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final canEdit = userAsync.maybeWhen(data: (u) => u.rol == UserRole.admin, orElse: () => false);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(eventsStreamProvider);
        ref.invalidate(calendarInfoStreamProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          eventsAsync.when(
            loading: () => const Padding(padding: EdgeInsets.all(48), child: LoadingState()),
            error: (e, _) => ErrorStateView(error: e, onRetry: () => ref.invalidate(eventsStreamProvider)),
            data: (events) => EventsMonthCalendar(events: events),
          ),
          const Divider(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Text('Calendario académico', style: text.titleMedium)),
                if (canEdit)
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CalendarEditScreen(current: calendarAsync.value)),
                    ),
                  ),
              ],
            ),
          ),
          calendarAsync.when(
            loading: () => const Padding(padding: EdgeInsets.all(32), child: LoadingState()),
            error: (e, _) => ErrorStateView(error: e, onRetry: () => ref.invalidate(calendarInfoStreamProvider)),
            data: (info) {
              final hasText = info.texto != null && info.texto!.trim().isNotEmpty;
              if (info.imagenBase64 == null && !hasText) {
                return EmptyState(
                  message: canEdit
                      ? 'Aún no subes el calendario académico. Toca "Editar" para agregarlo.'
                      : 'El calendario académico todavía no está disponible.',
                  icon: Icons.calendar_month_outlined,
                );
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (info.imagenBase64 != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.outline),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AdaptiveImage(base64Image: info.imagenBase64!, maxHeight: 420, borderRadius: BorderRadius.zero),
                      ),
                    if (hasText) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(info.texto!, style: text.bodyLarge),
                      ),
                    ],
                    if (info.imagenBase64 != null) ...[
                      const SizedBox(height: 8),
                      Center(child: Text('Toca la imagen para verla en pantalla completa y hacer zoom', style: text.labelSmall)),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
