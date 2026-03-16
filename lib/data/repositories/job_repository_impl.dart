import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/data/datasources/job_datasource.dart';
import 'package:vcore_v5_app/domain/repositories/job_repository.dart';
import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/models/uploaded_file_model.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';
import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// Implementation of JobRepository
/// Handles switching between online/offline sources and manages caching
class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;
  final JobLocalDataSource localDataSource;
  final OfflineQueueDataSource offlineQueueDataSource;

  JobRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.offlineQueueDataSource,
  });

  final ConnectivityService _connectivityService = ConnectivityService();

  /// Helper to decide whether to fetch from remote or use cached data
  Future<ApiResult<T>> _executeWithCache<T>({
    required String cacheKey,
    required Future<ApiResult<T>> Function() remoteCall,
    required Future<T?> Function() cacheCall,
  }) async {
    try {
      // Try remote first if online
      if (_connectivityService.isOnline) {
        final result = await remoteCall();

        if (result.isSuccess && result.getDataOrNull() != null) {
          // Cache successful response for offline use
          if (cacheKey.isNotEmpty) {
            _cacheResult(cacheKey, result.getDataOrNull());
          }
          return result;
        }

        // If remote failed but we have cache, use it
        if (result.isError) {
          final cachedData = await cacheCall();
          if (cachedData != null) {
            debugPrint('Using cached data for $cacheKey due to API error');
            return ApiResult.success(cachedData);
          }
          return result;
        }

        return result;
      } else {
        // Offline mode - use cache
        final cachedData = await cacheCall();
        if (cachedData != null) {
          debugPrint('Using cached data in offline mode for $cacheKey');
          return ApiResult.offline(cachedData, message: 'Showing cached data');
        }

        return ApiResult.offline(
          null,
          message: 'No cached data available offline',
        );
      }
    } catch (e) {
      debugPrint('Error in executeWithCache: $e');
      // Last resort - try to get cached data
      final cachedData = await cacheCall();
      if (cachedData != null) {
        return ApiResult.offline(cachedData);
      }
      return ApiResult.error('Failed to fetch data: ${e.toString()}', error: e);
    }
  }

  void _cacheResult<T>(String key, T? data) {
    if (data == null || key.isEmpty) return;

    if (data is List<Job>) {
      localDataSource
          .cacheJobs(key, data)
          .then((_) {
            debugPrint('Cached data for key: $key');
          })
          .catchError((e) {
            debugPrint('Error caching data: $e');
          });
    } else if (data is List<UploadedFile>) {
      localDataSource
          .cacheJobImages(key, data)
          .then((_) {
            debugPrint('Cached images for key: $key');
          })
          .catchError((e) {
            debugPrint('Error caching images: $e');
          });
    }
  }

  @override
  Future<ApiResult<List<Job>>> getJobsWithDriver({
    required String driverId,
    required String status,
    required String pm,
    required String siteType,
    required String tenantId,
  }) async {
    final cacheKey =
        'jobs_with_driver:$driverId:$status:$pm:$siteType:$tenantId';

    return _executeWithCache<List<Job>>(
      cacheKey: cacheKey,
      remoteCall: () => remoteDataSource.getJobsWithDriver(
        driverId: driverId,
        status: status,
        pm: pm,
        siteType: siteType,
        tenantId: tenantId,
      ),
      cacheCall: () => localDataSource.getCachedJobs(cacheKey),
    );
  }

  @override
  Future<ApiResult<List<Job>>> getJobListToday({
    required String driverId,
    required String pm,
    required String siteType,
    required String tenantId,
  }) async {
    final cacheKey = 'jobs_list_today:$driverId:$pm:$siteType:$tenantId';

    return _executeWithCache<List<Job>>(
      cacheKey: cacheKey,
      remoteCall: () => remoteDataSource.getJobListToday(
        driverId: driverId,
        pm: pm,
        siteType: siteType,
        tenantId: tenantId,
      ),
      cacheCall: () => localDataSource.getCachedJobs(cacheKey),
    );
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> updateJobWithDateTime({
    required String jobId,
    required String driverId,
    required String mdtCode,
    required String jobLastStatusDateTime,
    required String tenantId,
    String lat = '0.0',
    String lon = '0.0',
  }) async {
    try {
      if (_connectivityService.isOnline) {
        return await remoteDataSource.updateJobWithDateTime(
          jobId: jobId,
          driverId: driverId,
          mdtCode: mdtCode,
          jobLastStatusDateTime: jobLastStatusDateTime,
          tenantId: tenantId,
          lat: lat,
          lon: lon,
        );
      } else {
        // Queue for later sync
        await offlineQueueDataSource.queueRequest(
          method: 'POST',
          url: '/UpdateJob',
          operationId: 'update_job_$jobId',
          data: {
            'jobid': jobId,
            'driverid': driverId,
            'mdtcode': mdtCode,
            'job_laststatus_date_time': jobLastStatusDateTime,
            'lat': lat,
            'lon': lon,
            'TenantId': tenantId,
          },
          optimisticData: {'result': true, 'error': null, 'queued': true},
        );

        return ApiResult.offline({
          'result': true,
          'queued': true,
        }, message: 'Job update queued - will sync when online');
      }
    } catch (e) {
      debugPrint('Error updating job: $e');
      return ApiResult.error('Failed to update job: ${e.toString()}', error: e);
    }
  }

  @override
  Future<ApiResult<List<UploadedFile>>> getJobImages({
    required String jobNo,
  }) async {
    final cacheKey = 'job_images:$jobNo';

    return _executeWithCache<List<UploadedFile>>(
      cacheKey: cacheKey,
      remoteCall: () => remoteDataSource.getJobImages(jobNo: jobNo),
      cacheCall: () => localDataSource.getCachedJobImages(cacheKey),
    );
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> uploadJobImage({
    required String jobNo,
    required String filePath,
    required String fileName,
  }) async {
    try {
      if (_connectivityService.isOnline) {
        return await remoteDataSource.uploadJobImage(
          jobNo: jobNo,
          filePath: filePath,
          fileName: fileName,
        );
      } else {
        // Queue image upload for later sync
        await offlineQueueDataSource.queueRequest(
          method: 'POST',
          url: '/app/ReceiveFile.ashx?id=$jobNo',
          operationId: 'upload_image_${jobNo}_$fileName',
          data: {'filePath': filePath, 'fileName': fileName, 'jobNo': jobNo},
          optimisticData: {
            'result': true,
            'message': 'Image upload queued - will sync when online',
            'fileName': fileName,
            'queued': true,
          },
        );

        return ApiResult.offline({
          'result': true,
          'message': 'Image upload queued',
          'fileName': fileName,
          'queued': true,
        }, message: 'Image will be uploaded when online');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return ApiResult.error(
        'Failed to upload image: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
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
  }) async {
    try {
      if (_connectivityService.isOnline) {
        return await remoteDataSource.updateJobDetails(
          jobNo: jobNo,
          trailerID: trailerID,
          trailerNo: trailerNo,
          containerNo: containerNo,
          sealNo: sealNo,
          remarks: remarks,
          siteType: siteType,
          pickQty: pickQty,
          dropQty: dropQty,
          tenantId: tenantId,
        );
      } else {
        // Queue for later sync
        await offlineQueueDataSource.queueRequest(
          method: 'POST',
          url: '/UpdateJobDetails',
          operationId: 'update_job_details_$jobNo',
          data: {
            'formData': {
              'jobNo': jobNo,
              'trailerID': trailerID,
              'trailerNo': trailerNo,
              'containerNo': containerNo,
              'SealNo': sealNo,
              'remarks': remarks,
              'siteType': siteType,
              'pickQty': pickQty,
              'dropQty': dropQty,
              'TenantId': tenantId,
            },
          },
          optimisticData: {
            'result': true,
            'message': 'Job details queued for sync',
            'queued': true,
          },
        );

        return ApiResult.offline({
          'result': true,
          'message': 'Job details queued - will sync when online',
          'queued': true,
        }, message: 'Details will be updated when online');
      }
    } catch (e) {
      debugPrint('Error updating job details: $e');
      return ApiResult.error(
        'Failed to update job details: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearAllCache();
  }

  @override
  Future<Map<String, dynamic>> getCacheStatus() async {
    return await localDataSource.getCacheStatus();
  }
}
