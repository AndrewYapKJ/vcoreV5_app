import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/login_response_model.dart';
import '../services/storage/login_cache_service.dart';
import 'package:flutter/foundation.dart';

// Simple mutable state provider using notifier pattern
class _UserNotifierImpl extends Notifier<LoginResponse?> {
  @override
  LoginResponse? build() {
    // Load user data from cache on initialization
    _loadUserFromCache();
    return null;
  }

  Future<void> _loadUserFromCache() async {
    debugPrint('🔄 UserProvider: Loading user from cache...');
    final cacheService = LoginCacheService();
    await cacheService.initialize();

    if (cacheService.isSessionValid()) {
      debugPrint('✅ UserProvider: Session is valid');
      final cachedUserInfo = cacheService.getCachedUserInfo();
      if (cachedUserInfo != null) {
        debugPrint(
          '📦 UserProvider: Found cached user info with keys: ${cachedUserInfo.keys.toList()}',
        );
        // Reconstruct LoginResponse from cached data
        final loginResponse = LoginResponse.fromJson(cachedUserInfo);
        state = loginResponse;
        debugPrint(
          '✅ UserProvider: User data loaded - Name: ${loginResponse.name}, TenantId: ${loginResponse.tenantId}',
        );
      } else {
        debugPrint('⚠️ UserProvider: Cached user info is null');
      }
    } else {
      debugPrint('⚠️ UserProvider: Session is invalid');
    }
  }
}

/// Simple user data provider
final userDataProvider = NotifierProvider<_UserNotifierImpl, LoginResponse?>(
  _UserNotifierImpl.new,
);

/// Provider to watch user data
final currentUserProvider = Provider<LoginResponse?>((ref) {
  return ref.watch(userDataProvider);
});

/// Provider to get driver ID
final driverIdProvider = Provider<String?>((ref) {
  return ref.watch(userDataProvider)?.driverId;
});

/// Provider to get tenant ID
final tenantIdProvider = Provider<String?>((ref) {
  return ref.watch(userDataProvider)?.tenantId;
});

/// Provider to get user name
final userNameProvider = Provider<String?>((ref) {
  return ref.watch(userDataProvider)?.name;
});

/// Provider to get user mobile
final userMobileProvider = Provider<String?>((ref) {
  return ref.watch(userDataProvider)?.mobile;
});

/// Provider to check if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(userDataProvider);
  return user != null && user.driverId != null;
});
