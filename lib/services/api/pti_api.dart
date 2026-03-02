import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/services/dio/dio_repo.dart';
import '../../models/pti_check_item_model.dart';

/// PTI API Service
/// Handles all PTI-related API calls
class PTIApi {
  final Dio _dio = DioRepo().mDio;

  /// Get PTI Check Items endpoint
  /// POST /GetPTICheckItems
  ///
  /// Request:
  /// {
  ///   "PMID": "47",
  ///   "DriverID": "40"
  /// }
  ///
  /// Response:
  /// {
  ///   "d": {
  ///     "status": true,
  ///     "d": [
  ///       {
  ///         "Category": "BREK",
  ///         "SubCategory": "BREK DAN SISTEM BREK DALAM KEADAAN BAIK",
  ///         "Type": 1
  ///       }
  ///     ]
  ///   }
  /// }
  Future<PTICheckItemsResponse> getPTICheckItems({
    required String pmid,
    required String driverId,
  }) async {
    try {
      final response = await _dio.post(
        '/GetPTICheckItems',
        data: {'PMID': pmid, 'DriverID': driverId},
      );

      if (response.statusCode == 200 && response.data != null) {
        return PTICheckItemsResponse.fromJson(response.data);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('GetPTICheckItems API Error: ${e.message}');
      rethrow;
    }
  }

  /// Save PTI Data endpoint
  /// POST /Save_PTI_Data
  ///
  /// Request:
  /// {
  ///   "PMID": "742",
  ///   "DriverID": "DRIV000317",
  ///   "data": "Category,SubCategory,Type,Value;..."
  /// }
  ///
  /// Response:
  /// {
  ///   "d": {
  ///     "error": "no error",
  ///     "result": true
  ///   }
  /// }
  Future<bool> savePTIData({
    required String pmid,
    required String driverId,
    required String data,
  }) async {
    try {
      final response = await _dio.post(
        '/Save_PTI_Data',
        data: {'PMID': pmid, 'DriverID': driverId, 'data': data},
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = response.data['d'];
        if (result != null && result['result'] == true) {
          return true;
        }
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Failed to save PTI data',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Save PTI Data API Error: ${e.message}');
      rethrow;
    }
  }
}
