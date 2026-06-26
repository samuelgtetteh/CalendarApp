import 'package:flutter/material.dart';

class Event {
  final String id;
  String title;
  DateTime date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? notes;
  Color color;

  Event({
    required this.id,
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    this.notes,
    this.color = const Color(0xFF2196F3),
  });

  static String keyFor(DateTime date) =>
      '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String get key => Event.keyFor(date);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'startTime': startTime != null
            ? '${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}'
            : null,
        'endTime': endTime != null
            ? '${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}'
            : null,
        'notes': notes,
        'color': color.toARGB32(),
      };

  factory Event.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? s) {
      if (s == null) return null;
      final parts = s.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: parseTime(json['startTime'] as String?),
      endTime: parseTime(json['endTime'] as String?),
      notes: json['notes'] as String?,
      color: Color(json['color'] as int),
    );
  }
}
