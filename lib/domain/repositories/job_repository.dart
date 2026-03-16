import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/models/uploaded_file_model.dart';
import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// Repository interface for Job-related operations
/// This defines the contract that all Job data sources must follow
/// Supports both online and offline modes
abstract class JobRepository {
  /// Get jobs for driver with filters
  /// Caches results automatically for offline use
  ///
  /// Parameters:
  /// - driverId: Driver ID
  /// - status: "pending", "in-progress", or "completed"
  /// - pm: Vehicle ID
  /// - siteType: "HMS" or "TMS"
  /// - tenantId: Tenant ID
  ///
  /// Returns: ApiResult with list of jobs
  /// - When online: Fetches from API and caches
  /// - When offline: Returns cached data
  /// - On error: Attempts to return cached data
  Future<ApiResult<List<Job>>> getJobsWithDriver({
    required String driverId,
    required String status,
    required String pm,
    required String siteType,
    required String tenantId,
  });

  /// Get completed jobs for today
  /// Similar caching behavior as getJobsWithDriver
  Future<ApiResult<List<Job>>> getJobListToday({
    required String driverId,
    required String pm,
    required String siteType,
    required String tenantId,
  });

  /// Update job status with date/time
  ///
  /// Returns: ApiResult with update confirmation
  /// - When online: Sends to API immediately
  /// - When offline: Queues for later sync
  /// - Response includes 'queued' flag if offline
  Future<ApiResult<Map<String, dynamic>>> updateJobWithDateTime({
    required String jobId,
    required String driverId,
    required String mdtCode,
    required String jobLastStatusDateTime,
    required String tenantId,
    String lat = '0.0',
    String lon = '0.0',
  });

  /// Get images for a specific job
  /// Images are cached for offline viewing
  Future<ApiResult<List<UploadedFile>>> getJobImages({required String jobNo});

  /// Upload image for a job
  ///
  /// Returns: ApiResult with upload confirmation
  /// - When online: Uploads immediately
  /// - When offline: Queues for later sync
  /// - Response includes 'queued' flag if offline
  ///
  /// Parameters:
  /// - jobNo: Job number
  /// - filePath: Full path to image file
  /// - fileName: Display name for the file
  Future<ApiResult<Map<String, dynamic>>> uploadJobImage({
    required String jobNo,
    required String filePath,
    required String fileName,
  });

  /// Update complete job details
  ///
  /// Returns: ApiResult with update confirmation
  /// - When online: Sends to API immediately
  /// - When offline: Queues for later sync
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

  /// Clear all cached job data
  Future<void> clearCache();

  /// Get current cache status
  Future<Map<String, dynamic>> getCacheStatus();
}
