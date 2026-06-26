import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class EventStorage {
  static const _key = 'events_v1';

  static Future<Map<String, List<Event>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        (value as List)
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
  }

  static Future<void> save(Map<String, List<Event>> events) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      events.map(
        (key, list) => MapEntry(key, list.map((e) => e.toJson()).toList()),
      ),
    );
    await prefs.setString(_key, encoded);
  }
}
