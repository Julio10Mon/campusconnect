import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
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
  late DateTime _fecha;
  String? _fotoBase64;
  bool _isSaving = false;

  bool get _isEditing => widget.notice != null;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.notice?.titulo ?? '');
    _descripcionCtrl = TextEditingController(text: widget.notice?.descripcion ?? '');
    _fecha = widget.notice?.fecha ?? DateTime.now();
    _fotoBase64 = widget.notice?.fotoBase64;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_fecha));
    if (time == null) return;
    setState(() {
      _fecha = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final auth = ref.read(firebaseAuthProvider);
    final repo = ref.read(academicRepositoryProvider);
    final currentUser = auth.currentUser;

    final notice = NoticeModel(
      id: widget.notice?.id ?? '',
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      fecha: _fecha,
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
    final fechaTexto = DateFormat('d MMM yyyy, HH:mm', 'es_MX').format(_fecha);
    final colors = Theme.of(context).colorScheme;

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
                const SizedBox(height: 16),
                Material(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    leading: Icon(Icons.event_outlined, color: colors.primary),
                    title: const Text('Fecha y hora'),
                    subtitle: Text(fechaTexto),
                    trailing: const Icon(Icons.edit_outlined, size: 18),
                    onTap: _pickDateTime,
                  ),
                ),
                const SizedBox(height: 28),
                AppButton(label: AppStrings.save, isLoading: _isSaving, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
