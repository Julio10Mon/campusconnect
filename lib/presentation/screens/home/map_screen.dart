import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/campus_locations.dart';
import '../../../data/models/user_model.dart';
import '../../providers/academic_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/adaptive_image.dart';
import '../../widgets/state_placeholders.dart';
import 'map_edit_screen.dart';

/// Mapa de ubicaciones (solo consulta): croquis del campus y directorio de
/// edificios. Se muestra dentro de la pestaña "Explorar".
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapInfoAsync = ref.watch(mapInfoStreamProvider);
    final userAsync = ref.watch(currentUserProvider);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final canEdit = userAsync.maybeWhen(data: (u) => u.rol == UserRole.admin, orElse: () => false);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(mapInfoStreamProvider),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Row(
            children: [
              Expanded(child: Text('Croquis del campus', style: text.titleMedium)),
              if (canEdit)
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MapEditScreen(current: mapInfoAsync.value)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          mapInfoAsync.when(
            loading: () => const Padding(padding: EdgeInsets.all(32), child: LoadingState()),
            error: (e, _) => ErrorStateView(error: e, onRetry: () => ref.invalidate(mapInfoStreamProvider)),
            data: (info) {
              final hasText = info.texto != null && info.texto!.trim().isNotEmpty;
              if (info.imagenBase64 == null && !hasText) {
                return EmptyState(
                  message: canEdit
                      ? 'Aún no subes el croquis del campus. Toca "Editar" para agregarlo.'
                      : 'El croquis del campus todavía no está disponible.',
                  icon: Icons.map_outlined,
                );
              }
              return Column(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: colors.primary),
                            const SizedBox(width: 8),
                            Text('Cómo llegar', style: text.titleSmall),
                          ]),
                          const SizedBox(height: 10),
                          Text(info.texto!, style: text.bodyLarge),
                        ],
                      ),
                    ),
                  ],
                  if (info.imagenBase64 != null) ...[
                    const SizedBox(height: 8),
                    Center(child: Text('Toca la imagen para verla en pantalla completa y hacer zoom', style: text.labelSmall)),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Text('Directorio de edificios', style: text.titleMedium),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (final loc in CampusLocations.edificios)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: colors.primary.withValues(alpha: 0.14),
                      child: Text(loc.letra ?? '', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800)),
                    ),
                    title: Text(loc.nombre),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (final loc in CampusLocations.deportivas)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.sports_soccer_outlined, color: colors.primary),
                    title: Text(loc.nombre),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
