import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/campus_locations.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/utils/campus_time.dart';
import '../../../data/models/event_model.dart';
import '../../../domain/validators/event_schedule_validator.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/location_picker_field.dart';
import '../../widgets/photo_picker_field.dart';

/// Formulario para publicar o editar un evento.
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
  late final TextEditingController _otraCtrl;

  /// Fecha/hora en "hora de pared" del campus (DateTime UTC con campos locales).
  late DateTime _wall;
  String? _ubicacionId;
  String? _fotoBase64;
  bool _isSaving = false;
  Timer? _clock;

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _tituloCtrl = TextEditingController(text: e?.titulo ?? '');
    _descripcionCtrl = TextEditingController(text: e?.descripcion ?? '');
    _fotoBase64 = e?.fotoBase64;

    if (e != null) {
      _wall = CampusTime.toWall(e.fecha);
      final match = CampusLocations.resolve(id: e.ubicacionId, text: e.ubicacion);
      if (match != null) {
        _ubicacionId = match.id;
        _otraCtrl = TextEditingController(text: match.id == CampusLocations.otherId ? e.ubicacion : '');
      } else {
        // Ubicación escrita antes del catálogo: se conserva como personalizada.
        _ubicacionId = e.ubicacion.trim().isEmpty ? null : CampusLocations.otherId;
        _otraCtrl = TextEditingController(text: e.ubicacion);
      }
    } else {
      // Por defecto: la próxima hora en punto del campus.
      final now = CampusTime.nowWall();
      _wall = DateTime.utc(now.year, now.month, now.day, now.hour).add(const Duration(hours: 1));
      _otraCtrl = TextEditingController();
    }

    // Si el formulario queda abierto mucho tiempo, se revalida cada 30 s.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _otraCtrl.dispose();
    super.dispose();
  }

  DateTime get _instant => CampusTime.wallToInstant(_wall);

  String? get _scheduleError => EventScheduleValidator.validate(_instant, originalFecha: widget.event?.fecha);

  Future<void> _pickDate() async {
    final today = CampusTime.nowWall();
    final todayDate = DateTime(today.year, today.month, today.day);
    final current = DateTime(_wall.year, _wall.month, _wall.day);
    // Al editar un evento pasado, el selector debe poder mostrar su fecha actual.
    final first = current.isBefore(todayDate) ? current : todayDate;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: first,
      lastDate: todayDate.add(const Duration(days: 365 * 2)),
      helpText: 'Fecha del evento',
    );
    if (date == null || !mounted) return;
    setState(() => _wall = DateTime.utc(date.year, date.month, date.day, _wall.hour, _wall.minute));
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _wall.hour, minute: _wall.minute),
      helpText: 'Hora del evento',
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;
    setState(() => _wall = DateTime.utc(_wall.year, _wall.month, _wall.day, time.hour, time.minute));
  }

  String get _ubicacionTexto {
    if (_ubicacionId == CampusLocations.otherId) return _otraCtrl.text.trim();
    return CampusLocations.byId(_ubicacionId)?.etiqueta ?? '';
  }

  Future<void> _save() async {
    // Evita envíos dobles: se marca antes de cualquier operación asíncrona.
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_scheduleError != null) {
      setState(() {}); // muestra el error de fecha
      return;
    }
    setState(() => _isSaving = true);

    final auth = ref.read(firebaseAuthProvider);
    final repo = ref.read(academicRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final event = EventModel(
      id: widget.event?.id ?? '',
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      ubicacion: _ubicacionTexto,
      ubicacionId: _ubicacionId,
      fecha: _instant,
      autorUid: widget.event?.autorUid ?? auth.currentUser?.uid,
      fotoBase64: _fotoBase64,
    );

    try {
      if (_isEditing) {
        await repo.updateEvent(event);
      } else {
        await repo.createEvent(event);
      }
      messenger.showSnackBar(SnackBar(content: Text(_isEditing ? 'Evento actualizado.' : 'Evento publicado.')));
      navigator.pop();
    } catch (e) {
      // Se conservan los datos escritos para que el usuario corrija y reintente.
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(friendlyError(e)), backgroundColor: Theme.of(context).colorScheme.error),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fechaTexto = DateFormat("EEEE d 'de' MMMM yyyy", 'es_MX').format(_wall);
    final horaTexto = DateFormat('HH:mm', 'es_MX').format(_wall);
    final scheduleError = _scheduleError;

    Widget section(String title) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 10),
          child: Text(title, style: textTheme.titleSmall),
        );

    Widget dateTile({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
      return Material(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: scheduleError != null ? Border.all(color: colors.error, width: 1.4) : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: textTheme.labelSmall),
                      Text(value, style: textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar evento' : 'Nuevo evento')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                section('1. Información del evento'),
                AppTextField(
                  controller: _tituloCtrl,
                  label: 'Título',
                  validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
                ),
                section('2. Descripción'),
                TextFormField(
                  controller: _descripcionCtrl,
                  maxLines: 4,
                  maxLength: 600,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Descripción', alignLabelWithHint: true),
                  validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
                ),
                section('3. Imagen (opcional)'),
                PhotoPickerField(base64Image: _fotoBase64, onChanged: (v) => setState(() => _fotoBase64 = v)),
                section('4. Fecha y hora'),
                LayoutBuilder(
                  builder: (context, c) {
                    final dateW = dateTile(icon: Icons.event_outlined, label: 'Fecha', value: fechaTexto, onTap: _pickDate);
                    final timeW = dateTile(icon: Icons.schedule_rounded, label: 'Hora', value: horaTexto, onTap: _pickTime);
                    if (c.maxWidth < 420) {
                      return Column(children: [dateW, const SizedBox(height: 10), timeW]);
                    }
                    return Row(children: [Expanded(flex: 3, child: dateW), const SizedBox(width: 10), Expanded(flex: 2, child: timeW)]);
                  },
                ),
                if (scheduleError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 16, color: colors.error),
                        const SizedBox(width: 6),
                        Expanded(child: Text(scheduleError, style: TextStyle(color: colors.error, fontSize: 12.5))),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                    child: Text('Hora del campus (Ciudad de México).', style: textTheme.bodySmall),
                  ),
                section('5. Ubicación'),
                LocationPickerField(
                  selectedId: _ubicacionId,
                  onChanged: (id) => setState(() => _ubicacionId = id),
                ),
                if (_ubicacionId == CampusLocations.otherId) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _otraCtrl,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Escribe la ubicación del evento'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe la ubicación del evento.' : null,
                  ),
                ],
                section('6. Confirmación'),
                AppButton(
                  label: _isEditing ? 'Guardar cambios' : 'Publicar evento',
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
