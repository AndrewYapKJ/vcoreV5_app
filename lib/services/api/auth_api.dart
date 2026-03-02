import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/services/dio/dio_repo.dart';
import '../../models/login_response_model.dart';

/// Auth API Service
/// Handles all authentication-related API calls
class AuthApi {
  final Dio _dio = DioRepo().mDio;

  /// Login endpoint
  /// POST /login
  ///
  /// Request:
  /// {
  ///   "mobile": "01397851577",
  ///   "password": "1234"
  /// }
  ///
  /// Response: Wrapped in "d" property
  Future<LoginResponse> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'mobile': mobile, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'] as Map<String, dynamic>;
        return LoginResponse.fromJson(data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Login API Error: ${e.message}');
      rethrow;
    }
  }

  /// Register endpoint
  /// POST /register
  ///
  /// Request:
  /// {
  ///   "mobile": "01397851577",
  ///   "password": "1234",
  ///   "name": "John Doe",
  ///   "email": "john@example.com"
  /// }
  ///
  /// Response: Wrapped in "d" property
  Future<LoginResponse> register({
    required String mobile,
    required String password,
    required String name,
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'mobile': mobile,
          'password': password,
          'name': name,
          'email': email,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'] as Map<String, dynamic>;
        return LoginResponse.fromJson(data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Register API Error: ${e.message}');
      rethrow;
    }
  }

  /// Verify OTP endpoint
  /// POST /verify-otp
  ///
  /// Request:
  /// {
  ///   "mobile": "01397851577",
  ///   "otp": "123456"
  /// }
  Future<LoginResponse> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/verify-otp',
        data: FormData.fromMap({'mobile': mobile, 'otp': otp}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'] as Map<String, dynamic>;
        return LoginResponse.fromJson(data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Verify OTP API Error: ${e.message}');
      rethrow;
    }
  }

  /// Forgot password endpoint
  /// POST /forgot-password
  ///
  /// Request:
  /// {
  ///   "mobile": "01397851577"
  /// }
  Future<Map<String, dynamic>> forgotPassword({required String mobile}) async {
    try {
      final response = await _dio.post(
        '/forgot-password',
        data: FormData.fromMap({'mobile': mobile}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['d'] as Map<String, dynamic>;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Forgot Password API Error: ${e.message}');
      rethrow;
    }
  }

  /// Reset password endpoint
  /// POST /reset-password
  ///
  /// Request:
  /// {
  ///   "mobile": "01397851577",
  ///   "newPassword": "newpass123"
  /// }
  Future<Map<String, dynamic>> resetPassword({
    required String mobile,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/reset-password',
        data: FormData.fromMap({'mobile': mobile, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['d'] as Map<String, dynamic>;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Reset Password API Error: ${e.message}');
      rethrow;
    }
  }

  /// Set auth token for authenticated requests
  // void setToken(String token) {
  //   DioSetup().setAuthToken(token);
  // }

  // /// Remove auth token on logout
  // void removeToken() {
  //   DioSetup().removeAuthToken();
  // }
}
