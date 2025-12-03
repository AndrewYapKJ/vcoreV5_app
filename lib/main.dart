import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/localization_provider.dart';
import 'routes/app_router.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:provider/provider.dart';
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ms'), Locale('zh')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    return MaterialApp.router(
      title: 'Logistics Driver App',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: FlexColorScheme.light(
        scheme: _schemes[themeController.schemeIndex],
      ).toTheme,
      darkTheme: FlexColorScheme.dark(
        scheme: _schemes[themeController.schemeIndex],
      ).toTheme,
      themeMode: themeController.themeMode,
      routerConfig: appRouter,
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
