import 'package:dio/dio.dart';
import 'api/vehicle_api.dart';
import '../models/vehicle_model.dart';
import 'storage/login_cache_service.dart';

class VehicleService {
  final VehicleApi _vehicleApi = VehicleApi();
  final LoginCacheService _cacheService = LoginCacheService();

  /// Get vehicles for a specific driver
  /// Returns a list of vehicles
  Future<List<Vehicle>> getVehicles({required String driverId}) async {
    try {
      final vehicles = await _vehicleApi.getVehicles(driverId: driverId);
      return vehicles;
    } on DioException catch (e) {
      // Return empty list on error
      // Error handling will be managed at the UI level
      throw Exception(e.message ?? 'Failed to fetch vehicles');
    }
  }

  /// Cache selected vehicle data
  /// Called when user selects a vehicle
  Future<void> cacheSelectedVehicle({
    required String vehicleId,
    required String vehicleName,
    required String plateNumber,
  }) async {
    try {
      await _cacheService.cacheVehicleSelection(
        vehicleId: vehicleId,
        vehicleName: vehicleName,
        plateNumber: plateNumber,
      );
    } catch (e) {
      throw Exception('Failed to cache vehicle selection: $e');
    }
  }

  /// Get last selected vehicle from cache
  Map<String, dynamic>? getLastSelectedVehicle() {
    try {
      return _cacheService.getCachedVehicleSelection();
    } catch (e) {
      return null;
    }
  }
}
