import 'package:dio/dio.dart';
import 'package:vcore_v5_app/services/dio/interceptor/logging.dart';
import 'package:vcore_v5_app/services/offline/offline_storage_service.dart';

class DioRepo {
  final Dio _dio;

  DioRepo({String? baseUrl}) : _dio = _createDio(baseUrl);

  static Dio _createDio(String? baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl:
            baseUrl ?? 'https://vcore.x1.com.my/VCoreMultiTDriverMDT2025.asmx',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ),
    );

    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = OfflineStorageService.getAuthToken();
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Simple response handling - let ApiService handle caching
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          String errorMessage = 'Request failed';

          if (e.response?.data is Map &&
              e.response?.data['d']?['Error'] != null) {
            errorMessage = e.response!.data['d']['Error'] as String;
          } else if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout) {
            errorMessage = 'No internet connection';
          } else if (e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Server response timed out';
          } else if (e.response?.statusCode == 401) {
            errorMessage = 'Unauthorized access';
          } else if (e.response?.statusCode == 400) {
            errorMessage = 'Invalid request';
          } else if (e.response?.statusCode == 500) {
            errorMessage = 'Server error ${e.requestOptions.path}';
          }

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: errorMessage,
            ),
          );
        },
      ),
      LoggingInterceptors(),
    ]);

    return dio;
  }

  Dio get mDio => _dio;
}
