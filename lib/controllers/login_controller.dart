import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/storage/login_cache_service.dart';
import '../services/offline/offline_storage_service.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../services/api/jobs_api.dart';
import '../providers/trailer_search_provider.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  final _authService = AuthService();
  final _storage = LocalStorageService();
  final _jobsApi = JobsApi();
  late final LoginCacheService _loginCacheService;

  @override
  LoginState build() {
    _loginCacheService = LoginCacheService();

    // Load remembered credentials synchronously during initialization
    try {
      if (_loginCacheService.isRememberMeEnabled()) {
        final username = _loginCacheService.getRememberedUsername();
        final password = _loginCacheService.getRememberedPassword();

        if (username != null && password != null) {
          debugPrint('Remembered credentials loaded for: $username');
          return LoginState.initial().copyWith(
            userId: username,
            password: password,
            rememberMe: true,
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading remembered credentials: $e');
    }

    return LoginState.initial();
  }

  Future<void> login() async {
    // Validate before making API call
    if (!state.isValid) {
      if (state.userId.isEmpty) {
        state = state.copyWith(errorMessage: 'Please enter your mobile number');
      } else if (state.password.isEmpty) {
        state = state.copyWith(errorMessage: 'Please enter your password');
      } else if (state.password.length < 4) {
        state = state.copyWith(
          errorMessage: 'Password must be at least 4 characters',
        );
      }
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.login(
        mobile: state.userId.trim(),
        password: state.password.trim(),
      );

      if (response.result && response.error == null) {
        // Save driver ID and tenant ID for global access
        if (response.driverId != null) {
          await _storage.saveDriverId(response.driverId!);
        }
        if (response.tenantId != null) {
          await _storage.saveTenantId(response.tenantId!);
        }
        if (response.name != null) {
          await _storage.saveUserName(response.name!);
        }
        if (response.mobile != null) {
          await _storage.saveUserMobile(response.mobile!);
        }

        // Save credentials if remember me is enabled
        if (state.rememberMe) {
          await _storage.saveRememberMe(true);
          await _storage.saveUserId(state.userId);
          await _loginCacheService.saveRememberedCredentials(
            username: state.userId.trim(),
            password: state.password.trim(),
          );
        } else {
          // Clear remembered credentials if remember me is not checked
          await _loginCacheService.clearRememberedCredentials();
        }

        // Create user model from API response
        final user = UserModel(
          response.mobile ?? state.userId,
          name: response.name,
          email: response.email,
          driverId: response.driverId,
          imei: response.imei,
        );

        // Store user data in provider for profile page access
        ref.read(userDataProvider.notifier).state = response;

        // Fetch MDT Functions (available job activities) after successful login
        if (response.tenantId != null) {
          try {
            final mdtResponse = await _jobsApi.getMDTFunctions(
              tenantId: response.tenantId!,
            );
            // Save MDT Functions to local storage for persistence
            final mdtJson = jsonEncode(
              mdtResponse.functions.map((f) => f.toJson()).toList(),
            );
            await _storage.saveMDTFunctions(mdtJson);
            debugPrint('✅ MDT Functions saved to local storage');
          } catch (e) {
            // Log error but don't block login flow
            debugPrint('❌ Failed to fetch MDT Functions: $e');
          }

          // Initialize trailer cache for offline usage
          try {
            debugPrint('📱 Initializing trailer cache on login...');
            await trailerSearchManager.initializeCache(
              tenantId: response.tenantId!,
            );
            final cacheSize = trailerSearchManager.getCacheSize();
            debugPrint('✅ Trailer cache initialized with $cacheSize trailers');
          } catch (e) {
            // Log error but don't block login flow
            debugPrint('⚠️ Warning: Failed to initialize trailer cache: $e');
          }
        }

        state = state.copyWith(isLoading: false, success: true, user: user);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error: Please check your connection',
      );
    }
  }

  void setUserId(String v) => state = state.copyWith(userId: v);
  void setPassword(String v) => state = state.copyWith(password: v);

  void toggleRememberMe(bool v) {
    state = state.copyWith(rememberMe: v);
    // If unchecking remember me, clear saved credentials immediately
    if (!v) {
      _loginCacheService.clearRememberedCredentials();
    }
  }

  Future<void> logout() async {
    // Clear offline queue and all cached data
    await OfflineStorageService.clearAllDataOnLogout();
    // Clear cached login data
    await _loginCacheService.clearCache();
    // Clear all user data from local storage
    await _storage.clearAllUserData();
    // Clear trailer search cache
    await trailerSearchManager.clearCache();
    // Clear user from provider (only if ref is still mounted)
    if (ref.mounted) {
      ref.read(userDataProvider.notifier).state = null;
    } else {
      debugPrint('⚠️ Ref already disposed, skipping userDataProvider update');
    }
    // Reset state
    state = LoginState.initial();
  }
}

class LoginState {
  String userId;
  String password;
  final bool rememberMe;
  final bool isLoading;
  final String? errorMessage;
  final bool success;
  final UserModel? user;

  bool get isValid => userId.isNotEmpty && password.length >= 4;

  LoginState({
    required this.userId,
    required this.password,
    required this.rememberMe,
    required this.isLoading,
    required this.errorMessage,
    required this.success,
    required this.user,
  });

  factory LoginState.initial() => LoginState(
    userId: "",
    password: "",
    rememberMe: false,
    isLoading: false,
    errorMessage: null,
    success: false,
    user: null,
  );

  LoginState copyWith({
    String? userId,
    String? password,
    bool? rememberMe,
    bool? isLoading,
    String? errorMessage,
    bool? success,
    UserModel? user,
  }) {
    return LoginState(
      userId: userId ?? this.userId,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? this.success,
      user: user ?? this.user,
    );
  }
}
