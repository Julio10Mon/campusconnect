import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/campus_time.dart';
import '../../../core/utils/date_labels.dart';
import '../../../domain/home_feed.dart';
import '../../providers/academic_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/compact_rows.dart';
import '../../widgets/logo_app.dart';
import '../../widgets/next_event_hero.dart';
import '../../widgets/state_placeholders.dart';
import 'event_form_screen.dart';

/// Inicio: lo próximo y lo reciente, calculado con datos reales.
class HomeScreen extends ConsumerWidget {
  final VoidCallback onSeeEvents;
  final VoidCallback onSeeNotices;
  const HomeScreen({super.key, required this.onSeeEvents, required this.onSeeNotices});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);
    final noticesAsync = ref.watch(noticesStreamProvider);
    final userAsync = ref.watch(currentUserProvider);
    final text = Theme.of(context).textTheme;

    final firstName = userAsync.maybeWhen(
      data: (u) => u.nombre.trim().split(RegExp(r'\s+')).first,
      orElse: () => '',
    );
    final greeting = firstName.isEmpty ? 'Hola' : 'Hola, $firstName';

    Future<void> refresh() async {
      ref.invalidate(eventsStreamProvider);
      ref.invalidate(noticesStreamProvider);
    }

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(8), child: LogoApp(size: 32)),
        title: const Text('CampusConnect'),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Builder(builder: (context) {
          if (eventsAsync.isLoading && !eventsAsync.hasValue || noticesAsync.isLoading && !noticesAsync.hasValue) {
            return const LoadingState();
          }
          if (eventsAsync.hasError && !eventsAsync.hasValue) {
            return ErrorStateView(error: eventsAsync.error!, onRetry: refresh);
          }
          final feed = HomeFeed.build(
            events: eventsAsync.valueOrNull ?? const [],
            notices: noticesAsync.valueOrNull ?? const [],
          );

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.md, AppSpace.gutter, AppSpace.xl),
            children: [
              Text(greeting, style: text.headlineSmall),
              const SizedBox(height: 2),
              Text(DateLabels.longDate(CampusTime.nowWall()), style: text.bodySmall),
              const SizedBox(height: AppSpace.lg - 4),

              // Próximo evento
              if (feed.nextEvent != null)
                NextEventHero(event: feed.nextEvent!, onTap: () => context.push('/home/event/${feed.nextEvent!.id}'))
              else
                _NoUpcoming(onPublish: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventFormScreen()))),

              // Esta semana
              if (feed.thisWeek.isNotEmpty) ...[
                const SizedBox(height: AppSpace.lg),
                _SectionHeader(title: 'Esta semana', action: 'Ver eventos', onAction: onSeeEvents),
                const SizedBox(height: AppSpace.sm),
                RowGroup(children: [
                  for (final e in feed.thisWeek.take(4))
                    EventRow(key: ValueKey('home-${e.id}'), event: e, onTap: () => context.push('/home/event/${e.id}')),
                ]),
              ] else if (feed.nextEvent != null && feed.laterCount > 0) ...[
                const SizedBox(height: AppSpace.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onSeeEvents,
                    child: Text('Hay ${feed.laterCount} ${feed.laterCount == 1 ? 'evento más' : 'eventos más'} en las próximas semanas'),
                  ),
                ),
              ],

              // Avisos
              const SizedBox(height: AppSpace.lg),
              _SectionHeader(title: 'Avisos recientes', action: 'Ver avisos', onAction: onSeeNotices),
              const SizedBox(height: AppSpace.sm),
              if (feed.recentNotices.isEmpty)
                const EmptyState(message: 'Todavía no hay avisos. Cuando se publique uno, aparecerá aquí.', icon: Icons.campaign_outlined)
              else
                RowGroup(children: [
                  for (final n in feed.recentNotices)
                    NoticeRow(key: ValueKey('home-n-${n.id}'), notice: n, onTap: () => context.push('/home/notice/${n.id}')),
                ]),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;
  const _SectionHeader({required this.title, required this.action, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
        TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }
}

class _NoUpcoming extends StatelessWidget {
  final VoidCallback onPublish;
  const _NoUpcoming({required this.onPublish});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpace.lg - 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No hay eventos próximos', style: text.titleMedium),
          const SizedBox(height: 4),
          Text('Publica el primero para que toda la comunidad lo vea.', style: text.bodyMedium),
          const SizedBox(height: AppSpace.md),
          FilledButton.icon(onPressed: onPublish, icon: const Icon(Icons.add), label: const Text('Publicar evento')),
        ],
      ),
    );
  }
}
