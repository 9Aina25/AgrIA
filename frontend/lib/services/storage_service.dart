import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class StorageService extends ChangeNotifier {
  static const String _diagnosisKey = 'diagnosis_history';

  Future<void> saveDiagnosis(Map<String, dynamic> diagnosis) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList(_diagnosisKey) ?? [];
    history.add(jsonEncode(diagnosis));
    await prefs.setStringList(_diagnosisKey, history);
  }

  Future<List<Map<String, dynamic>>> getDiagnosisHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? history = prefs.getStringList(_diagnosisKey);
    if (history == null) return [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}