import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';
import 'package:vcore_v5_app/services/dio/dio_repo.dart';
import 'package:vcore_v5_app/services/offline/offline_storage_service.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';

class OfflineQueueManager {
  static final OfflineQueueManager _instance = OfflineQueueManager._internal();
  factory OfflineQueueManager() => _instance;
  OfflineQueueManager._internal();

  bool _isProcessing = false;

  static Function()? _onSyncComplete;

  static void setOnSyncComplete(Function() callback) {
    _onSyncComplete = callback;
  }

  static void clearOnSyncComplete() {
    _onSyncComplete = null;
  }

  Future<void> processQueuedRequests() async {
    if (_isProcessing) return;

    _isProcessing = true;

    try {
      final connectivityService = ConnectivityService();
      if (!connectivityService.isOnline) {
        debugPrint('Cannot process queue: still offline');
        return;
      }

      final queuedRequests = OfflineStorageService.getQueuedRequests();
      if (queuedRequests.isEmpty) {
        debugPrint('No queued requests to process');
        return;
      }

      debugPrint('Processing ${queuedRequests.length} queued requests');

      int successCount = 0;
      int failureCount = 0;

      for (final request in queuedRequests) {
        try {
          debugPrint(
            'Processing request: ${request['method']} ${request['url']}',
          );
          debugPrint('Request data: ${request['data']}');
          debugPrint('Request headers: ${request['headers']}');
          debugPrint('Request queryParams: ${request['queryParameters']}');

          await _processRequest(request);

          // Cache the response if cacheKey is provided and optimisticData exists
          if (request['cacheKey'] != null &&
              request['optimisticData'] != null) {
            await OfflineStorageService.cacheApiResponse(
              request['cacheKey'],
              request['optimisticData'],
            );
            debugPrint('Cached response for key: ${request['cacheKey']}');
          }

          await OfflineStorageService.removeQueuedRequest(request['id']);
          successCount++;
          debugPrint('Successfully processed request: ${request['id']}');
        } catch (e, stackTrace) {
          debugPrint('Failed to process queued request ${request['id']}: $e');
          debugPrint('Stack trace: $stackTrace');

          // Increment retry count
          final currentRetry = (request['retryCount'] as int?) ?? 0;
          if (currentRetry < 3) {
            await OfflineStorageService.updateQueuedRequestRetry(
              request['id'],
              newRetryCount: currentRetry + 1,
            );
            debugPrint('Retry count incremented to ${currentRetry + 1}');
          } else {
            // Max retries exceeded, remove the request
            await OfflineStorageService.removeQueuedRequest(request['id']);
            debugPrint('Request removed after max retries: ${request['id']}');
          }

          failureCount++;
        }
      }

      if (successCount > 0) {
        CustomSnackBar.showSuccess(
          null,
          message: 'Synced $successCount requests successfully',
        );

        if (_onSyncComplete != null) {
          debugPrint('Triggering data refresh after successful sync');
          _onSyncComplete!();
        }
      }

      if (failureCount > 0) {
        CustomSnackBar.showWarning(
          null,
          message: '$failureCount requests failed to sync',
        );
      }
    } catch (e) {
      debugPrint('Error processing queue: $e');
      CustomSnackBar.showError(null, message: 'Failed to sync offline data');
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processRequest(Map<dynamic, dynamic> request) async {
    final dio = DioRepo().mDio;

    final method = request['method'] as String;
    final url = request['url'] as String;
    final data = request['data'];

    Map<String, dynamic>? headers;
    if (request['headers'] != null) {
      final headersRaw = request['headers'];
      if (headersRaw is Map) {
        headers = <String, dynamic>{};
        headersRaw.forEach((key, value) {
          headers![key.toString()] = value;
        });
      }
    }

    Map<String, dynamic>? queryParameters;
    if (request['queryParameters'] != null) {
      final queryParamsRaw = request['queryParameters'];
      if (queryParamsRaw is Map) {
        queryParameters = <String, dynamic>{};
        queryParamsRaw.forEach((key, value) {
          queryParameters![key.toString()] = value;
        });
      }
    }

    final options = Options(method: method, headers: headers);

    Response response;

    try {
      debugPrint('Making $method request to: $url');
      debugPrint('Data: $data');
      debugPrint('Headers: $headers');
      debugPrint('Query parameters: $queryParameters');

      switch (method.toUpperCase()) {
        case 'GET':
          response = await dio.get(
            url,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'POST':
          // Special handling for image uploads
          if (url.contains('ReceiveFile.ashx') &&
              data is Map &&
              data.containsKey('base64Data')) {
            // Handle image upload with FormData
            final base64Data = data['base64Data'] as String;
            final filename = data['filename'] as String;

            debugPrint('Processing image upload with base64 data: $filename');

            // Convert base64 back to bytes
            final imageBytes = base64Decode(base64Data);

            // Create FormData for file upload
            final formData = FormData.fromMap({
              'file': MultipartFile.fromBytes(
                imageBytes,
                filename: filename,
                contentType: DioMediaType('image', 'jpeg'),
              ),
            });

            debugPrint(
              'Processing image upload: $filename (${imageBytes.length} bytes)',
            );

            response = await dio.post(
              url,
              data: formData,
              queryParameters: queryParameters,
              options: options.copyWith(contentType: 'multipart/form-data'),
            );
          } else if (url.contains('ReceiveFile.ashx') &&
              data is Map &&
              data.containsKey('imagePath')) {
            // Legacy format - log warning and skip
            debugPrint(
              'WARNING: Found legacy imagePath format in queue - skipping invalid request',
            );
            debugPrint('Legacy data: $data');
            throw Exception(
              'Legacy image upload format detected - request skipped',
            );
          } else {
            // Regular POST request
            response = await dio.post(
              url,
              data: data,
              queryParameters: queryParameters,
              options: options,
            );
          }
          break;
        case 'PUT':
          response = await dio.put(
            url,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'DELETE':
          response = await dio.delete(
            url,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        case 'PATCH':
          response = await dio.patch(
            url,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported');
      }

      debugPrint(
        'Successfully processed queued request: $method $url (${response.statusCode})',
      );
      debugPrint('Response data: ${response.data}');
    } catch (e) {
      debugPrint('Error in HTTP request: $e');
      rethrow;
    }
  }

  Future<void> clearQueue() async {
    await OfflineStorageService.clearQueue();
    CustomSnackBar.showInfo(null, message: 'Offline queue cleared');
  }

  /// Clear invalid legacy image upload requests from queue
  Future<void> clearLegacyImageUploads() async {
    try {
      final queuedRequests = OfflineStorageService.getQueuedRequests();
      int removedCount = 0;

      for (var request in queuedRequests) {
        final url = request['url'] as String? ?? '';
        final data = request['data'];

        // Remove legacy image upload requests
        if (url.contains('ReceiveFile.ashx') &&
            data is Map &&
            data.containsKey('imagePath')) {
          await OfflineStorageService.removeQueuedRequest(request['id']);
          removedCount++;
          debugPrint('Removed legacy image upload request: ${request['id']}');
        }
      }

      if (removedCount > 0) {
        CustomSnackBar.showInfo(
          null,
          message: 'Cleared $removedCount legacy image upload requests',
        );
        debugPrint(
          'Cleared $removedCount legacy image upload requests from queue',
        );
      } else {
        debugPrint('No legacy image upload requests found in queue');
      }
    } catch (e) {
      debugPrint('Error clearing legacy image uploads: $e');
    }
  }

  int getQueuedRequestsCount() {
    return OfflineStorageService.getQueuedRequests().length;
  }

  bool hasQueuedRequests() {
    return OfflineStorageService.getQueuedRequests().isNotEmpty;
  }
}
