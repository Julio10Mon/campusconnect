import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/event_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/photo_picker_field.dart';

/// Formulario evento
class EventFormScreen extends ConsumerStatefulWidget {
  final EventModel? event;
  const EventFormScreen({super.key, this.event});

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _ubicacionCtrl;
  late DateTime _fecha;
  String? _fotoBase64;
  bool _isSaving = false;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.event?.titulo ?? '');
    _descripcionCtrl = TextEditingController(text: widget.event?.descripcion ?? '');
    _ubicacionCtrl = TextEditingController(text: widget.event?.ubicacion ?? '');
    _fecha = widget.event?.fecha ?? DateTime.now();
    _fotoBase64 = widget.event?.fotoBase64;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _ubicacionCtrl.dispose();
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

    final event = EventModel(
      id: widget.event?.id ?? '',
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      ubicacion: _ubicacionCtrl.text.trim(),
      fecha: _fecha,
      autorUid: widget.event?.autorUid ?? auth.currentUser?.uid,
      fotoBase64: _fotoBase64,
    );

    try {
      if (_isEditing) {
        await repo.updateEvent(event);
      } else {
        await repo.createEvent(event);
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
      appBar: AppBar(title: Text(_isEditing ? 'Editar evento' : 'Nuevo evento')),
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
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _ubicacionCtrl,
                  label: 'Ubicación',
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
