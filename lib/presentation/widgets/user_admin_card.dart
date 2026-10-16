import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/user_model.dart';

class UserAdminCard extends StatelessWidget {
  final UserModel user;
  final bool isSelf;
  final VoidCallback onTap;
  final ValueChanged<bool>? onToggleActive;

  const UserAdminCard({
    super.key,
    required this.user,
    required this.isSelf,
    required this.onTap,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fotoBytes = user.fotoBase64 != null ? base64Decode(user.fotoBase64!) : null;
    final fecha = user.creadoEn != null ? DateFormat('d MMM yyyy', 'es_MX').format(user.creadoEn!) : '—';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colors.primary.withValues(alpha: 0.15),
                backgroundImage: fotoBytes != null ? MemoryImage(fotoBytes) : null,
                child: fotoBytes == null
                    ? Text(
                        user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                        style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.nombre.isNotEmpty ? user.nombre : '(Sin nombre)',
                            style: text.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelf)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _Badge(label: 'Tú', color: colors.primary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(user.correo, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Badge(
                          label: user.rol == UserRole.admin ? 'Administrador' : 'Estudiante',
                          color: user.rol == UserRole.admin ? colors.secondary : colors.primary,
                        ),
                        _Badge(
                          label: user.activo ? 'Activa' : 'Desactivada',
                          color: user.activo ? Colors.green : colors.error,
                        ),
                        _Badge(label: 'Desde $fecha', color: colors.onSurfaceVariant, subtle: true),
                      ],
                    ),
                  ],
                ),
              ),
              if (onToggleActive != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Switch(
                    value: user.activo,
                    onChanged: isSelf ? null : onToggleActive,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool subtle;
  const _Badge({required this.label, required this.color, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: subtle ? color.withValues(alpha: 0.08) : color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
