import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/user_model.dart';
import '../../providers/academic_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/adaptive_image.dart';
import '../../widgets/logo_app.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/state_placeholders.dart';
import 'calendar_edit_screen.dart';

/// Calendario académico
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarAsync = ref.watch(calendarInfoStreamProvider);
    final userAsync = ref.watch(currentUserProvider);
    final colors = Theme.of(context).colorScheme;
    final canEdit = userAsync.maybeWhen(
      data: (user) => user.rol == UserRole.admin,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(8), child: LogoApp(size: 32)),
        title: const ScreenHeaderTitle(eyebrow: AppStrings.appName, title: AppStrings.navCalendar),
        actions: [
          if (canEdit)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filledTonal(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar calendario',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CalendarEditScreen(current: calendarAsync.value)),
                ),
              ),
            ),
        ],
      ),
      body: calendarAsync.when(
        loading: () => const LoadingState(),
        error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(calendarInfoStreamProvider)),
        data: (info) {
          final hasContent = (info.imagenBase64 != null) || (info.texto != null && info.texto!.trim().isNotEmpty);
          if (!hasContent) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: EmptyState(
                message: canEdit
                    ? 'Aún no subes el calendario académico. Toca el ícono de arriba para agregarlo.'
                    : AppStrings.emptyCalendar,
                icon: Icons.calendar_month_outlined,
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (info.imagenBase64 != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.outline),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6))],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: AdaptiveImage(base64Image: info.imagenBase64!, maxHeight: 420, borderRadius: BorderRadius.zero),
                  ),
                if (info.texto != null && info.texto!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: colors.primary),
                            const SizedBox(width: 8),
                            Text('Notas', style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(info.texto!, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ],
                if (info.imagenBase64 != null) ...[
                  const SizedBox(height: 8),
                  Center(child: Text('Toca la imagen para verla en pantalla completa y hacer zoom', style: Theme.of(context).textTheme.labelSmall)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
