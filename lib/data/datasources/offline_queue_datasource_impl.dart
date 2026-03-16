import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/data/datasources/job_datasource.dart';
import 'package:vcore_v5_app/services/offline/offline_storage_service.dart';

/// Implementation of OfflineQueueDataSource
/// Uses OfflineStorageService to manage request queue
class OfflineQueueDataSourceImpl implements OfflineQueueDataSource {
  OfflineQueueDataSourceImpl();
  @override
  Future<void> queueRequest({
    required String method,
    required String url,
    required String operationId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? optimisticData,
    String? cacheKey,
  }) async {
    try {
      await OfflineStorageService.queueOfflineRequest(
        method: method,
        url: url,
        data: data,
        optimisticData: optimisticData,
        cacheKey: cacheKey,
      );

      debugPrint('✅ Queued request: $method $url (operationId: $operationId)');
    } catch (e) {
      debugPrint('❌ Error queuing request: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getQueuedRequests() async {
    try {
      final requests = OfflineStorageService.getQueuedRequests();
      debugPrint('Retrieved ${requests.length} queued requests');
      return requests.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ Error getting queued requests: $e');
      return [];
    }
  }

  @override
  Future<void> removeQueuedRequest(String requestId) async {
    try {
      await OfflineStorageService.removeQueuedRequest(requestId);
      debugPrint('✅ Removed queued request: $requestId');
    } catch (e) {
      debugPrint('❌ Error removing queued request: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearQueue() async {
    try {
      await OfflineStorageService.clearQueue();
      debugPrint('✅ Cleared offline queue');
    } catch (e) {
      debugPrint('❌ Error clearing queue: $e');
      rethrow;
    }
  }

  @override
  Future<int> getPendingRequestCount() async {
    try {
      final requests = OfflineStorageService.getQueuedRequests();
      return requests.length;
    } catch (e) {
      debugPrint('❌ Error getting pending request count: $e');
      return 0;
    }
  }

  @override
  Future<void> updateRetryCount(String requestId, int newCount) async {
    try {
      await OfflineStorageService.updateQueuedRequestRetry(
        requestId,
        newRetryCount: newCount,
      );
      debugPrint('✅ Updated retry count for request: $requestId');
    } catch (e) {
      debugPrint('❌ Error updating retry count: $e');
      rethrow;
    }
  }
}
