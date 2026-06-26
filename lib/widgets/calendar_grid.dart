import 'package:flutter/material.dart';
import '../models/event.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final Map<String, List<Event>> events;
  final ValueChanged<DateTime> onDayTap;

  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.events,
    required this.onDayTap,
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // 0=Sun … 6=Sat
    final totalRows = ((startOffset + daysInMonth) / 7).ceil();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: List.generate(totalRows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final dayNum = row * 7 + col - startOffset + 1;

            if (dayNum < 1 || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 52));
            }

            final day =
                DateTime(focusedMonth.year, focusedMonth.month, dayNum);
            final isToday = _isSameDay(day, today);
            final isSelected = _isSameDay(day, selectedDay);
            final dayEvents = events[Event.keyFor(day)] ?? [];

            Color numBg = Colors.transparent;
            Color numFg = colorScheme.onSurface;
            if (isToday) {
              numBg = colorScheme.primary;
              numFg = colorScheme.onPrimary;
            } else if (isSelected) {
              numBg = colorScheme.primaryContainer;
              numFg = colorScheme.onPrimaryContainer;
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => onDayTap(day),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 52,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: numBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: numFg,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (dayEvents.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dayEvents.take(3).map((e) {
                            return Container(
                              width: 5,
                              height: 5,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? colorScheme.onPrimary
                                        .withValues(alpha: 0.8)
                                    : e.color,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        )
                      else
                        const SizedBox(height: 7),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
