import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';
import 'package:vcore_v5_app/services/firebase_service.dart';
import 'package:vcore_v5_app/services/remote_config_service.dart';
import 'package:vcore_v5_app/services/env_service.dart';
import 'package:vcore_v5_app/services/offline/offline_storage_service.dart';
import 'package:vcore_v5_app/services/offline/offline_queue_manager.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';
import 'routes/app_router.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'controllers/theme_controller.dart';
import 'themes/app_color_scheme.dart';

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

  // Initialize offline storage service (for caching and offline queue)
  try {
    await OfflineStorageService.initialize();
    debugPrint('✓ Offline storage service initialized');
  } catch (e) {
    debugPrint('✗ Offline storage initialization error: $e');
  }

  runApp(
    ProviderScope(
      // providers: [ChangeNotifierProvider(create: (_) => ConnectivityService())],
      child: ScaleKitBuilder(
        designWidth: 375,
        designHeight: 812,
        designType: DeviceType.mobile,
        child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ms'), Locale('zh')],
          path: 'assets/lang',
          fallbackLocale: const Locale('en'),
          child: MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'main_navigator',
  );

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    print("mavogaerasa das fsfdsg sdf ${MyApp.navigatorKey}");
    _initializeServices();
    super.initState();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize global error service with navigator key
      CustomSnackBar.initialize(MyApp.navigatorKey);

      // Initialize connectivity service
      final connectivityService = ref.read(connectivityServiceProvider);
      await connectivityService.initialize();

      // Process any existing queue if we start online
      if (connectivityService.isOnline) {
        debugPrint('App started online - processing any queued requests');
        await OfflineQueueManager().processQueuedRequests();
      }

      // Listen to connectivity changes and process queue when back online
      connectivityService.addListener(() {
        if (connectivityService.isOnline) {
          CustomSnackBar.showOnlineNotification();
          OfflineQueueManager().processQueuedRequests();
        } else {
          CustomSnackBar.showOfflineNotification();
        }
      });
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final themeAsync = ref.watch(themeControllerProvider);

    return themeAsync.when(
      loading: () => MaterialApp(home: SizedBox()),
      error: (_, _) => MaterialApp(home: Text("Theme error")),
      data: (theme) {
        final scheme = AppColorScheme.getSchemeByIndex(theme.schemeIndex);
        return MaterialApp.router(
          title: 'VCORE Driver App',
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          theme: FlexColorScheme.light(colors: scheme.light).toTheme,
          darkTheme: FlexColorScheme.dark(colors: scheme.dark).toTheme,
          themeMode: theme.themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
