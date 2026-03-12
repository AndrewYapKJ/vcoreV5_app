import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage/login_cache_service.dart';
import '../providers/jobs_provider.dart';

enum SplashState { loading, sessionActive, noSession, error }

final splashControllerProvider = FutureProvider<SplashState>((ref) async {
  final loginCacheService = LoginCacheService();
  await loginCacheService.initialize();

  try {
    // Check for active session
    final hasSession = loginCacheService.isCachedSessionValid();

    if (!hasSession) {
      // No session or session expired
      return SplashState.noSession;
    }

    // Get tenant ID from cache
    final tenantId = loginCacheService.getCachedTenantId();
    if (tenantId == null) {
      return SplashState.noSession;
    }
    print("object");
    // Invalidate and refetch MDT Functions using the provider
    // This ensures the data is fresh and cached in Riverpod state
    // ref.read(mdtFunctionsProvider);
    final mdtResponse = await ref.watch(mdtFunctionsProvider.future);
    print("object");
    if (mdtResponse.isSuccess && mdtResponse.functions.isNotEmpty) {
      // Session exists and MDT functions were refreshed
      return SplashState.sessionActive;
    }

    // API call failed or returned no data
    return SplashState.noSession;
  } catch (e) {
    return SplashState.error;
  }
});
