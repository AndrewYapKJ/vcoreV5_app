import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// Model for vehicle data
class Vehicle {
  final String id;
  final String regNo;
  final String make;
  final String model;
  final String year;
  final String? currentLocation;

  Vehicle({
    required this.id,
    required this.regNo,
    required this.make,
    required this.model,
    required this.year,
    this.currentLocation,
  });
}

/// Repository interface for Vehicle operations
abstract class VehicleRepository {
  /// Get all vehicles for a driver
  Future<ApiResult<List<Vehicle>>> getVehicles({
    required String driverId,
    required String tenantId,
  });

  /// Get a specific vehicle by ID
  Future<ApiResult<Vehicle>> getVehicleById({
    required String vehicleId,
    required String tenantId,
  });

  /// Search vehicles by registration number
  Future<ApiResult<List<Vehicle>>> searchVehicles({
    required String searchQuery,
    required String tenantId,
  });

  /// Update vehicle location/status
  Future<ApiResult<void>> updateVehicleLocation({
    required String vehicleId,
    required String latitude,
    required String longitude,
    required String tenantId,
  });

  /// Clear vehicle cache
  Future<void> clearCache();

  /// Get cache status
  Future<ApiResult<Map<String, dynamic>>> getCacheStatus();
}
