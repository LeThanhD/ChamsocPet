import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToHistory(Map<String, dynamic> item) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> current = prefs.getStringList('history_appointments') ?? [];
  current.add(jsonEncode(item));
  await prefs.setStringList('history_appointments', current);
}
