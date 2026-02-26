import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vcore_v5_app/services/firebase_service.dart';
import 'package:vcore_v5_app/services/remote_config_service.dart';
import 'package:vcore_v5_app/services/env_service.dart';
import 'routes/app_router.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file or system environment
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✓ Loaded environment variables from .env file');
  } catch (e) {
    debugPrint('⚠ Could not load .env file: $e');
    debugPrint('  Using system environment variables instead');
  }

  // Validate required environment variables
  try {
    final missingVars = EnvService.validateEnvironment();
    if (missingVars.isNotEmpty) {
      debugPrint(
        '⚠ WARNING: Missing environment variables: ${missingVars.join(", ")}\n'
        '  Please add them to your .env file or set them as system environment variables.',
      );
    } else {
      debugPrint('✓ All environment variables loaded successfully');
    }
  } catch (e) {
    debugPrint('⚠ Warning: Environment validation error: $e');
  }

  await EasyLocalization.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✓ Firebase initialized successfully');
  } catch (e) {
    debugPrint('✗ Firebase initialization error: $e');
  }

  // Initialize remote config with fallback to Huawei
  await RemoteConfigService().initialize();

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
      error: (_, _) => MaterialApp(home: Text("Theme error")),
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
