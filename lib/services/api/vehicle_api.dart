import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/services/dio/dio_repo.dart';
import '../../models/vehicle_model.dart';
import '../../models/trailer_search_model.dart';

/// Vehicle API Service
/// Handles all vehicle-related API calls
class VehicleApi {
  final Dio _dio = DioRepo().mDio;

  /// Get vehicles endpoint
  /// POST /GetVehicles
  ///
  /// Request:
  /// {
  ///   "driverId": "DRIV000004"
  /// }
  ///
  /// Response: Wrapped in "d" property
  /// {
  ///   "d": [
  ///     {
  ///       "ID": "47",
  ///       "NO": "BAR9224",
  ///       "Status": "",
  ///       "MDTUID": "0"
  ///     }
  ///   ]
  /// }
  Future<List<Vehicle>> getVehicles({required String driverId}) async {
    try {
      final response = await _dio.post(
        '/GetVehicles',
        data: {'driverId': driverId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'];

        if (data is List) {
          return (data)
              .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
              .toList();
        }

        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Invalid response format: expected list in "d" property',
          response: response,
        );
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('GetVehicles API Error: ${e.message}');
      rethrow;
    }
  }

  /// Search trailers endpoint
  /// POST /GetTrailerRegNoSearch
  ///
  /// Request:
  /// {
  ///   "TrailerRegNo": "tbe",
  ///   "TrSize": "40",
  ///   "TenantId": 2010
  /// }
  ///
  /// Response: Wrapped in "d" property
  /// {
  ///   "d": [
  ///     {
  ///       "TrailerRegNoDisp": "TBE3868--TBE 3868(Size-40)",
  ///       "TrailerRegNo": "TBE 3868",
  ///       "TrailerID": "TBE3868",
  ///       "TrailerSize": "40",
  ///       "Status": "2",
  ///       "reason": ""
  ///     }
  ///   ]
  /// }
  Future<List<TrailerSearchResult>> searchTrailers({
    required String trailerRegNo,
    required String trSize,
    required int tenantId,
  }) async {
    try {
      final response = await _dio.post(
        '/GetTrailerRegNoSearchQR',
        data: {
          'TrailerRegNo': trailerRegNo,
          'TrSize': trSize,
          'TenantId': tenantId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'];

        if (data is List) {
          return (data)
              .map(
                (item) =>
                    TrailerSearchResult.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }

        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Invalid response format: expected list in "d" property',
          response: response,
        );
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('SearchTrailers API Error: ${e.message}');
      rethrow;
    }
  }
}
