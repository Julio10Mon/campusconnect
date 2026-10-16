import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/user_model.dart';
import '../../../providers/user_management_providers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

/// Editar usuario (admin)
class UserEditScreen extends ConsumerStatefulWidget {
  final UserModel user;
  final bool isSelf;
  const UserEditScreen({super.key, required this.user, required this.isSelf});

  @override
  ConsumerState<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _carreraCtrl;
  late UserRole _rol;
  late bool _activo;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.user.nombre);
    _carreraCtrl = TextEditingController(text: widget.user.carrera ?? '');
    _rol = widget.user.rol;
    _activo = widget.user.activo;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _carreraCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(userAdminControllerProvider.notifier);
    final uid = widget.user.uid;

    await controller.updateInfo(uid, nombre: _nombreCtrl.text.trim(), carrera: _carreraCtrl.text.trim());
    if (!widget.isSelf) {
      if (_rol != widget.user.rol) await controller.changeRole(uid, _rol);
      if (_activo != widget.user.activo) await controller.setActive(uid, _activo);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(userAdminControllerProvider);
    final isSaving = actionState is AdminActionLoading;
    final colors = Theme.of(context).colorScheme;

    ref.listen<AdminActionState>(userAdminControllerProvider, (previous, next) {
      if (next is AdminActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: colors.error),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Editar usuario')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(widget.user.correo, style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'El correo no se puede editar aquí.',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _nombreCtrl,
                  label: AppStrings.fullName,
                  validator: (v) => (v == null || v.trim().length < 3) ? 'Ingresa un nombre válido.' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(controller: _carreraCtrl, label: 'Carrera (opcional)'),
                const SizedBox(height: 24),
                Text('Rol', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(value: UserRole.estudiante, label: Text('Estudiante'), icon: Icon(Icons.school_outlined)),
                    ButtonSegment(value: UserRole.admin, label: Text('Admin'), icon: Icon(Icons.shield_outlined)),
                  ],
                  selected: {_rol},
                  onSelectionChanged: widget.isSelf ? null : (s) => setState(() => _rol = s.first),
                ),
                if (widget.isSelf) ...[
                  const SizedBox(height: 8),
                  Text(
                    'No puedes cambiar tu propio rol (para evitar quedarte sin acceso de administrador).',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  child: SwitchListTile(
                    title: const Text('Cuenta activa'),
                    subtitle: Text(_activo ? 'Puede iniciar sesión normalmente.' : 'No podrá iniciar sesión.'),
                    value: _activo,
                    onChanged: widget.isSelf ? null : (v) => setState(() => _activo = v),
                  ),
                ),
                const SizedBox(height: 28),
                AppButton(label: AppStrings.save, isLoading: isSaving, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
