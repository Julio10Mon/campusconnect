import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/utils/campus_time.dart';
import '../../data/models/event_model.dart';
import 'event_card.dart';

/// Calendario mensual de solo consulta construido con eventos reales.
/// Los días con eventos llevan un punto: azul si hay próximos, gris si todos
/// ya finalizaron.
class EventsMonthCalendar extends StatefulWidget {
  final List<EventModel> events;
  const EventsMonthCalendar({super.key, required this.events});

  @override
  State<EventsMonthCalendar> createState() => _EventsMonthCalendarState();
}

class _EventsMonthCalendarState extends State<EventsMonthCalendar> {
  late DateTime _month; // primer día del mes visible (hora de pared)
  DateTime? _selected;

  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  static const _weekdayNames = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

  @override
  void initState() {
    super.initState();
    final now = CampusTime.nowWall();
    _month = DateTime.utc(now.year, now.month, 1);
    _selected = DateTime.utc(now.year, now.month, now.day);
  }

  Map<DateTime, List<EventModel>> _byDay() {
    final map = <DateTime, List<EventModel>>{};
    for (final e in widget.events) {
      final w = CampusTime.toWall(e.fecha);
      final key = DateTime.utc(w.year, w.month, w.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.fecha.compareTo(b.fecha));
    }
    return map;
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime.utc(_month.year, _month.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final byDay = _byDay();
    final today = CampusTime.nowWall();
    final todayKey = DateTime.utc(today.year, today.month, today.day);

    final daysInMonth = DateTime.utc(_month.year, _month.month + 1, 0).day;
    final leading = _month.weekday - 1; // lunes = 0
    final cells = leading + daysInMonth;
    final rows = (cells / 7).ceil();
    final monthLabel = toBeginningOfSentenceCase(DateFormat('MMMM yyyy', 'es_MX').format(_month));

    final selectedEvents = _selected == null ? <EventModel>[] : (byDay[_selected] ?? <EventModel>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(child: Text(monthLabel, style: text.titleMedium)),
              IconButton(tooltip: 'Mes anterior', icon: const Icon(Icons.chevron_left_rounded), onPressed: () => _shiftMonth(-1)),
              IconButton(tooltip: 'Mes siguiente', icon: const Icon(Icons.chevron_right_rounded), onPressed: () => _shiftMonth(1)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Row(
                children: [
                  for (final d in _weekdays)
                    Expanded(child: Center(child: Text(d, style: text.labelSmall))),
                ],
              ),
              const SizedBox(height: 4),
              for (var r = 0; r < rows; r++)
                Row(
                  children: [
                    for (var c = 0; c < 7; c++)
                      Expanded(child: _cell(context, r * 7 + c - leading + 1, daysInMonth, byDay, todayKey, colors)),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_selected != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              '${_weekdayNames[_selected!.weekday - 1]} ${_selected!.day} de ${DateFormat('MMMM', 'es_MX').format(_selected!)}',
              style: text.titleSmall,
            ),
          ),
        if (selectedEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text('No hay eventos programados para este día.', style: text.bodySmall),
          )
        else
          for (final e in selectedEvents)
            EventCard(key: ValueKey('cal-${e.id}'), event: e, onTap: () => context.push('/home/event/${e.id}')),
      ],
    );
  }

  Widget _cell(BuildContext context, int day, int daysInMonth, Map<DateTime, List<EventModel>> byDay, DateTime todayKey, ColorScheme colors) {
    if (day < 1 || day > daysInMonth) return const SizedBox(height: 48);
    final date = DateTime.utc(_month.year, _month.month, day);
    final events = byDay[date] ?? const <EventModel>[];
    final isToday = date == todayKey;
    final isSelected = _selected == date;
    final hasUpcoming = events.any((e) => !e.isPast());
    final label = '$day de ${DateFormat('MMMM', 'es_MX').format(date)}'
        '${events.isEmpty ? '' : ', ${events.length} ${events.length == 1 ? 'evento' : 'eventos'}'}';

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selected = date),
        child: Container(
          height: 48,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : null,
            borderRadius: BorderRadius.circular(12),
            border: isToday && !isSelected ? Border.all(color: colors.primary, width: 1.5) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? colors.onPrimary : colors.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 6,
                child: events.isEmpty
                    ? null
                    : Container(
                        width: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? colors.onPrimary : (hasUpcoming ? colors.secondary : colors.onSurfaceVariant),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
