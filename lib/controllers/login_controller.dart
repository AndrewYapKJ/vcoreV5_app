import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/storage/login_cache_service.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../services/api/jobs_api.dart';

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

        if (state.rememberMe) {
          await _storage.saveRememberMe(true);
          await _storage.saveUserId(state.userId);
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
            debugPrint('MDT Functions saved to local storage');
          } catch (e) {
            // Log error but don't block login flow
            debugPrint('Failed to fetch MDT Functions: $e');
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
  void toggleRememberMe(bool v) => state = state.copyWith(rememberMe: v);

  Future<void> logout() async {
    // Clear cached login data
    await _loginCacheService.clearCache();
    // Clear all user data from local storage
    await _storage.clearAllUserData();
    // Clear user from provider
    ref.read(userDataProvider.notifier).state = null;
    // Reset state
    state = LoginState.initial();
  }
}

class LoginState {
  final String userId;
  final String password;
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
