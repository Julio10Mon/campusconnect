import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/notice_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/academic_providers.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/adaptive_image.dart';
import '../../widgets/state_placeholders.dart';
import 'notice_form_screen.dart';

class NoticeDetailScreen extends ConsumerWidget {
  final String noticeId;
  const NoticeDetailScreen({super.key, required this.noticeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticeAsync = ref.watch(noticeByIdProvider(noticeId));
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aviso'),
        actions: [
          noticeAsync.maybeWhen(
            data: (notice) => userAsync.maybeWhen(
              data: (user) {
                final canManage = user.rol == UserRole.admin ||
                    user.uid == notice.autorUid;
                if (!canManage) return const SizedBox.shrink();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: AppStrings.edit,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => NoticeFormScreen(notice: notice)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: AppStrings.delete,
                      onPressed: () => _confirmDelete(context, ref, notice),
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
      body: noticeAsync.when(
        loading: () => const LoadingState(),
        error: (error, _) => ErrorStateView(
          error: error,
          onRetry: () => ref.invalidate(noticeByIdProvider(noticeId)),
        ),
        data: (notice) {
          final fecha = DateFormat('EEEE d MMMM yyyy, HH:mm', 'es_MX').format(notice.fecha);
          final colors = Theme.of(context).colorScheme;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notice.fotoBase64 != null)
                  AdaptiveImage(base64Image: notice.fotoBase64!, maxHeight: 380, borderRadius: BorderRadius.zero),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notice.titulo, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        children: [
                          _MetaRow(icon: Icons.schedule_rounded, label: fecha, colors: colors),
                          if (notice.autor != null) _MetaRow(icon: Icons.person_outline_rounded, label: notice.autor!, colors: colors),
                        ],
                      ),
                      const Divider(height: 36),
                      Text(notice.descripcion, style: Theme.of(context).textTheme.bodyLarge),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, NoticeModel notice) {
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
              await ref.read(academicRepositoryProvider).deleteNotice(notice.id);
              if (context.mounted) context.pop();
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
