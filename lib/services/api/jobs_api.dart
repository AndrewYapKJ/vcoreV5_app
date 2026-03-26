import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/services/api_services/api_service.dart';
import 'package:vcore_v5_app/services/offline/offline_storage_service.dart';
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
      message: json['d'] != null ? json['d']['Error'] : null,
      jobId: json['jobId'],
    );
  }
}

/// Jobs/Activities API Service
/// Handles job and activity-related API calls
class JobsApi {
  final ApiService _apiService = ApiService();

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
    const cacheKey = 'mdt_functions_cache';

    try {
      final result = await _apiService.post<MDTFunctionsResponse>(
        '/MDTFunctions',
        data: {'TenantId': tenantId},
        enableOfflineQueue: true,
        fromJson: (data) {
          if (data['d'] == null) {
            throw Exception('Invalid response format: missing d property');
          }
          return MDTFunctionsResponse.fromJson(data);
        },
      );

      if (result.isSuccess && result.data != null) {
        // Cache successful response
        await OfflineStorageService.cacheApiResponse(cacheKey, {
          'mdtFunctions': result.data!.toJson(),
        });
        debugPrint('MDT functions fetched and cached successfully');
        return result.data!;
      } else {
        // Try to use cached data on failure
        final cachedData = OfflineStorageService.getCachedApiResponse(cacheKey);
        if (cachedData != null && cachedData['mdtFunctions'] != null) {
          final cachedResponse = MDTFunctionsResponse.fromJson(
            cachedData['mdtFunctions'] as Map<String, dynamic>,
          );
          debugPrint('Using cached MDT functions due to API failure');
          return cachedResponse;
        }
        throw Exception(result.errorMessage ?? 'Failed to fetch MDT functions');
      }
    } catch (e) {
      debugPrint('Error getting MDT Functions: $e');

      // Try to fall back to cached data on exception
      final cachedData = OfflineStorageService.getCachedApiResponse(cacheKey);
      if (cachedData != null && cachedData['mdtFunctions'] != null) {
        final cachedResponse = MDTFunctionsResponse.fromJson(
          cachedData['mdtFunctions'] as Map<String, dynamic>,
        );
        debugPrint('Using cached MDT functions due to exception');
        return cachedResponse;
      }
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
    final optimisticData = {
      'containerNo': containerNo,
      'containerSize': containerSize,
      'trailerId': trailerId,
      'status': 'requested_offline',
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final result = await _apiService.post<RequestJobResponse>(
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
        optimisticData: optimisticData,
        enableOfflineQueue: true,
        fromJson: (data) {
          // Handle offline optimistic data format
          if (data.containsKey('containerNo') && data.containsKey('status')) {
            return RequestJobResponse(success: true, jobId: containerNo);
          }
          if (data['d'] == null) {
            throw Exception('Invalid response format: missing d property');
          }

          return RequestJobResponse.fromJson(data);
        },
      );

      if (result.isSuccess) {
        debugPrint('✅ Request job successful: ${result.data}');
        return result.data!;
      } else {
        throw Exception(result.errorMessage ?? 'Request job failed');
      }
    } catch (e) {
      debugPrint('Request Job API Error: $e');
      rethrow;
    }
  }
}
