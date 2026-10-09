import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/user_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/photo_picker_field.dart';

/// Editar perfil
class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _carreraCtrl;
  late final TextEditingController _bioCtrl;
  String? _fotoBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.user.nombre);
    _carreraCtrl = TextEditingController(text: widget.user.carrera ?? '');
    _bioCtrl = TextEditingController(text: widget.user.bio ?? '');
    _fotoBase64 = widget.user.fotoBase64;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _carreraCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Sin copyWith
    final updated = UserModel(
      uid: widget.user.uid,
      nombre: _nombreCtrl.text.trim(),
      correo: widget.user.correo,
      rol: widget.user.rol,
      carrera: _carreraCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      fotoBase64: _fotoBase64,
      creadoEn: widget.user.creadoEn,
    );

    try {
      await ref.read(authRepositoryProvider).updateProfile(updated);
      ref.invalidate(currentUserProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: PhotoPickerField(
                      base64Image: _fotoBase64,
                      onChanged: (v) => setState(() => _fotoBase64 = v),
                      height: 140,
                      borderRadius: BorderRadius.circular(70),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _nombreCtrl,
                  label: AppStrings.fullName,
                  validator: (v) => (v == null || v.trim().length < 3) ? 'Ingresa tu nombre completo.' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(controller: _carreraCtrl, label: 'Carrera (opcional)'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  maxLength: 160,
                  decoration: const InputDecoration(
                    labelText: 'Sobre ti (opcional)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(label: AppStrings.save, isLoading: _isSaving, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
