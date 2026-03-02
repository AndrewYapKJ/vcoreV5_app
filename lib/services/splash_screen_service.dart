import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/mdt_functions_model.dart';
import './local_storage_service.dart';
import './api/jobs_api.dart';

class SplashScreenService {
  final _storage = LocalStorageService();
  final _jobsApi = JobsApi();

  /// Check for active session and refetch MDT Functions
  /// Returns true if session exists and MDT Functions were refreshed
  Future<bool> checkSessionAndRefetchMDT() async {
    try {
      // Check if user has an active session
      final hasSession = await _storage.hasActiveSession();

      if (!hasSession) {
        debugPrint('No active session found');
        return false;
      }

      debugPrint('Active session detected, refetching MDT Functions...');

      // Get tenant ID
      final tenantId = await _storage.getSavedTenantId();
      if (tenantId == null) {
        debugPrint('Tenant ID not found');
        return false;
      }

      // Refetch MDT Functions from API
      final mdtResponse = await _jobsApi.getMDTFunctions(tenantId: tenantId);

      if (mdtResponse.isSuccess) {
        // Save to local storage
        final mdtJson = jsonEncode(
          mdtResponse.functions.map((f) => f.toJson()).toList(),
        );
        await _storage.saveMDTFunctions(mdtJson);
        debugPrint('MDT Functions refreshed and saved successfully');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking session and refetching MDT: $e');
      return false;
    }
  }

  /// Load cached MDT Functions from local storage
  Future<List<MDTFunction>?> loadCachedMDTFunctions() async {
    try {
      final mdtJson = await _storage.getSavedMDTFunctions();
      if (mdtJson == null || mdtJson.isEmpty) {
        return null;
      }

      final List<dynamic> decoded = jsonDecode(mdtJson);
      final functions = decoded
          .map((item) => MDTFunction.fromJson(item as Map<String, dynamic>))
          .toList();

      return functions;
    } catch (e) {
      debugPrint('Error loading cached MDT Functions: $e');
      return null;
    }
  }

  /// Get driver ID from cache
  Future<String?> getCachedDriverId() async {
    return _storage.getSavedDriverId();
  }

  /// Get tenant ID from cache
  Future<String?> getCachedTenantId() async {
    return _storage.getSavedTenantId();
  }
}
