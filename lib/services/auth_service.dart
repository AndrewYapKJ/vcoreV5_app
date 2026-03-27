import 'package:dio/dio.dart';
import 'api/auth_api.dart';
import 'storage/login_cache_service.dart';
import 'offline/offline_storage_service.dart';
import '../models/login_response_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final AuthApi _authApi = AuthApi();
  final LoginCacheService _cacheService = LoginCacheService();

  /// Login with mobile and password
  /// Returns LoginResponse with all driver details
  Future<LoginResponse> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final response = await _authApi.login(mobile: mobile, password: password);

      // Check if login was successful
      if (response.result && response.error == null) {
        debugPrint(
          '✅ AuthService: Login successful - TenantId: ${response.tenantId}',
        );
        final responseJson = response.toJson();
        debugPrint(
          '📦 AuthService: Response JSON keys: ${responseJson.keys.toList()}',
        );

        // Cache the complete login response
        await _cacheService.cacheLoginData(
          driverId: response.driverId,
          mobile: response.mobile,
          name: response.name,
          email: response.email,
          imei: response.imei,
          userInfo: responseJson, // Save complete response
        );

        // Cache PTI status
        await _cacheService.cachePTIStatus(isCompleted: response.ptiStatus);
      }

      return response;
    } on DioException catch (e) {
      // Return failed response with error
      return LoginResponse(
        result: false,
        error: e.message ?? 'An error occurred during login',
        critUpdate: false,
        ptiStatus: false,
      );
    }
  }

  /// Register with mobile, password, name, and email
  /// Returns LoginResponse with registration result
  Future<LoginResponse> register({
    required String mobile,
    required String password,
    required String name,
    required String email,
  }) async {
    try {
      final response = await _authApi.register(
        mobile: mobile,
        password: password,
        name: name,
        email: email,
      );

      // Check if registration was successful
      if (response.result && response.error == null) {
        // Cache the complete login response
        await _cacheService.cacheLoginData(
          driverId: response.driverId,
          mobile: response.mobile,
          name: response.name,
          email: response.email,
          imei: response.imei,
          userInfo: response.toJson(), // Save complete response
        );
      }

      return response;
    } on DioException catch (e) {
      return LoginResponse(
        result: false,
        error: e.message ?? 'An error occurred during registration',
        critUpdate: false,
        ptiStatus: false,
      );
    }
  }

  /// Logout - clear all cached data
  Future<void> logout() async {
    // Clear offline queue and all cached data
    await OfflineStorageService.clearAllDataOnLogout();
    // Clear login cache
    await _cacheService.clearCache();
  }
}
