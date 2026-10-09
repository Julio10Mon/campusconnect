import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../providers/academic_providers.dart';
import '../../widgets/notice_card.dart';
import '../../widgets/logo_app.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/state_placeholders.dart';
import 'notice_form_screen.dart';

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(8), child: LogoApp(size: 32)),
        title: const ScreenHeaderTitle(eyebrow: AppStrings.appName, title: AppStrings.navNotices),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NoticeFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo aviso'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(noticesStreamProvider),
        child: noticesAsync.when(
          loading: () => const LoadingState(),
          error: (error, _) => ErrorStateView(
            error: error,
            onRetry: () => ref.invalidate(noticesStreamProvider),
          ),
          data: (notices) {
            if (notices.isEmpty) {
              return const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: EmptyState(message: AppStrings.emptyNotices, icon: Icons.campaign_outlined),
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 12, bottom: 96),
              itemCount: notices.length,
              itemBuilder: (context, i) {
                final notice = notices[i];
                return NoticeCard(
                  notice: notice,
                  onTap: () => context.push('/home/notice/${notice.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
