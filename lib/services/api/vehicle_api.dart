import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/services/dio/dio_repo.dart';
import '../../models/vehicle_model.dart';
import '../../models/trailer_search_model.dart';
import '../../models/yard_model.dart';
import '../../models/return_value_model.dart';
import '../../models/rest_value_model.dart';

/// Vehicle API Service
/// Handles all vehicle-related API calls
class VehicleApi {
  final Dio _dio = DioRepo().mDio;

  /// Get vehicles endpoint
  /// POST /GetVehicles
  ///
  /// Request:
  /// {
  ///   "driverId": "DRIV000004",
  ///   "TenantId": 2010
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
  Future<List<Vehicle>> getVehicles({
    required String driverId,
    required String tenantId,
  }) async {
    try {
      final response = await _dio.post(
        '/GetVehicles',
        data: {'driverId': driverId, 'TenantId': tenantId},
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

  /// Get default/assigned vehicle for driver
  /// POST /GetVehicleQRDefaultPM
  ///
  /// Request:
  /// {
  ///   "DriverID": "40",
  ///   "TenantId": "2010"
  /// }
  ///
  /// Response: Wrapped in "d" property
  /// {
  ///   "d": [
  ///     {
  ///       "ID": "47",
  ///       "NO": "BAR9224",
  ///       "Status": "1",
  ///       "MDTUID": "0"
  ///     }
  ///   ]
  /// }
  Future<Vehicle?> getDefaultVehicle({
    required String driverId,
    required String tenantId,
  }) async {
    try {
      final response = await _dio.post(
        '/GetVehicleQRDefaultPM',
        data: {'DriverID': driverId, 'TenantId': tenantId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'];

        if (data is List && data.isNotEmpty) {
          return Vehicle.fromJson(data[0] as Map<String, dynamic>);
        }

        // Return null if no default vehicle assigned
        return null;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('GetDefaultVehicle API Error: ${e.message}');
      // Return null instead of rethrowing to gracefully handle no default vehicle
      return null;
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
    required String tenantId,
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

  /// Get RTB Yards (Return to Base Yards)
  /// POST /RTBYard
  ///
  /// Request:
  /// {
  ///   "Name": "",
  ///   "TenantId": "2010"
  /// }
  ///
  /// Response: Wrapped in "d" property
  /// {
  ///   "d": [
  ///     {
  ///       "YardID": "147",
  ///       "YardName": "STG_YARD_WP (STAGING YARD(WESTPORT) SDN BHD)",
  ///       "Result": true,
  ///       "Error": ""
  ///     }
  ///   ]
  /// }
  Future<List<YardModel>> getRTBYards({
    required String tenantId,
    String name = '',
  }) async {
    try {
      final response = await _dio.post(
        '/RTBYard',
        data: {'Name': name, 'TenantId': tenantId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['d'];

        if (data is List) {
          return (data)
              .map((item) => YardModel.fromJson(item as Map<String, dynamic>))
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
      debugPrint('Get RTB Yards API Error: ${e.message}');
      rethrow;
    }
  }

  /// Get Return Value (Check return state)
  /// POST /GetReturnValue
  ///
  /// Request:
  /// {
  ///   "driverId": "40",
  ///   "pmid": "47",
  ///   "trailer": "",
  ///   "ReturnTo": "0",
  ///   "remark": "",
  ///   "TenantId": "2010"
  /// }
  ///
  /// Response:
  /// {
  ///   "Result": false,
  ///   "status": "",
  ///   "Id": "",
  ///   "DriverName": "MUHAMMAD HAKIMIE",
  ///   ...
  /// }
  ///
  /// States:
  /// - Result=false: Request Return state
  /// - Result=true, status="0": Start Return state
  /// - Result=true, status="1": End Return state
  Future<ReturnValueModel> getReturnValue({
    required String driverId,
    required String pmid,
    required String tenantId,
    String trailer = '',
    String returnTo = '0',
    String remark = '',
  }) async {
    try {
      final response = await _dio.post(
        '/GetReturnValue',
        data: {
          'driverId': driverId,
          'pmid': pmid,
          'trailer': trailer,
          'ReturnTo': returnTo,
          'remark': remark,
          'TenantId': tenantId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Response is directly the data object, not wrapped in 'd'
        return ReturnValueModel.fromJson(
          response.data['d'] as Map<String, dynamic>,
        );
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Get Return Value API Error: ${e.message}');
      rethrow;
    }
  }

  /// Request Return to Base (RTB)
  /// POST /RTBByDriver
  ///
  /// Request:
  /// {
  ///   "driverId": "40",
  ///   "pmid": "47",
  ///   "trailer": "30",
  ///   "ReturnTo": "147",
  ///   "remark": "123",
  ///   "startEndlat": 3.082078442995987,
  ///   "startEndlon": 101.58268594391204,
  ///   "TenantId": "2010"
  /// }
  ///
  /// Response:
  /// {
  ///   "Result": true,
  ///   "Error": null,
  ///   "Id": "4"
  /// }
  Future<Map<String, dynamic>> requestRTB({
    required String driverId,
    required String pmid,
    required String trailer,
    required String returnTo,
    required String tenantId,
    String remark = '',
    double startEndlat = 0.0,
    double startEndlon = 0.0,
  }) async {
    try {
      final response = await _dio.post(
        '/RTBByDriver',
        data: {
          'driverId': driverId,
          'pmid': pmid,
          'trailer': trailer,
          'ReturnTo': returnTo,
          'remark': remark,
          'startEndlat': startEndlat,
          'startEndlon': startEndlon,
          'TenantId': tenantId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Request RTB API Error: ${e.message}');
      rethrow;
    }
  }

  /// Update RTB Start
  /// POST /UpdateRTBStart
  ///
  /// Request:
  /// {
  ///   "RTBRequestNo": "4",
  ///   "startEndlat": "3.0819658548237308",
  ///   "startEndlon": "101.58286390651938",
  ///   "DriverId": "40"
  /// }
  ///
  /// Response:
  /// {
  ///   "Result": true,
  ///   "Error": null
  /// }
  Future<Map<String, dynamic>> updateRTBStart({
    required String rtbRequestNo,
    required String driverId,
    String startEndlat = '0.0',
    String startEndlon = '0.0',
  }) async {
    try {
      final response = await _dio.post(
        '/UpdateRTBStart',
        data: {
          'RTBRequestNo': rtbRequestNo,
          'startEndlat': startEndlat,
          'startEndlon': startEndlon,
          'DriverId': driverId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Update RTB Start API Error: ${e.message}');
      rethrow;
    }
  }

  /// Update RTB End
  /// POST /UpdateRTBEnd
  ///
  /// Request:
  /// {
  ///   "RTBRequestNo": "4",
  ///   "startEndlat": "3.0819658548237308",
  ///   "startEndlon": "101.58286390651938",
  ///   "DriverId": "40"
  /// }
  ///
  /// Response:
  /// {
  ///   "Result": true,
  ///   "Error": null
  /// }
  Future<Map<String, dynamic>> updateRTBEnd({
    required String rtbRequestNo,
    required String driverId,
    String startEndlat = '0.0',
    String startEndlon = '0.0',
  }) async {
    try {
      final response = await _dio.post(
        '/UpdateRTBEnd',
        data: {
          'RTBRequestNo': rtbRequestNo,
          'startEndlat': startEndlat,
          'startEndlon': startEndlon,
          'DriverId': driverId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Update RTB End API Error: ${e.message}');
      rethrow;
    }
  }

  /// Get Rest Value (Check rest state)
  /// POST /GetRestValue
  ///
  /// Request:
  /// {
  ///   "driverId": "40",
  ///   "pmid": "47",
  ///   "trailer": "",
  ///   "remark": "",
  ///   "TenantId": "2010"
  /// }
  ///
  /// Response:
  /// {
  ///   "Result": false,
  ///   "status": "",
  ///   "Id": "",
  ///   "DriverName": "MUHAMMAD HAKIMIE",
  ///   ...
  /// }
  ///
  /// States:
  /// - Result=false: Request Rest state
  /// - Result=true, status="0": Start Rest state
  /// - Result=true, status="1": End Rest state
  Future<RestValueModel> getRestValue({
    required String driverId,
    required String pmid,
    required String tenantId,
    String trailer = '',
    String remark = '',
  }) async {
    try {
      final response = await _dio.post(
        '/GetRestValue',
        data: {
          'driverId': driverId,
          'pmid': pmid,
          'trailer': trailer,
          'remark': remark,
          'TenantId': tenantId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Response is directly the data object, not wrapped in 'd'
        return RestValueModel.fromJson(
          response.data['d'] as Map<String, dynamic>,
        );
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Get Rest Value API Error: ${e.message}');
      rethrow;
    }
  }

  /// Request Rest
  /// POST /RESTByDriver
  ///
  /// Request:
  /// {
  ///   "driverId": "40",
  ///   "pmid": "47",
  ///   "trailer": "30",
  ///   "remark": "123",
  ///   "startEndlat": 3.082078442995987,
  ///   "startEndlon": 101.58268594391204,
  ///   "TenantId": "2010"
  /// }
  ///
  /// Response:
  /// {
  ///   "Result": true,
  ///   "Error": null,
  ///   "Id": "4"
  /// }
  Future<Map<String, dynamic>> requestRest({
    required String driverId,
    required String pmid,
    required String trailer,
    required String tenantId,
    String remark = '',
    double startEndlat = 0.0,
    double startEndlon = 0.0,
  }) async {
    try {
      final response = await _dio.post(
        '/RESTByDriver',
        data: {
          'driverId': driverId,
          'pmid': pmid,
          'trailer': trailer,
          'remark': remark,
          'startEndlat': startEndlat,
          'startEndlon': startEndlon,
          'TenantId': tenantId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Request Rest API Error: ${e.message}');
      rethrow;
    }
  }

  /// Update Rest Start
  /// POST /UpdateRestStart
  ///
  /// Request:
  /// {
  ///   "RestRequestNo": "4",
  ///   "startEndlat": "3.0819658548237308",
  ///   "startEndlon": "101.58286390651938",
  ///   "DriverId": "40"
  /// }
  ///
  /// Response:
  /// {
  ///   "Result": true,
  ///   "Error": null
  /// }
  Future<Map<String, dynamic>> updateRestStart({
    required String restRequestNo,
    required String driverId,
    String startEndlat = '0.0',
    String startEndlon = '0.0',
  }) async {
    try {
      final response = await _dio.post(
        '/UpdateRestStart',
        data: {
          'RESTRequestNo': restRequestNo,
          'startEndlat': startEndlat,
          'startEndlon': startEndlon,
          'DriverId': driverId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['d'] as Map<String, dynamic>;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Update Rest Start API Error: ${e.message}');
      rethrow;
    }
  }

  /// Update Rest End
  /// POST /UpdateRestEnd
  ///
  /// Request:
  /// {
  ///   "RestRequestNo": "4",
  ///   "startEndlat": "3.0819658548237308",
  ///   "startEndlon": "101.58286390651938",
  ///   "DriverId": "40"
  /// }
  ///
  /// Response:
  /// {
  ///   "Result": true,
  ///   "Error": null
  /// }
  Future<Map<String, dynamic>> updateRestEnd({
    required String restRequestNo,
    required String driverId,
    String startEndlat = '0.0',
    String startEndlon = '0.0',
  }) async {
    try {
      final response = await _dio.post(
        '/UpdateRestEnd',
        data: {
          'RESTrRequestNo': restRequestNo,
          'startEndlat': startEndlat,
          'startEndlon': startEndlon,
          'DriverId': driverId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data["d"] as Map<String, dynamic>;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Unexpected response format',
        response: response,
      );
    } on DioException catch (e) {
      debugPrint('Update Rest End API Error: ${e.message}');
      rethrow;
    }
  }
}
