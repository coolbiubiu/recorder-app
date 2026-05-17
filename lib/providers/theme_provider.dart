import 'package:flutter/material.dart';
import '../data/repositories/settings_repository.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider({required SettingsRepository repository})
      : _repository = repository;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void loadTheme() {
    final settings = _repository.getAppSettings();
    _themeMode = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _repository.updateDarkMode(mode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}