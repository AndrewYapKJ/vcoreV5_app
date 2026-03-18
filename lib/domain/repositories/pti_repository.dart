import 'package:vcore_v5_app/models/pti_check_item_model.dart';
import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// Repository interface for PTI (Pre-Trip Inspection) operations
/// Handles all PTI check submissions and retrievals
abstract class PTIRepository {
  /// Get all PTI checks for a driver
  Future<ApiResult<List<PTICheckItem>>> getPTIChecks({
    required String driverId,
    required String tenantId,
  });

  /// Submit a PTI check
  Future<ApiResult<void>> submitPTICheck({
    required String driverId,
    required String vehicleId,
    required List<PTICheckItem> items,
    required String tenantId,
  });

  /// Get a specific PTI check by ID
  Future<ApiResult<PTICheckItem>> getPTICheckById({
    required String ptiId,
    required String tenantId,
  });

  /// Clear PTI cache
  Future<void> clearCache();

  /// Get cache status
  Future<ApiResult<Map<String, dynamic>>> getCacheStatus();
}
