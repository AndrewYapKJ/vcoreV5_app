import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../controllers/theme_controller.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  static final List<FlexScheme> _schemes = FlexScheme.values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeControllerProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    return themeAsync.when(
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => Scaffold(body: Text("Error loading theme")),
      data: (theme) => Scaffold(
        appBar: AppBar(title: Text('user_profile'.tr())),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('user_profile'.tr(), style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 24),
              FloatingActionButton.extended(
                heroTag: 'theme',
                onPressed: controller.toggleThemeMode,
                icon: Icon(
                  theme.themeMode == ThemeMode.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                label: Text(
                  theme.themeMode == ThemeMode.light
                      ? 'Dark Mode'
                      : 'Light Mode',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: theme.schemeIndex,
                items: List.generate(_schemes.length, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text(_schemes[i].name),
                  );
                }),
                onChanged: (i) {
                  if (kDebugMode) {
                    print(FlexScheme.values.length);
                  }
                  if (i != null) controller.changeScheme(i);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
