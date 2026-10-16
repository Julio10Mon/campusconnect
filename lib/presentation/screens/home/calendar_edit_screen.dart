import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/calendar_info_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/photo_picker_field.dart';

/// Editar calendario
class CalendarEditScreen extends ConsumerStatefulWidget {
  final CalendarInfoModel? current;
  const CalendarEditScreen({super.key, this.current});

  @override
  ConsumerState<CalendarEditScreen> createState() => _CalendarEditScreenState();
}

class _CalendarEditScreenState extends ConsumerState<CalendarEditScreen> {
  late final TextEditingController _textoCtrl;
  String? _imagenBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textoCtrl = TextEditingController(text: widget.current?.texto ?? '');
    _imagenBase64 = widget.current?.imagenBase64;
  }

  @override
  void dispose() {
    _textoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final info = CalendarInfoModel(imagenBase64: _imagenBase64, texto: _textoCtrl.text.trim());
    try {
      await ref.read(academicRepositoryProvider).setCalendarInfo(info);
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
      appBar: AppBar(title: const Text('Editar calendario')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PhotoPickerField(
                base64Image: _imagenBase64,
                onChanged: (v) => setState(() => _imagenBase64 = v),
                height: 220,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _textoCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Texto descriptivo (notas, aclaraciones, etc.)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(label: AppStrings.save, isLoading: _isSaving, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
