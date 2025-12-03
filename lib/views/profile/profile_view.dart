import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../controllers/theme_controller.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static final List<FlexScheme> _schemes = [
    FlexScheme.material,
    FlexScheme.hippieBlue,
    FlexScheme.mandyRed,
    FlexScheme.money,
    FlexScheme.espresso,
    FlexScheme.outerSpace,
  ];

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    return Scaffold(
      appBar: AppBar(title: Text('user_profile'.tr())),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('user_profile'.tr(), style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 24),
            FloatingActionButton.extended(
              heroTag: 'theme',
              onPressed: themeController.toggleThemeMode,
              icon: Icon(
                themeController.themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              label: Text(
                themeController.themeMode == ThemeMode.light
                    ? 'Dark Mode'
                    : 'Light Mode',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: themeController.schemeIndex,
              items: List.generate(_schemes.length, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text(_schemes[i].name),
                );
              }),
              onChanged: (int? i) {
                if (i != null) themeController.changeScheme(i);
              },
            ),
          ],
        ),
      ),
    );
  }
}
