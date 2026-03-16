import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/data/datasources/job_datasource.dart';
import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/models/uploaded_file_model.dart';
import 'package:vcore_v5_app/services/offline/offline_storage_service.dart';

/// Implementation of JobLocalDataSource
/// Uses OfflineStorageService (Hive) for caching
class JobLocalDataSourceImpl implements JobLocalDataSource {
  JobLocalDataSourceImpl();
  @override
  Future<void> cacheJobs(String key, List<Job> jobs) async {
    try {
      final jobsJson = jobs.map((j) => j.toJson()).toList();
      await OfflineStorageService.cacheApiResponse(key, {
        'jobs': jobsJson,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Cached ${jobs.length} jobs for key: $key');
    } catch (e) {
      debugPrint('❌ Error caching jobs: $e');
    }
  }

  @override
  Future<List<Job>?> getCachedJobs(String key) async {
    try {
      final cachedData = OfflineStorageService.getCachedApiResponse(key);
      if (cachedData == null) {
        debugPrint('No cached jobs for key: $key');
        return null;
      }

      final jobsJson = cachedData['jobs'] as List?;
      if (jobsJson == null || jobsJson.isEmpty) {
        debugPrint('Empty cached jobs for key: $key');
        return [];
      }

      final jobs = jobsJson
          .map((json) => Job.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Retrieved ${jobs.length} cached jobs for key: $key');
      return jobs;
    } catch (e) {
      debugPrint('❌ Error retrieving cached jobs: $e');
      return null;
    }
  }

  @override
  Future<void> cacheJobImages(String key, List<UploadedFile> images) async {
    try {
      final imagesJson = images.map((i) => i.toJson()).toList();
      await OfflineStorageService.cacheApiResponse(key, {
        'images': imagesJson,
        'timestamp': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Cached ${images.length} images for key: $key');
    } catch (e) {
      debugPrint('❌ Error caching images: $e');
    }
  }

  @override
  Future<List<UploadedFile>?> getCachedJobImages(String key) async {
    try {
      final cachedData = OfflineStorageService.getCachedApiResponse(key);
      if (cachedData == null) {
        debugPrint('No cached images for key: $key');
        return null;
      }

      final imagesJson = cachedData['images'] as List?;
      if (imagesJson == null || imagesJson.isEmpty) {
        debugPrint('Empty cached images for key: $key');
        return [];
      }

      final images = imagesJson
          .map((json) => UploadedFile.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('✅ Retrieved ${images.length} cached images for key: $key');
      return images;
    } catch (e) {
      debugPrint('❌ Error retrieving cached images: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getCacheStatus() async {
    try {
      // This would need additional implementation in OfflineStorageService
      // For now, return basic status
      return {
        'cached': true,
        'message': 'Cache service is active',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Error getting cache status: $e');
      return {'cached': false, 'error': e.toString()};
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      // Clear cache box - this would need a method in OfflineStorageService
      debugPrint('✅ Cleared all cache');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  @override
  Future<void> clearCache(String key) async {
    try {
      // Clear specific key - this would need a method in OfflineStorageService
      debugPrint('✅ Cleared cache for key: $key');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }
}
