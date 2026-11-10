import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'app_theme_mode';
  final _storage = const FlutterSecureStorage();

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final saved = await _storage.read(key: _key);
      if (saved == 'dark') {
        _themeMode = ThemeMode.dark;
        notifyListeners();
      } else if (saved == 'light') {
        _themeMode = ThemeMode.light;
        notifyListeners();
      }
    } catch (_) {
      // Default to light
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      await _storage.write(
        key: _key,
        value: isDark ? 'dark' : 'light',
      );
    } catch (_) {
      // Ignore storage write error
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      await _storage.write(
        key: _key,
        value: mode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {
      // Ignore storage write error
    }
  }
}

