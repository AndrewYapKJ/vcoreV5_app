import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/models/uploaded_file_model.dart';
import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// Remote data source interface for Job API calls
abstract class JobRemoteDataSource {
  /// Fetch jobs from API (online only)
  Future<ApiResult<List<Job>>> getJobsWithDriver({
    required String driverId,
    required String status,
    required String pm,
    required String siteType,
    required String tenantId,
  });

  Future<ApiResult<List<Job>>> getJobListToday({
    required String driverId,
    required String pm,
    required String siteType,
    required String tenantId,
  });

  Future<ApiResult<Map<String, dynamic>>> updateJobWithDateTime({
    required String jobId,
    required String driverId,
    required String mdtCode,
    required String jobLastStatusDateTime,
    required String tenantId,
    String lat = '0.0',
    String lon = '0.0',
  });

  Future<ApiResult<List<UploadedFile>>> getJobImages({required String jobNo});

  Future<ApiResult<Map<String, dynamic>>> uploadJobImage({
    required String jobNo,
    required String filePath,
    required String fileName,
  });

  Future<ApiResult<Map<String, dynamic>>> updateJobDetails({
    required String jobNo,
    required String trailerID,
    required String trailerNo,
    required String containerNo,
    required String sealNo,
    required String remarks,
    required String siteType,
    required String pickQty,
    required String dropQty,
    required String tenantId,
  });
}

/// Local data source interface for caching and offline access
abstract class JobLocalDataSource {
  /// Cache job data
  Future<void> cacheJobs(String key, List<Job> jobs);

  /// Get cached jobs
  Future<List<Job>?> getCachedJobs(String key);

  /// Cache job images
  Future<void> cacheJobImages(String key, List<UploadedFile> images);

  /// Get cached images
  Future<List<UploadedFile>?> getCachedJobImages(String key);

  /// Get cache status and size
  Future<Map<String, dynamic>> getCacheStatus();

  /// Clear all cached data
  Future<void> clearAllCache();

  /// Clear specific cache
  Future<void> clearCache(String key);
}

/// Offline queue data source for managing queued requests
abstract class OfflineQueueDataSource {
  /// Queue a request for later sync
  Future<void> queueRequest({
    required String method,
    required String url,
    required String operationId,
    Map<String, dynamic>? data,
    Map<String, dynamic>? optimisticData,
    String? cacheKey,
  });

  /// Get all queued requests
  Future<List<Map<String, dynamic>>> getQueuedRequests();

  /// Remove a queued request
  Future<void> removeQueuedRequest(String requestId);

  /// Clear all queued requests
  Future<void> clearQueue();

  /// Get pending request count
  Future<int> getPendingRequestCount();

  /// Update request retry count
  Future<void> updateRetryCount(String requestId, int newCount);
}
