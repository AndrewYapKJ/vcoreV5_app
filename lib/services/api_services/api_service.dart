import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';
import 'package:vcore_v5_app/services/api_services/api_result.dart';
import 'package:vcore_v5_app/services/dio/dio_repo.dart';
import 'package:vcore_v5_app/services/offline/offline_storage_service.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = DioRepo().mDio;

  bool get _isOfflineModeEnabled => true;

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final connectivityService = ConnectivityService();
      final cacheKey = 'GET:$path${queryParameters?.toString() ?? ''}';

      // Only use offline features if the feature flag is enabled
      if (!connectivityService.isOnline && _isOfflineModeEnabled) {
        final cachedData = OfflineStorageService.getCachedApiResponse(cacheKey);
        if (cachedData != null) {
          final result = fromJson != null
              ? fromJson(cachedData)
              : cachedData as T;
          CustomSnackBar.showInfo(
            null,
            message: 'Showing cached data (offline)',
          );
          return ApiResult.success(result);
        } else {
          return ApiResult.offlineFailure('No cached data available offline');
        }
      }

      // If offline mode is disabled and we're offline, fail immediately
      if (!connectivityService.isOnline && !_isOfflineModeEnabled) {
        return ApiResult.onlineFailure('No internet connection');
      }

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.data == null) {
        return ApiResult.onlineFailure('Server returned null response');
      }

      if (response.statusCode == 200) {
        // Only cache if offline mode is enabled
        if (_isOfflineModeEnabled) {
          await OfflineStorageService.cacheApiResponse(
            cacheKey,
            response.data as Map<String, dynamic>,
            ttl: const Duration(hours: 24),
          );
        }

        final result = fromJson != null
            ? fromJson(response.data as Map<String, dynamic>)
            : response.data as T;

        return ApiResult.success(result);
      } else {
        return ApiResult.onlineFailure(
          'Request failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      debugPrint('Unexpected error in GET request: $e');
      return ApiResult.onlineFailure('Unexpected error occurred');
    }
  }

  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic>? optimisticData,
    bool enableOfflineQueue = false,
    String? baseUrl,
  }) async {
    return _performWriteRequest(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      fromJson: fromJson,
      optimisticData: optimisticData,
      enableOfflineQueue: enableOfflineQueue,
      baseUrl: baseUrl,
    );
  }

  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic>? optimisticData,
  }) async {
    return _performWriteRequest(
      'PUT',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      fromJson: fromJson,
      optimisticData: optimisticData,
    );
  }

  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic>? optimisticData,
  }) async {
    return _performWriteRequest(
      'PATCH',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      fromJson: fromJson,
      optimisticData: optimisticData,
    );
  }

  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic>? optimisticData,
  }) async {
    return _performWriteRequest(
      'DELETE',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      fromJson: fromJson,
      optimisticData: optimisticData,
    );
  }

  Future<ApiResult<T>> _performWriteRequest<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    Map<String, dynamic>? optimisticData,
    bool enableOfflineQueue = true,
    String? baseUrl, // Add baseUrl parameter
  }) async {
    try {
      final connectivityService = ConnectivityService();

      if (!connectivityService.isOnline) {
        // Only use offline queue if offline mode is enabled
        if (enableOfflineQueue && _isOfflineModeEnabled) {
          final requestId = DateTime.now().millisecondsSinceEpoch.toString();

          // Use baseUrl in offline queue if provided
          final fullUrl = baseUrl != null ? '$baseUrl$path' : path;

          await OfflineStorageService.queueOfflineRequest(
            method: method,
            url: '$fullUrl${queryParameters?.toString() ?? ''}',
            data: data,
            headers: options?.headers?.cast<String, dynamic>(),
            queryParameters: queryParameters,
          );

          if (optimisticData != null) {
            final optimisticKey = 'optimistic:$method:$path:$requestId';
            await OfflineStorageService.storeUserData(
              optimisticKey,
              optimisticData,
            );
          }

          // GlobalErrorService.showWarning(
          //     'Request queued for when connection is restored');

          return ApiResult.offlineSuccess(
            data: optimisticData != null && fromJson != null
                ? fromJson(optimisticData)
                : optimisticData as T?,
            requestId: requestId,
          );
        } else {
          return ApiResult.offlineFailure(
            enableOfflineQueue
                ? 'Offline mode is disabled'
                : 'Cannot perform this action while offline',
          );
        }
      }

      // Create a new Dio instance with custom baseUrl if provided
      Dio dioInstance = _dio;
      if (baseUrl != null) {
        dioInstance = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: _dio.options.connectTimeout,
            receiveTimeout: _dio.options.receiveTimeout,
            sendTimeout: _dio.options.sendTimeout,
            headers: _dio.options.headers,
            responseType: _dio.options.responseType,
            validateStatus: _dio.options.validateStatus,
          ),
        );

        // Copy interceptors from original dio instance
        dioInstance.interceptors.addAll(_dio.interceptors);
      }

      Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await dioInstance.post(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'PUT':
          response = await dioInstance.put(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'PATCH':
          response = await dioInstance.patch(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'DELETE':
          response = await dioInstance.delete(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      if (response.data == null) {
        return ApiResult.onlineFailure('Server returned null response');
      }

      final result = fromJson != null
          ? fromJson(response.data as Map<String, dynamic>)
          : response.data as T;
      print(" Response from $method $path: ${response.data}");
      return ApiResult.success(result);
    } on DioException catch (e) {
      print(" DioException in $method request to $path: ${e.error}");
      return _handleDioException(e);
    } catch (e) {
      print(" DioException in $method request to $path: ${e}");
      debugPrint('Unexpected error in $method request: $e');
      return ApiResult.onlineFailure('Unexpected error occurred');
    }
  }

  ApiResult<T> _handleDioException<T>(DioException e) {
    String errorMessage = 'Request failed';

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'No internet connection';
      return ApiResult.offlineFailure(errorMessage);
    } else if (e.response?.data is Map &&
        e.response?.data['d']?['Error'] != null) {
      errorMessage = e.response!.data['d']['Error'] as String;
    } else if (e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Server response timed out';
    } else if (e.response?.statusCode == 401) {
      errorMessage = 'Unauthorized access';
    } else if (e.response?.statusCode == 400) {
      errorMessage = 'Invalid request';
    } else if (e.response?.statusCode == 500) {
      errorMessage = 'Server error ${e.requestOptions.path}';
    }

    CustomSnackBar.showError(null, message: errorMessage);
    return ApiResult.onlineFailure(errorMessage);
  }

  bool hasPendingRequests() {
    return OfflineStorageService.getQueuedRequests().isNotEmpty;
  }

  int getPendingRequestsCount() {
    return OfflineStorageService.getQueuedRequests().length;
  }
}
