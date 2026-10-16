import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/campus_time.dart';
import '../../../core/utils/date_labels.dart';
import '../../../domain/home_feed.dart';
import '../../providers/academic_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/compact_rows.dart';
import '../../widgets/logo_app.dart';
import '../../widgets/motion.dart';
import '../../widgets/next_event_hero.dart';
import '../../widgets/state_placeholders.dart';
import 'event_form_screen.dart';

/// Inicio: lo próximo y lo reciente, calculado con datos reales.
class HomeScreen extends ConsumerWidget {
  final VoidCallback onSeeEvents;
  final VoidCallback onSeeNotices;
  final VoidCallback onSeeExplore;
  const HomeScreen({super.key, required this.onSeeEvents, required this.onSeeNotices, required this.onSeeExplore});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);
    final noticesAsync = ref.watch(noticesStreamProvider);
    final userAsync = ref.watch(currentUserProvider);

    final firstName = userAsync.maybeWhen(
      data: (u) => u.nombre.trim().split(RegExp(r'\s+')).first,
      orElse: () => '',
    );

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
              FadeSlideIn(
                child: _WelcomeBanner(greeting: firstName.isEmpty ? 'Bienvenido de nuevo' : 'Bienvenido de nuevo, $firstName', date: DateLabels.longDate(CampusTime.nowWall())),
              ),
              const SizedBox(height: AppSpace.md),

              // Accesos rápidos
              FadeSlideIn(
                delay: Motion.stagger(1),
                child: Row(
                  children: [
                    _QuickAction(icon: Icons.campaign_rounded, label: 'Avisos', color: AppColors.orange, onTap: onSeeNotices),
                    _QuickAction(icon: Icons.event_rounded, label: 'Eventos', color: const Color(0xFFE5484D), onTap: onSeeEvents),
                    _QuickAction(icon: Icons.explore_rounded, label: 'Explorar', color: AppColors.blue, onTap: onSeeExplore),
                    _QuickAction(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Publicar',
                      color: AppColors.lightBlue,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventFormScreen())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.lg - 4),

              // Próximo evento
              FadeSlideIn(
                delay: Motion.stagger(2),
                child: feed.nextEvent != null
                    ? NextEventHero(event: feed.nextEvent!, onTap: () => context.push('/home/event/${feed.nextEvent!.id}'))
                    : _NoUpcoming(onPublish: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventFormScreen()))),
              ),

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

/// Acceso rápido a una sección: ícono dentro de un círculo tintado y etiqueta.
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: ExcludeSemantics(
          child: PressableScale(
            pressedScale: 0.94,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(label, style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner de bienvenida con degradado institucional.
class _WelcomeBanner extends StatelessWidget {
  final String greeting;
  final String date;
  const _WelcomeBanner({required this.greeting, required this.date});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpace.lg - 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: text.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text('¡Que tengas un gran día!', style: text.bodyMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: 10),
                Text(date, style: text.labelMedium?.copyWith(color: Colors.white60)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.school_rounded, size: 56, color: Colors.white24),
        ],
      ),
    );
  }
}
