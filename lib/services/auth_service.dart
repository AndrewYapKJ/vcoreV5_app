import 'package:dio/dio.dart';
import 'api/auth_api.dart';
import 'storage/login_cache_service.dart';
import '../models/login_response_model.dart';

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
        // Cache the login data
        await _cacheService.cacheLoginData(
          driverId: response.driverId,
          mobile: response.mobile,
          name: response.name,
          email: response.email,
          imei: response.imei,
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
        // Cache the login data
        await _cacheService.cacheLoginData(
          driverId: response.driverId,
          mobile: response.mobile,
          name: response.name,
          email: response.email,
          imei: response.imei,
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
    await _cacheService.clearCache();
  }
}
