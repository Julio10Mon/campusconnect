import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/campus_locations.dart';
import '../../../core/utils/text_utils.dart';
import '../../../data/models/event_model.dart';
import '../../providers/academic_providers.dart';
import '../../widgets/motion.dart';
import '../../widgets/event_card.dart';
import '../../widgets/location_picker_field.dart';
import '../../widgets/logo_app.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/state_placeholders.dart';
import 'event_form_screen.dart';

enum _EventFilter { upcoming, past, all }

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _EventFilter _filter = _EventFilter.upcoming;

  /// Id de ubicación del catálogo usado como filtro (null = todas).
  String? _locationFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<EventModel> _apply(List<EventModel> events) {
    final now = DateTime.now();
    final q = TextUtils.normalize(_query);
    final filtered = events.where((e) {
      final past = e.isPast(now);
      if (_filter == _EventFilter.upcoming && past) return false;
      if (_filter == _EventFilter.past && !past) return false;
      if (_locationFilter != null) {
        final loc = CampusLocations.resolve(id: e.ubicacionId, text: e.ubicacion);
        if (loc?.id != _locationFilter) return false;
      }
      if (q.isNotEmpty) {
        final hay = TextUtils.normalize('${e.titulo} ${e.descripcion} ${e.ubicacion}');
        if (!q.split(' ').every(hay.contains)) return false;
      }
      return true;
    }).toList();

    // Próximos: el más cercano primero. Finalizados/todos: el más reciente primero.
    filtered.sort((a, b) => _filter == _EventFilter.upcoming ? a.fecha.compareTo(b.fecha) : b.fecha.compareTo(a.fecha));
    return filtered;
  }

  bool get _hasActiveFilters => _query.trim().isNotEmpty || _locationFilter != null || _filter != _EventFilter.upcoming;

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _query = '';
      _locationFilter = null;
      _filter = _EventFilter.upcoming;
    });
  }

  Future<void> _pickLocationFilter() async {
    final picked = await showLocationSheet(context, selectedId: _locationFilter, includeOther: false, allowAll: true);
    if (picked == null) return;
    setState(() => _locationFilter = picked.isEmpty ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsStreamProvider);
    final colors = Theme.of(context).colorScheme;
    final locName = CampusLocations.byId(_locationFilter);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(8), child: LogoApp(size: 32)),
        title: const ScreenHeaderTitle(title: AppStrings.navEvents),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EventFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo evento'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por título, descripción o ubicación',
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
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                for (final entry in const {
                  _EventFilter.upcoming: 'Próximos',
                  _EventFilter.past: 'Finalizados',
                  _EventFilter.all: 'Todos',
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: _filter == entry.key,
                      onSelected: (_) => setState(() => _filter = entry.key),
                    ),
                  ),
                ActionChip(
                  avatar: Icon(Icons.place_outlined, size: 18, color: colors.primary),
                  label: Text(locName == null ? 'Ubicación' : (locName.letra != null ? 'Edificio ${locName.letra}' : locName.nombre)),
                  onPressed: _pickLocationFilter,
                ),
                if (_hasActiveFilters)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.filter_alt_off_outlined, size: 18),
                      label: const Text('Limpiar'),
                      onPressed: _clearFilters,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(eventsStreamProvider),
              child: eventsAsync.when(
                loading: () => const LoadingState(),
                error: (error, _) => ErrorStateView(error: error, onRetry: () => ref.invalidate(eventsStreamProvider)),
                data: (events) {
                  final visible = _apply(events);
                  if (visible.isEmpty) {
                    final noEventsAtAll = events.isEmpty;
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: EmptyState(
                        message: noEventsAtAll
                            ? AppStrings.emptyEvents
                            : 'No hay eventos que coincidan con tu búsqueda o filtros.',
                        icon: noEventsAtAll ? Icons.event_outlined : Icons.search_off_rounded,
                        action: (!noEventsAtAll && _hasActiveFilters)
                            ? OutlinedButton(onPressed: _clearFilters, child: const Text('Limpiar filtros'))
                            : null,
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 4, bottom: 96),
                    itemCount: visible.length,
                    itemBuilder: (context, i) => FadeSlideIn(
                      key: ValueKey(visible[i].id),
                      delay: Motion.stagger(i),
                      child: EventCard(
                        event: visible[i],
                        onTap: () => context.push('/home/event/${visible[i].id}'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
