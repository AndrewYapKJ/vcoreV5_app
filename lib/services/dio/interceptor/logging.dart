import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('🚀 --> ${options.method} ${options.uri}');
      if (options.headers.isNotEmpty) {
        debugPrint('📋 Headers: ${options.headers}');
      }
      if (options.queryParameters.isNotEmpty) {
        debugPrint('🔍 Query: ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('📦 Body: ${options.data}');
      }
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final statusIcon = response.statusCode == 200 ? '✅' : '⚠️';
      debugPrint(
          '$statusIcon <-- ${response.statusCode} ${response.requestOptions.uri}');

      if (response.data != null) {
        final dataString = response.data.toString();
        if (dataString.length < 500) {
          debugPrint('📥 Response: ${response.data}');
        } else {
          debugPrint(
              '📥 Response: ${dataString.substring(0, 200)}...[truncated]');
        }
      }
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: ${err.message}');
      debugPrint('🔗 URL: ${err.requestOptions.uri}');
      if (err.response != null) {
        debugPrint('📊 Status: ${err.response?.statusCode}');
        debugPrint('📄 Error Data: ${err.response?.data}');
      }
    }
    return handler.next(err);
  }
}
