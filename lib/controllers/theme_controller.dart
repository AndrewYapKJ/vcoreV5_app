import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/theme_storage_service.dart';

part 'theme_controller.g.dart';

@riverpod
class ThemeController extends _$ThemeController {
  final _storage = ThemeStorageService();

  @override
  Future<ThemeState> build() async {
    // Load from SharedPrefs
    final mode = await _storage.getThemeMode();
    final scheme = await _storage.getSchemeIndex();
    return ThemeState(themeMode: mode, schemeIndex: scheme);
  }

  Future<void> toggleThemeMode() async {
    final newMode = switch (state.value!.themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      _ => ThemeMode.light,
    };

    state = AsyncData(state.value!.copyWith(themeMode: newMode));

    await _storage.saveThemeMode(newMode);
  }

  Future<void> changeScheme(int index) async {
    state = AsyncData(state.value!.copyWith(schemeIndex: index));

    await _storage.saveSchemeIndex(index);
  }
}

class ThemeState {
  final ThemeMode themeMode;
  final int schemeIndex;

  ThemeState({required this.themeMode, required this.schemeIndex});

  ThemeState copyWith({ThemeMode? themeMode, int? schemeIndex}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      schemeIndex: schemeIndex ?? this.schemeIndex,
    );
  }
}
