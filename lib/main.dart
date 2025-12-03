import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/localization_provider.dart';
import 'routes/app_router.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ms'), Locale('zh')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  int _schemeIndex = 0;

  final List<FlexScheme> _schemes =const [
    FlexScheme.material,
    FlexScheme.hippieBlue,
    FlexScheme.mandyRed,
    FlexScheme.money,
    FlexScheme.espresso,
    FlexScheme.outerSpace,
  ];

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  void _changeScheme(int index) {
    setState(() {
      _schemeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Logistics Driver App',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: FlexColorScheme.light(scheme: _schemes[_schemeIndex]).toTheme,
      darkTheme: FlexColorScheme.dark(scheme: _schemes[_schemeIndex]).toTheme,
      themeMode: _themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'theme',
                    onPressed: _toggleThemeMode,
                    child: Icon(_themeMode == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<int>(
                    value: _schemeIndex,
                    items: List.generate(_schemes.length, (i) {
                      return DropdownMenuItem(
                        value: i,
                        child: Text(_schemes[i].name),
                      );
                    }),
                    onChanged: (int? i) { if (i != null) _changeScheme(i); },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('app_title'.tr(), style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
