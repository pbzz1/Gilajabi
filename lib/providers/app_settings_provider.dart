import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isKoreanMode = true;

  bool get isDarkMode => _isDarkMode;
  bool get isKoreanMode => _isKoreanMode;

  AppSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isKoreanMode = prefs.getBool('isKoreanMode') ?? true;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> toggleKoreanMode(bool value) async {
    _isKoreanMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isKoreanMode', value);
    notifyListeners();
  }
}