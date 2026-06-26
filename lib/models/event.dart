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
}
