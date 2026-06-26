import 'package:flutter/material.dart';
import '../models/event.dart';
import '../widgets/calendar_grid.dart';
import 'event_form_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  final Map<String, List<Event>> _events = {};

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _weekdayNames = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  List<Event> get _selectedDayEvents =>
      List.unmodifiable(_events[Event.keyFor(_selectedDay)] ?? []);

  void _prevMonth() => setState(
        () => _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month - 1),
      );

  void _nextMonth() => setState(
        () => _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + 1),
      );

  void _onDayTap(DateTime day) => setState(() => _selectedDay = day);

  Future<void> _addEvent() async {
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(initialDate: _selectedDay),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => (_events[result.key] ??= []).add(result));
    }
  }

  Future<void> _editEvent(Event event) async {
    final result = await Navigator.push<Event>(
      context,
      MaterialPageRoute(builder: (_) => EventFormScreen(event: event)),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        for (final list in _events.values) {
          list.removeWhere((e) => e.id == event.id);
        }
        _events.removeWhere((_, list) => list.isEmpty);
        (_events[result.key] ??= []).add(result);
        _selectedDay = result.date;
        _focusedMonth = DateTime(result.date.year, result.date.month);
      });
    }
  }

  void _deleteEvent(Event event) => setState(() {
        _events[event.key]?.removeWhere((e) => e.id == event.id);
        _events.removeWhere((_, list) => list.isEmpty);
      });

  String _formattedSelectedDay() {
    final weekday = _weekdayNames[_selectedDay.weekday % 7];
    final month = _monthNames[_selectedDay.month - 1];
    return '$weekday, $month ${_selectedDay.day}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final events = _selectedDayEvents;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevMonth,
                ),
                Text(
                  '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CalendarGrid(
              focusedMonth: _focusedMonth,
              selectedDay: _selectedDay,
              events: _events,
              onDayTap: _onDayTap,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  _formattedSelectedDay(),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (events.isNotEmpty)
                  Text(
                    '${events.length} event${events.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 52,
                          color: colorScheme.onSurface.withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No events',
                          style: TextStyle(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: events.length,
                    itemBuilder: (context, i) => _EventTile(
                      event: events[i],
                      onEdit: () => _editEvent(events[i]),
                      onDelete: () => _deleteEvent(events[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventTile({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    String? timeStr;
    if (event.startTime != null) {
      timeStr = _formatTime(event.startTime!);
      if (event.endTime != null) {
        timeStr += ' – ${_formatTime(event.endTime!)}';
      }
    }

    final hasSubtitle =
        timeStr != null || (event.notes?.isNotEmpty ?? false);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: event.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: hasSubtitle
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (timeStr != null)
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: event.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (event.notes?.isNotEmpty ?? false)
                    Text(
                      event.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
