import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/theme_controller.dart';

class ThemeModeToggle extends ConsumerWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);
    return themeAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (theme) {
        final isDark = theme.themeMode == ThemeMode.dark;
        return IconButton(
          icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          onPressed: controller.toggleThemeMode,
        );
      },
    );
  }
}
