import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:vcore_v5_app/services/api_services/api_service.dart';
import 'package:vcore_v5_app/services/offline/offline_storage_service.dart';
import '../../models/job_model.dart';
import '../../models/uploaded_file_model.dart';

/// Job API Service
/// Handles all job-related API calls
class JobApi {
  final ApiService _apiService = ApiService();

  /// Get Jobs with Driver
  /// POST /GetJobswithdriver
  ///
  /// Request:
  /// {
  ///   "driverId": "DRIV000004",
  ///   "Status": "0", // 0 = pending, 1 = in-progress
  ///   "PM": "47",
  ///   "SiteType": "HMS", // HMS or TMS
  ///   "TenantId": "1"
  /// }
  ///
  /// Response:
  /// {
  ///   "d": [
  ///     {
  ///       "ID": 16584,
  ///       "NO": "I-2602-00116-2-D1",
  ///       ...
  ///     }
  ///   ]
  /// }
  Future<List<Job>> getJobsWithDriver({
    required String driverId,
    required String status, // "0" for pending, "1" for in-progress
    required String pm,
    required String siteType, // "HMS" or "TMS"
    required String tenantId,
  }) async {
    final cacheKey =
        'jobs_with_driver:$driverId:$status:$pm:$siteType:$tenantId';

    try {
      final result = await _apiService.post<List<Job>>(
        '/GetJobswithdriver',
        data: {
          'driverId': driverId,
          'Status': status,
          'PM': pm,
          'SiteType': siteType,
          'TenantId': tenantId,
        },
        enableOfflineQueue: false,
        fromJson: (data) {
          if (data['d'] == null) {
            throw Exception('Invalid response format: missing d property');
          }
          final list = data['d'] as List?;
          return list?.map((json) => Job.fromJson(json)).toList() ?? [];
        },
      );

      if (result.isSuccess && result.data != null) {
        // Cache successful response
        await OfflineStorageService.cacheApiResponse(cacheKey, {
          'jobs': result.data!.map((j) => j.toJson()).toList(),
        });
        debugPrint(
          'Jobs with driver fetched and cached: ${result.data!.length}',
        );
        return result.data!;
      } else {
        // Try to use cached data on failure
        final cachedData = OfflineStorageService.getCachedApiResponse(cacheKey);
        if (cachedData != null && cachedData['jobs'] != null) {
          final cachedJobs = (cachedData['jobs'] as List)
              .map((json) => Job.fromJson(json as Map<String, dynamic>))
              .toList();
          debugPrint(
            'Using cached jobs with driver due to API failure: ${cachedJobs.length}',
          );
          return cachedJobs;
        }
        throw Exception(result.errorMessage ?? 'Failed to fetch jobs');
      }
    } catch (e) {
      debugPrint('GetJobsWithDriver API Error: $e');

      // Fall back to cached data on exception
      final cachedData = OfflineStorageService.getCachedApiResponse(cacheKey);
      if (cachedData != null && cachedData['jobs'] != null) {
        final cachedJobs = (cachedData['jobs'] as List)
            .map((json) => Job.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint(
          'Using cached jobs with driver due to exception: ${cachedJobs.length}',
        );
        return cachedJobs;
      }
      rethrow;
    }
  }

  /// Get Job List Today (Completed Jobs)
  /// POST /Z_GetJobListToday
  ///
  /// Request:
  /// {
  ///   "driverId": "DRIV000004",
  ///   "PM": "47",
  ///   "SiteType": "HMS", // HMS or TMS
  ///   "TenantId": "1"
  /// }
  ///
  /// Response:
  /// {
  ///   "d": [
  ///     {
  ///       "ID": 16584,
  ///       "NO": "I-2602-00116-2-D1",
  ///       ...
  ///     }
  ///   ]
  /// }
  Future<List<Job>> getJobListToday({
    required String driverId,
    required String pm,
    required String siteType, // "HMS" or "TMS"
    required String tenantId,
  }) async {
    final cacheKey = 'jobs_list_today:$driverId:$pm:$siteType:$tenantId';

    try {
      final result = await _apiService.post<List<Job>>(
        '/Z_GetJobListToday',
        data: {
          'driverId': driverId,
          'PM': pm,
          'SiteType': siteType,
          'TenantId': tenantId,
        },
        enableOfflineQueue: false,
        fromJson: (data) {
          if (data['d'] == null) {
            throw Exception('Invalid response format: missing d property');
          }
          final list = data['d'] as List?;
          return list?.map((json) => Job.fromJson(json)).toList() ?? [];
        },
      );

      if (result.isSuccess && result.data != null) {
        // Cache successful response
        await OfflineStorageService.cacheApiResponse(cacheKey, {
          'completedJobs': result.data!.map((j) => j.toJson()).toList(),
        });
        debugPrint('Job list today fetched and cached: ${result.data!.length}');
        return result.data!;
      } else {
        // Try to use cached data on failure
        final cachedData = OfflineStorageService.getCachedApiResponse(cacheKey);
        if (cachedData != null && cachedData['completedJobs'] != null) {
          final cachedJobs = (cachedData['completedJobs'] as List)
              .map((json) => Job.fromJson(json as Map<String, dynamic>))
              .toList();
          debugPrint(
            'Using cached job list today due to API failure: ${cachedJobs.length}',
          );
          return cachedJobs;
        }
        throw Exception(result.errorMessage ?? 'Failed to fetch job list');
      }
    } catch (e) {
      debugPrint('GetJobListToday API Error: $e');

      // Fall back to cached data on exception
      final cachedData = OfflineStorageService.getCachedApiResponse(cacheKey);
      if (cachedData != null && cachedData['completedJobs'] != null) {
        final cachedJobs = (cachedData['completedJobs'] as List)
            .map((json) => Job.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint(
          'Using cached job list today due to exception: ${cachedJobs.length}',
        );
        return cachedJobs;
      }
      rethrow;
    }
  }

  /// Update Job with DateTime
  /// POST /UpdateJob_withDTime
  ///
  /// Request:
  /// {
  ///   "jobid": "I-2602-00116-2-D1",
  ///   "driverid": "DRIV000004",
  ///   "mdtcode": "101",
  ///   "lat": "",
  ///   "lon": "",
  ///   "job_laststatus_date_time": "2026-03-03 12:00:00",
  ///   "TenantId": "1"
  /// }
  ///
  /// Response:
  /// {
  ///   "d": {
  ///     "Result": true,
  ///     "Error": null
  ///   }
  /// }
  Future<Map<String, dynamic>> updateJobWithDateTime({
    required String jobId,
    required String driverId,
    required String mdtCode,
    required String jobLastStatusDateTime,
    required String tenantId,
    String lat = '0.0',
    String lon = '0.0',
  }) async {
    final optimisticData = {
      'jobId': jobId,
      'driverId': driverId,
      'mdtCode': mdtCode,
      'updatedAt': DateTime.now().toIso8601String(),
      'status': 'updated_offline',
    };

    try {
      final result = await _apiService.post<Map<String, dynamic>>(
        '/UpdateJob',
        data: {
          'jobid': jobId,
          'driverid': driverId,
          'mdtcode': "0$mdtCode",
          'lat': lat,
          'lon': lon,
          'TenantId': tenantId,
        },
        optimisticData: optimisticData,
        enableOfflineQueue: true,
        fromJson: (data) {
          // Handle offline optimistic data format

          if (data.containsKey('jobId') && data.containsKey('status')) {
            print("2222");
            return {'result': true, 'error': null};
          }
          if (data['d'] == null) {
            print("33333");
            throw Exception('Invalid response format: missing d property');
          }
          print("11111");
          final responseData = data['d'] as Map<String, dynamic>;
          return {
            'result': responseData['Result'] ?? false,
            'error': responseData['Error'],
          };
        },
      );

      print("44444");
      if (result.isSuccess) {
        debugPrint('✅ UpdateJob Success');
        return result.data ?? {'result': false, 'error': 'No response data'};
      } else if (result.isOffline) {
        print("55555");
        // Request was queued offline
        debugPrint('📋 UpdateJob queued for sync when online');
        return {'result': true, 'error': null, 'queued': true};
      } else {
        print("6666");
        throw Exception(result.errorMessage ?? 'Failed to update job');
      }
    } catch (e) {
      debugPrint('UpdateJob_withDTime API Error: $e');
      return {'result': false, 'error': e.toString()};
    }
  }

  /// Get Job Images
  /// POST /GetJobImages
  ///
  /// Request:
  /// {
  ///   "JobNo": "CNE-2602-0013-1-D1"
  /// }
  ///
  /// Response:
  /// {
  ///   "d": [
  ///     {
  ///       "__type": "VCoreMultiTDriverMDT2025+MDTUploadedFile",
  ///       "Id": "20",
  ///       "Name": "CNE-2602-0013-1-D1-20260303163156",
  ///       "ContentType": "application/octet-stream",
  ///       "Data": "/9j/4QGvRXhpZgAATU0A..." // base64 encoded image
  ///     }
  ///   ]
  /// }
  Future<List<UploadedFile>> getJobImages({required String jobNo}) async {
    final cacheKey = 'job_images:$jobNo';

    try {
      final result = await _apiService.post<List<UploadedFile>>(
        '/GetJobImages',
        data: {'JobNo': jobNo},
        enableOfflineQueue: false,
        fromJson: (data) {
          if (data['d'] == null) {
            throw Exception('Invalid response format: missing d property');
          }
          final list = data['d'] as List?;
          return list?.map((json) => UploadedFile.fromJson(json)).toList() ??
              [];
        },
      );

      if (result.isSuccess && result.data != null) {
        // Cache successful response
        await OfflineStorageService.cacheApiResponse(cacheKey, {
          'images': result.data!.map((i) => i.toJson()).toList(),
        });
        debugPrint('Job images fetched and cached: ${result.data!.length}');
        return result.data!;
      } else {
        // Try to use cached data on failure
        final cachedData = OfflineStorageService.getCachedApiResponse(cacheKey);
        if (cachedData != null && cachedData['images'] != null) {
          final cachedImages = (cachedData['images'] as List)
              .map(
                (json) => UploadedFile.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          debugPrint(
            'Using cached job images due to API failure: ${cachedImages.length}',
          );
          return cachedImages;
        }
        throw Exception(result.errorMessage ?? 'Failed to fetch job images');
      }
    } catch (e) {
      debugPrint('GetJobImages API Error: $e');

      // Fall back to cached data on exception
      final cachedData = OfflineStorageService.getCachedApiResponse(cacheKey);
      if (cachedData != null && cachedData['images'] != null) {
        final cachedImages = (cachedData['images'] as List)
            .map((json) => UploadedFile.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint(
          'Using cached job images due to exception: ${cachedImages.length}',
        );
        return cachedImages;
      }
      return [];
    }
  }

  /// Update Job Details
  /// POST /UpdateJobDetails
  ///
  /// Request:
  /// {
  ///   "jobNo": "CNE-2602-0013-1-D1",
  ///   "trailerID": "47",
  ///   "trailerNo": "TR-001",
  ///   "containerNo": "CONT123",
  ///   "SealNo": "SEAL123",
  ///   "remarks": "Some remarks",
  ///   "siteType": "HMS",
  ///   "pickQty": "1",
  ///   "dropQty": "0",
  ///   "TenantId": "2010"
  /// }
  ///
  /// Response:
  /// {
  ///   "d": {
  ///     "result": true,
  ///     "message": "Success"
  ///   }
  /// }
  Future<Map<String, dynamic>> updateJobDetails({
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
    final optimisticData = {
      'jobNo': jobNo,
      'trailerNo': trailerNo,
      'containerNo': containerNo,
      'sealNo': sealNo,
      'remarks': remarks,
      'updatedAt': DateTime.now().toIso8601String(),
      'status': 'updated_offline',
    };

    try {
      final result = await _apiService.post<Map<String, dynamic>>(
        '/UpdateJobDetails',
        data: {
          "formData": {
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
        optimisticData: optimisticData,
        enableOfflineQueue: true,
        fromJson: (data) {
          // Handle offline optimistic data format
          if (data.containsKey('jobNo') && data.containsKey('status')) {
            return {'result': true, 'message': 'Success'};
          }
          if (data['d'] == null) {
            throw Exception('Invalid response format: missing d property');
          }
          return data['d'] as Map<String, dynamic>;
        },
      );

      if (result.isSuccess) {
        debugPrint('✅ UpdateJobDetails Success');
        return result.data ?? {'result': true, 'message': 'Success'};
      } else if (result.isOffline) {
        // Request was queued offline
        debugPrint('📋 UpdateJobDetails queued for sync when online');
        return {
          'result': true,
          'message': 'Request queued - will sync when online',
          'queued': true,
        };
      } else {
        return {
          'result': false,
          'message': result.errorMessage ?? 'Error updating job details',
          'error': result.errorMessage,
        };
      }
    } catch (e) {
      debugPrint('❌ UpdateJobDetails API Error: $e');
      return {'result': false, 'message': e.toString(), 'error': e.toString()};
    }
  }

  /// Upload Job Image
  /// POST https://vcore.x1.com.my/app/ReceiveFile.ashx?id={jobNo}
  ///
  /// Supports offline queueing - when offline, converts image to base64 and queues for sync.
  ///
  /// Request: FormData with 'files' field containing the image file
  /// Response: HTTP 200 on success
  Future<Map<String, dynamic>> uploadJobImage({
    required String jobNo,
    required String filePath,
    required String fileName,
  }) async {
    // Use dedicated Dio instance with custom base URL for file uploads
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await dio.post(
        'https://vcore.x1.com.my/app/ReceiveFile.ashx',
        data: formData,
        queryParameters: {'id': jobNo},
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Image uploaded successfully: $fileName');
        return {
          'result': true,
          'message': 'Image uploaded successfully',
          'fileName': fileName,
        };
      } else {
        throw Exception(
          'Failed to upload image. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Upload failed with error: ${e.message}');

      // Check if offline
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        debugPrint(
          '📋 No internet connection - queueing upload for later sync',
        );

        try {
          // Read the file and convert to base64 for offline queuing
          final file = File(filePath);
          if (!await file.exists()) {
            throw Exception('File not found: $filePath');
          }

          final imageBytes = await file.readAsBytes();
          final base64Data = base64Encode(imageBytes);

          debugPrint(
            '📋 File converted to base64 (${imageBytes.length} bytes)',
          );

          // Queue the upload with base64 data (required format for offline queue manager)
          await OfflineStorageService.queueOfflineRequest(
            method: 'POST',
            url: 'https://vcore.x1.com.my/app/ReceiveFile.ashx',
            data: {
              'base64Data': base64Data,
              'filename': fileName,
              'jobNo': jobNo,
            },
            queryParameters: {'id': jobNo},
            optimisticData: {
              'result': true,
              'message': 'Upload queued - will sync when online',
              'fileName': fileName,
              'queued': true,
            },
            cacheKey: 'job_image_upload:$jobNo:$fileName',
          );

          debugPrint('✅ Image queued for sync: $fileName');

          return {
            'result': true,
            'message': 'Image upload queued - will sync when online',
            'fileName': fileName,
            'queued': true,
          };
        } catch (queueError) {
          debugPrint('❌ Error queueing image for sync: $queueError');
          return {
            'result': false,
            'message': 'Failed to queue image: $queueError',
            'error': queueError.toString(),
          };
        }
      }

      return {
        'result': false,
        'message': 'Failed to upload image: ${e.message}',
        'error': e.message,
      };
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return {
        'result': false,
        'message': 'Upload failed: $e',
        'error': e.toString(),
      };
    }
  }
}
