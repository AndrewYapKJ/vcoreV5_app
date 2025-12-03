import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  int _schemeIndex = 0;

  ThemeMode get themeMode => _themeMode;
  int get schemeIndex => _schemeIndex;

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void changeScheme(int index) {
    _schemeIndex = index;
    notifyListeners();
  }
}
