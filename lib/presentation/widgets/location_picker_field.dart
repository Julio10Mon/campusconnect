import 'package:flutter/material.dart';

import '../../core/constants/campus_locations.dart';

/// Valor devuelto por el selector cuando el usuario elige "Todas" (filtros).
const String kAllLocations = '';

/// Abre el selector de ubicaciones con búsqueda.
///
/// Devuelve el id elegido, [kAllLocations] si se eligió "Todas las ubicaciones"
/// (solo si [allowAll]) o `null` si se cerró sin elegir.
Future<String?> showLocationSheet(
  BuildContext context, {
  String? selectedId,
  bool includeOther = true,
  bool allowAll = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _LocationSheet(selectedId: selectedId, includeOther: includeOther, allowAll: allowAll),
  );
}

class _LocationSheet extends StatefulWidget {
  final String? selectedId;
  final bool includeOther;
  final bool allowAll;
  const _LocationSheet({required this.selectedId, required this.includeOther, required this.allowAll});

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final results = CampusLocations.search(_query, includeOther: widget.includeOther);
    final edificios = results.where((l) => l.tipo == LocationKind.edificio).toList();
    final deportivas = results.where((l) => l.tipo == LocationKind.deportiva).toList();
    final otras = results.where((l) => l.tipo == LocationKind.otra).toList();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Buscar ubicación',
                  hintText: 'Edificio, letra, área o cancha',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Borrar búsqueda',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            Expanded(
              child: results.isEmpty && !widget.allowAll
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No encontramos esa ubicación. Prueba con otra palabra o elige "Otra ubicación".',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        if (widget.allowAll && _query.isEmpty)
                          ListTile(
                            leading: const Icon(Icons.layers_clear_outlined),
                            title: const Text('Todas las ubicaciones'),
                            selected: widget.selectedId == null || widget.selectedId == kAllLocations,
                            onTap: () => Navigator.of(context).pop(kAllLocations),
                          ),
                        if (edificios.isNotEmpty) _header(context, 'Edificios'),
                        for (final loc in edificios) _tile(context, loc, colors),
                        if (deportivas.isNotEmpty) _header(context, 'Instalaciones deportivas'),
                        for (final loc in deportivas) _tile(context, loc, colors),
                        if (otras.isNotEmpty) _header(context, 'Personalizada'),
                        for (final loc in otras) _tile(context, loc, colors),
                        if (results.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text('Sin resultados para "$_query".', textAlign: TextAlign.center),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Text(text.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
    );
  }

  Widget _tile(BuildContext context, CampusLocation loc, ColorScheme colors) {
    final selected = loc.id == widget.selectedId;
    final IconData icon = switch (loc.tipo) {
      LocationKind.deportiva => Icons.sports_soccer_outlined,
      LocationKind.otra => Icons.edit_location_alt_outlined,
      LocationKind.edificio => Icons.apartment_outlined,
    };
    return ListTile(
      selected: selected,
      leading: loc.tipo == LocationKind.edificio
          ? CircleAvatar(
              radius: 18,
              backgroundColor: colors.primary.withValues(alpha: 0.14),
              child: Text(loc.letra ?? '', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w800)),
            )
          : Icon(icon),
      title: Text(loc.tipo == LocationKind.edificio ? 'Edificio ${loc.letra}' : loc.nombre),
      subtitle: loc.tipo == LocationKind.edificio ? Text(loc.nombre) : null,
      trailing: selected ? Icon(Icons.check_rounded, color: colors.primary) : null,
      onTap: () => Navigator.of(context).pop(loc.id),
    );
  }
}

/// Campo de formulario que muestra la ubicación elegida y abre el selector.
class LocationPickerField extends FormField<String> {
  LocationPickerField({
    super.key,
    required String? selectedId,
    required ValueChanged<String> onChanged,
  }) : super(
          initialValue: selectedId,
          validator: (v) => (v == null || v.isEmpty) ? 'Selecciona una ubicación.' : null,
          builder: (state) {
            final context = state.context;
            final colors = Theme.of(context).colorScheme;
            final loc = CampusLocations.byId(selectedId);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  button: true,
                  label: 'Ubicación del evento. ${loc?.etiqueta ?? 'Sin seleccionar'}',
                  child: Material(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final picked = await showLocationSheet(context, selectedId: selectedId);
                        if (picked != null && picked.isNotEmpty) {
                          onChanged(picked);
                          state.didChange(picked);
                        }
                      },
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 56),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: state.hasError ? Border.all(color: colors.error, width: 1.4) : null,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.place_outlined, color: colors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc?.etiqueta ?? 'Selecciona una ubicación',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: loc == null ? colors.onSurfaceVariant : colors.onSurface,
                                    ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: Text(state.errorText!, style: TextStyle(color: colors.error, fontSize: 12.5)),
                  ),
              ],
            );
          },
        );
}
