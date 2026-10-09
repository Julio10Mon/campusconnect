import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../providers/academic_providers.dart';
import '../../widgets/event_card.dart';
import '../../widgets/logo_app.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/state_placeholders.dart';
import 'event_form_screen.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(8), child: LogoApp(size: 32)),
        title: const ScreenHeaderTitle(eyebrow: AppStrings.appName, title: AppStrings.navEvents),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EventFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo evento'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(eventsStreamProvider),
        child: eventsAsync.when(
          loading: () => const LoadingState(),
          error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(eventsStreamProvider)),
          data: (events) {
            if (events.isEmpty) {
              return const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: EmptyState(message: AppStrings.emptyEvents, icon: Icons.event_outlined),
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 12, bottom: 96),
              itemCount: events.length,
              itemBuilder: (context, i) => EventCard(
                event: events[i],
                onTap: () => context.push('/home/event/${events[i].id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
