import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorageService {
  static const _keyThemeMode = "theme_mode";
  static const _keySchemeIndex = "scheme_index";

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.toString());
  }

  Future<void> saveSchemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySchemeIndex, index);
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyThemeMode) ?? ThemeMode.light.toString();

    switch (value) {
      case "ThemeMode.dark":
        return ThemeMode.dark;
      case "ThemeMode.system":
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Future<int> getSchemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySchemeIndex) ?? 0;
  }
}
