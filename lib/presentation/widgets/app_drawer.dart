import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/user_model.dart';
import '../providers/auth_provider.dart';
import 'app_nav_bar.dart';

/// Menú lateral desplegable. Usa las mismas secciones de la barra inferior;
/// no agrega navegación nueva.
class AppDrawer extends ConsumerWidget {
  final int selectedIndex;
  final List<AppNavItem> items;
  final ValueChanged<int> onSelected;

  const AppDrawer({super.key, required this.selectedIndex, required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).valueOrNull;
    final fotoBytes = user?.fotoBase64 != null ? base64Decode(user!.fotoBase64!) : null;
    final nombre = user?.nombre ?? AppStrings.appName;
    final rol = user == null ? '' : (user.rol == UserRole.admin ? 'Administrador' : 'Estudiante');

    return Drawer(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(28))),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.navy,
                    backgroundImage: fotoBytes != null ? MemoryImage(fotoBytes) : null,
                    child: fotoBytes == null
                        ? Text(_initials(nombre), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (rol.isNotEmpty) Text(rol, style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: ListTile(
                  selected: i == selectedIndex,
                  selectedTileColor: colors.primary.withValues(alpha: 0.12),
                  selectedColor: colors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Icon(i == selectedIndex ? items[i].selectedIcon : items[i].icon),
                  title: Text(items[i].label),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelected(i);
                  },
                ),
              ),
            const Spacer(),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: Icon(Icons.logout_rounded, color: colors.error),
                title: Text(AppStrings.logout, style: TextStyle(color: colors.error)),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmLogout(context, ref);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
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
