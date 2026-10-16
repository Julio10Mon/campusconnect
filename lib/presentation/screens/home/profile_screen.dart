import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/notice_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/academic_providers.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/motion.dart';
import '../../widgets/event_card.dart';
import '../../widgets/logo_app.dart';
import '../../widgets/notice_card.dart';
import '../../widgets/state_placeholders.dart';
import 'admin/user_management_screen.dart';
import 'edit_profile_screen.dart';

enum _ProfileTab { events, notices, saved }

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  _ProfileTab _tab = _ProfileTab.events;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(padding: EdgeInsets.all(10), child: LogoApp(size: 32)),
        actions: [
          userAsync.maybeWhen(
            data: (user) => Padding(
              padding: const EdgeInsets.only(right: 12, top: 4),
              child: IconButton.filledTonal(
                style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18)),
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                tooltip: 'Editar perfil',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const LoadingState(),
        error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(currentUserProvider)),
        data: (user) => _buildProfile(context, user, colors),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, UserModel user, ColorScheme colors) {
    final text = Theme.of(context).textTheme;
    final fotoBytes = user.fotoBase64 != null ? base64Decode(user.fotoBase64!) : null;
    final esAdmin = user.rol == UserRole.admin;

    final events = ref.watch(eventsStreamProvider).valueOrNull ?? const <EventModel>[];
    final notices = ref.watch(noticesStreamProvider).valueOrNull ?? const <NoticeModel>[];
    final savedIds = ref.watch(savedEventIdsProvider).valueOrNull ?? const <String>{};

    final myEvents = events.where((e) => e.autorUid == user.uid).toList()..sort((a, b) => b.fecha.compareTo(a.fecha));
    final myNotices = notices.where((n) => n.autorUid == user.uid).toList();
    final savedEvents = events.where((e) => savedIds.contains(e.id)).toList()..sort((a, b) => a.fecha.compareTo(b.fecha));
    final myUpcoming = myEvents.where((e) => !e.isPast()).length;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Encabezado
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 172,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.navy, AppColors.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
            ),
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Semantics(
                    label: 'Foto de perfil de ${user.nombre}',
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: Motion.reduced(context) ? 1 : 0.85, end: 1),
                      duration: Motion.slow,
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                      child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.navy,
                      backgroundImage: fotoBytes != null ? MemoryImage(fotoBytes) : null,
                      child: fotoBytes == null
                          ? Text(_initials(user.nombre), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 58),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(user.nombre, textAlign: TextAlign.center, style: text.headlineSmall?.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Text(user.correo, textAlign: TextAlign.center, style: text.bodySmall),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: (esAdmin ? AppColors.orange : AppColors.blue).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(esAdmin ? Icons.shield_outlined : Icons.school_outlined, size: 14, color: esAdmin ? AppColors.orange : AppColors.blue),
                    const SizedBox(width: 6),
                    Text(
                      esAdmin ? 'Administrador' : 'Estudiante',
                      style: TextStyle(color: esAdmin ? AppColors.orange : AppColors.blue, fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(user.bio!, textAlign: TextAlign.center, style: text.bodyMedium),
              ],
              if (user.carrera != null && user.carrera!.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(Icons.school_outlined, color: colors.primary),
                    title: Text('Carrera', style: text.labelMedium),
                    subtitle: Text(user.carrera!, style: text.titleSmall),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              // Estadísticas reales
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.outline),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(child: _StatTile(value: myEvents.length + myNotices.length, label: 'Publicaciones')),
                      VerticalDivider(width: 1, color: colors.outline),
                      Expanded(child: _StatTile(value: myUpcoming, label: 'Próximos creados')),
                      VerticalDivider(width: 1, color: colors.outline),
                      Expanded(child: _StatTile(value: savedEvents.length, label: 'Guardados')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<_ProfileTab>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: _ProfileTab.events, label: Text('Mis eventos')),
                    ButtonSegment(value: _ProfileTab.notices, label: Text('Mis avisos')),
                    ButtonSegment(value: _ProfileTab.saved, label: Text('Guardados')),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) => setState(() => _tab = s.first),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: Motion.base,
          switchInCurve: Motion.curve,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: Column(
            key: ValueKey(_tab),
            children: _tabContent(context, myEvents, myNotices, savedEvents),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cuenta', style: text.titleMedium),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Editar perfil'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditProfileScreen(user: user))),
                    ),
                    if (esAdmin) ...[
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings_outlined),
                        title: const Text('Administrar usuarios'),
                        subtitle: const Text('Activa, desactiva y asigna roles'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                      ),
                      const Divider(height: 1),
                    ],
                    if (_usesPassword()) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_reset_rounded),
                        title: const Text('Cambiar contraseña'),
                        subtitle: const Text('Te enviaremos un correo seguro para restablecerla'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _confirmPasswordReset(context, user.correo),
                      ),
                    ],
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.logout, color: colors.error),
                      title: Text(AppStrings.logout, style: TextStyle(color: colors.error)),
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text(AppStrings.universityName, textAlign: TextAlign.center, style: text.labelSmall),
                    const SizedBox(height: 2),
                    Text(AppStrings.universityLocation, textAlign: TextAlign.center, style: text.labelSmall),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _tabContent(BuildContext context, List<EventModel> myEvents, List<NoticeModel> myNotices, List<EventModel> saved) {
    switch (_tab) {
      case _ProfileTab.events:
        if (myEvents.isEmpty) {
          return const [EmptyState(message: 'Aún no has publicado eventos.', icon: Icons.event_outlined)];
        }
        return [for (final e in myEvents) EventCard(key: ValueKey('mine-${e.id}'), event: e, onTap: () => context.push('/home/event/${e.id}'))];
      case _ProfileTab.notices:
        if (myNotices.isEmpty) {
          return const [EmptyState(message: 'Aún no has publicado avisos.', icon: Icons.campaign_outlined)];
        }
        return [for (final n in myNotices) NoticeCard(key: ValueKey('mine-${n.id}'), notice: n, onTap: () => context.push('/home/notice/${n.id}'))];
      case _ProfileTab.saved:
        if (saved.isEmpty) {
          return const [EmptyState(message: 'No tienes eventos guardados. Toca el marcador de un evento para guardarlo.', icon: Icons.bookmark_border_rounded)];
        }
        return [for (final e in saved) EventCard(key: ValueKey('saved-${e.id}'), event: e, onTap: () => context.push('/home/event/${e.id}'))];
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  /// Solo las cuentas con correo y contraseña pueden restablecerla desde aquí.
  bool _usesPassword() {
    final providers = ref.read(firebaseAuthProvider).currentUser?.providerData ?? const [];
    return providers.any((p) => p.providerId == 'password');
  }

  void _confirmPasswordReset(BuildContext context, String email) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Text('Enviaremos un enlace para restablecer tu contraseña a $email.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text(AppStrings.cancel)),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(authRepositoryProvider).sendPasswordReset(email);
                messenger.showSnackBar(const SnackBar(content: Text('Te enviamos el correo. Revisa tu bandeja de entrada.')));
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text(friendlyError(e))));
              }
            },
            child: const Text('Enviar enlace'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas cerrar tu sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            CountUp(value: value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.primary)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
