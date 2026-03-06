import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/services/dio/dio_repo.dart';
import '../../models/mdt_functions_model.dart';

/// Response model for request job
class RequestJobResponse {
  final bool success;
  final String? message;
  final String? jobId;

  RequestJobResponse({required this.success, this.message, this.jobId});

  factory RequestJobResponse.fromJson(Map<String, dynamic> json) {
    return RequestJobResponse(
      success: json['d'] != null,
      message: json['message'],
      jobId: json['jobId'],
    );
  }
}

/// Jobs/Activities API Service
/// Handles job and activity-related API calls
class JobsApi {
  final Dio _dio = DioRepo().mDio;

  /// Fetch available MDT Functions (Job Activities)
  /// POST /MDTFunctions
  ///
  /// Request:
  /// {
  ///   "TenantId": "2010"
  /// }
  ///
  /// Response: List of available MDT functions wrapped in "d" property
  Future<MDTFunctionsResponse> getMDTFunctions({
    required String tenantId,
  }) async {
    try {
      final response = await _dio.post(
        '/MDTFunctions',
        data: {'TenantId': tenantId},
      );

      if (response.statusCode == 200 && response.data != null) {
        return MDTFunctionsResponse.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Get MDT Functions API Error: ${e.message}');
      rethrow;
    }
  }

  /// Request a job for driver
  /// POST /RequesForJObByDriver
  ///
  /// Request:
  /// {
  ///   "DriverID": "DRIV000004",
  ///   "pmid": "47",
  ///   "DELCOL": "DEL",
  ///   "lat": 0.0,
  ///   "lon": 0.0,
  ///   "ContainerNo": "ABCD123456",
  ///   "ContainerSize": "40",
  ///   "TrailerID": "TBE3868"
  /// }
  ///
  /// Response: Wrapped in "d" property
  Future<RequestJobResponse> requestJob({
    required String driverId,
    required String pmid,
    required String delCol, // DEL or COL
    required String containerNo,
    required String containerSize,
    required String trailerId,
    double lat = 0.0,
    double lon = 0.0,
  }) async {
    try {
      final response = await _dio.post(
        '/RequesForJObByDriver',
        data: {
          'DriverID': driverId,
          'pmid': pmid,
          'DELCOL': delCol,
          'lat': lat,
          'lon': lon,
          'ContainerNo': containerNo,
          'ContainerSize': containerSize,
          'TrailerID': trailerId,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Request job successful: $response.data');
        return RequestJobResponse.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Request Job API Error: ${e.message}');
      rethrow;
    }
  }
}
