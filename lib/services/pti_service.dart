import 'package:dio/dio.dart';
import 'api/pti_api.dart';
import '../models/pti_check_item_model.dart';

class PTICheckResponse {
  final bool isDoneForDay;
  final Map<String, List<PTICheckItem>> items;

  PTICheckResponse({required this.isDoneForDay, required this.items});
}

class PTIService {
  final PTIApi _ptiApi = PTIApi();

  /// Get PTI check items with completion status
  /// Returns both the completion status and grouped items by category
  /// isDoneForDay: true if PTI already completed for the day, false otherwise
  Future<PTICheckResponse> getPTICheckItemsByCategoryWithStatus({
    required String vehicleId,
    required String driverId,
  }) async {
    try {
      final response = await _ptiApi.getPTICheckItems(
        pmid: vehicleId,
        driverId: driverId,
      );

      // Group items by category
      final grouped = <String, List<PTICheckItem>>{};
      for (final item in response.items) {
        if (!grouped.containsKey(item.category)) {
          grouped[item.category] = [];
        }
        grouped[item.category]!.add(item);
      }

      return PTICheckResponse(isDoneForDay: response.status, items: grouped);
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch PTI check items');
    }
  }

  /// Save PTI data
  /// Formats the selected values into semicolon-separated string and submits to API
  /// Format: "Category,SubCategory,Type,SelectedValue;..."
  Future<bool> savePTIData({
    required String vehicleId,
    required String driverId,
    required Map<String, String> selectedValues,
    required Map<String, List<PTICheckItem>> categoryItems,
  }) async {
    try {
      // Build the data string
      final List<String> dataItems = [];

      for (final entry in selectedValues.entries) {
        final key = entry.key; // "Category|SubCategory"
        final value = entry.value; // "Good", "Average", "Poor"

        final parts = key.split('|');
        if (parts.length == 2) {
          final category = parts[0];
          final subCategory = parts[1];

          // Find the item type
          int itemType = 1;
          for (final items in categoryItems.values) {
            for (final item in items) {
              if (item.category == category &&
                  item.subCategory == subCategory) {
                itemType = item.type;
                break;
              }
            }
          }

          // Format: "Category,SubCategory,Type,SelectedValue"
          dataItems.add('$category,$subCategory,$itemType,$value');
        }
      }

      // Join all items with semicolon
      var dataString = dataItems.join(';');
      dataString = "$dataString;";

      return await _ptiApi.savePTIData(
        pmid: vehicleId,
        driverId: driverId,
        data: dataString,
      );
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to save PTI data');
    }
  }
}
