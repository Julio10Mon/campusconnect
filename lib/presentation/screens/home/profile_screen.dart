import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/logo_app.dart';
import '../../widgets/state_placeholders.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(10),
          child: LogoApp(size: 32),
        ),
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
        data: (user) {
          final fotoBytes = user.fotoBase64 != null ? base64Decode(user.fotoBase64!) : null;
          final esAdmin = user.rol == UserRole.admin;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
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
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.navy,
                          backgroundImage: fotoBytes != null ? MemoryImage(fotoBytes) : null,
                          child: fotoBytes == null
                              ? Text(
                                  user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 58),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(user.nombre, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(user.correo, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
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
                      const SizedBox(height: 16),
                      Text(user.bio!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    if (user.carrera != null && user.carrera!.trim().isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: Icon(Icons.school_outlined, color: colors.primary),
                          title: Text('Carrera', style: Theme.of(context).textTheme.labelMedium),
                          subtitle: Text(user.carrera!, style: Theme.of(context).textTheme.titleSmall),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context, ref),
                      icon: Icon(Icons.logout, color: colors.error),
                      label: Text(AppStrings.logout, style: TextStyle(color: colors.error)),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: colors.error.withValues(alpha: 0.4))),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.apartment_outlined, size: 14, color: colors.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Flexible(child: Text(AppStrings.universityName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(AppStrings.universityLocation, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
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
