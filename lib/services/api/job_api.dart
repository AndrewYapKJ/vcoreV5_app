import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/services/dio/dio_repo.dart';
import '../../models/job_model.dart';
import '../../models/uploaded_file_model.dart';

/// Job API Service
/// Handles all job-related API calls
class JobApi {
  final Dio _dio = DioRepo().mDio;

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
    try {
      final response = await _dio.post(
        '/GetJobswithdriver',
        data: {
          'driverId': driverId,
          'Status': status,
          'PM': pm,
          'SiteType': siteType,
          'TenantId': tenantId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'] as List?;
        if (data != null) {
          return data.map((json) => Job.fromJson(json)).toList();
        }
        return [];
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('GetJobsWithDriver API Error: ${e.message}');
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
    try {
      final response = await _dio.post(
        '/Z_GetJobListToday',
        data: {
          'driverId': driverId,
          'PM': pm,
          'SiteType': siteType,
          'TenantId': tenantId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'] as List?;
        if (data != null) {
          return data.map((json) => Job.fromJson(json)).toList();
        }
        return [];
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('GetJobListToday API Error: ${e.message}');
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
    try {
      final response = await _dio.post(
        '/UpdateJob',
        data: {
          'jobid': jobId,
          'driverid': driverId,
          'mdtcode': mdtCode,
          'lat': lat,
          'lon': lon,
          // 'job_laststatus_date_time': jobLastStatusDateTime,
          'TenantId': tenantId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'];
        if (data != null) {
          return {'result': data['Result'] ?? false, 'error': data['Error']};
        }
        return {'result': false, 'error': 'Unexpected response format'};
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('UpdateJob_withDTime API Error: ${e.response}');
      rethrow;
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
    try {
      final response = await _dio.post('/GetJobImages', data: {'JobNo': jobNo});

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'] as List?;
        if (data != null) {
          return data.map((json) => UploadedFile.fromJson(json)).toList();
        }
        return [];
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('GetJobImages API Error: ${e.message}');
      rethrow;
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
    try {
      final response = await _dio.post(
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
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = response.data['d'] as Map<String, dynamic>? ?? {};
        debugPrint('✅ UpdateJobDetails Success: $result');
        return result;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('❌ UpdateJobDetails API Error: ${e.response}');
      // Return error response for proper handling
      return {
        'result': false,
        'message':
            e.response?.data?['d']?['message'] ??
            e.message ??
            'Error updating job details',
        'error': e.response?.data?['d']?['error'],
      };
    }
  }
}
