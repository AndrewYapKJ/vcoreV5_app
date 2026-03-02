import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio instance configuration
/// This centralizes all Dio setup including base URL, interceptors, and error handling
class DioSetup {
  static final DioSetup _instance = DioSetup._internal();

  static const String _baseUrl =
      'https://vcore.x1.com.my/VCoreMultiTDriverMDT2025.asmx';

  late Dio _dio;

  factory DioSetup() {
    return _instance;
  }

  DioSetup._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_ApiInterceptor());
  }

  Dio get instance => _dio;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

/// Custom Dio Interceptor for logging and error handling
class _ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📤 API REQUEST');
    debugPrint('Method: ${options.method}');
    debugPrint('URL: ${options.baseUrl}${options.path}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('Data: ${options.data}');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📥 API RESPONSE');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.data}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ API ERROR');
    debugPrint('Type: ${err.type}');
    debugPrint('Message: ${err.message}');
    debugPrint('Status Code: ${err.response?.statusCode}');
    debugPrint('Response: ${err.response?.data}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    return handler.next(err);
  }
}
