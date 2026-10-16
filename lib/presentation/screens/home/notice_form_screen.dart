import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../data/models/notice_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/photo_picker_field.dart';

/// Formulario aviso
class NoticeFormScreen extends ConsumerStatefulWidget {
  final NoticeModel? notice;
  const NoticeFormScreen({super.key, this.notice});

  @override
  ConsumerState<NoticeFormScreen> createState() => _NoticeFormScreenState();
}

class _NoticeFormScreenState extends ConsumerState<NoticeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  String? _fotoBase64;
  bool _isSaving = false;

  bool get _isEditing => widget.notice != null;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.notice?.titulo ?? '');
    _descripcionCtrl = TextEditingController(text: widget.notice?.descripcion ?? '');
    _fotoBase64 = widget.notice?.fotoBase64;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Evita envíos dobles: se marca antes de cualquier operación asíncrona.
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final auth = ref.read(firebaseAuthProvider);
    final repo = ref.read(academicRepositoryProvider);
    final currentUser = auth.currentUser;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final notice = NoticeModel(
      id: widget.notice?.id ?? '',
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      // La fecha es automática: se conserva la original al editar.
      fecha: widget.notice?.fecha ?? DateTime.now(),
      autor: widget.notice?.autor ?? currentUser?.displayName ?? currentUser?.email,
      autorUid: widget.notice?.autorUid ?? currentUser?.uid,
      fotoBase64: _fotoBase64,
    );

    try {
      if (_isEditing) {
        await repo.updateNotice(notice);
      } else {
        await repo.createNotice(notice);
      }
      messenger.showSnackBar(SnackBar(content: Text(_isEditing ? 'Aviso actualizado.' : 'Aviso publicado.')));
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyError(e)), backgroundColor: Theme.of(context).colorScheme.error),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar aviso' : 'Nuevo aviso')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PhotoPickerField(base64Image: _fotoBase64, onChanged: (v) => setState(() => _fotoBase64 = v)),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _tituloCtrl,
                  label: 'Título',
                  validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
                ),
                const SizedBox(height: 28),
                AppButton(label: _isEditing ? 'Guardar cambios' : 'Publicar aviso', isLoading: _isSaving, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
