import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'core/localization_provider.dart';
import 'routes/app_router.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    ProviderScope(
      child: ScaleKitBuilder(
        designWidth: 375,
        designHeight: 812,
        designType: DeviceType.mobile,
        child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ms'), Locale('zh')],
          path: 'assets/lang',
          fallbackLocale: const Locale('en'),
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static final List<FlexScheme> _schemes = FlexScheme.values;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeControllerProvider);

    return themeAsync.when(
      loading: () => MaterialApp(home: SizedBox()),
      error: (_, __) => MaterialApp(home: Text("Theme error")),
      data: (theme) => MaterialApp.router(
        title: 'Logistics Driver App',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: FlexColorScheme.light(
          scheme: _schemes[theme.schemeIndex],
        ).toTheme,
        darkTheme: FlexColorScheme.dark(
          scheme: _schemes[theme.schemeIndex],
        ).toTheme,
        themeMode: theme.themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}
