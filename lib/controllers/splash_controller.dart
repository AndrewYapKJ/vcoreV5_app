import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/splash_screen_service.dart';

enum SplashState { loading, sessionActive, noSession, error }

final splashControllerProvider = FutureProvider<SplashState>((ref) async {
  final splashService = SplashScreenService();

  try {
    // Check for active session and refetch MDT Functions
    final sessionRefreshed = await splashService.checkSessionAndRefetchMDT();

    if (sessionRefreshed) {
      // Session exists and MDT functions were refreshed
      return SplashState.sessionActive;
    }

    // No session or couldn't refresh
    return SplashState.noSession;
  } catch (e) {
    return SplashState.error;
  }
});
