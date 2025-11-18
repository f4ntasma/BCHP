// lib/services/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _prefKey = 'is_dark_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _restore(); // Carga el valor guardado al iniciar la app
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_prefKey);
      if (saved != null) {
        _themeMode = saved ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
    } catch (_) {/* si falla, seguimos en light */}
  }

  Future<void> toggleTheme() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners(); // actualiza la UI

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, isDark); // guarda la elección
    } catch (_) {/* ignore */}
  }
}