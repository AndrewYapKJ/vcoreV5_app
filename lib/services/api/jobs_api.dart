import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/services/dio/dio_repo.dart';
import '../../models/mdt_functions_model.dart';

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
}
