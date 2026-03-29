import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcore_v5_app/models/trailer_search_model.dart';
import 'package:vcore_v5_app/services/api/vehicle_api.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';

/// Manager for trailer search with smart caching
class TrailerSearchManager {
  final VehicleApi _vehicleApi = VehicleApi();
  final List<TrailerSearchResult> _cache = [];
  bool _isInitialized = false;

  /// Initialize cache with full trailer list (called on login)
  Future<void> initializeCache({
    required String tenantId,
    String initialSearch = '',
  }) async {
    if (_isInitialized) {
      debugPrint('✅ Trailer cache already initialized, skipping');
      return;
    }

    try {
      debugPrint('🔄 Initializing trailer cache...');
      final results = await _vehicleApi.searchTrailers(
        trailerRegNo: initialSearch,
        trSize: '',
        tenantId: tenantId,
      );
      _cache.clear();
      _cache.addAll(results);
      _isInitialized = true;
      debugPrint('✅ Trailer cache initialized with ${_cache.length} trailers');
    } catch (e) {
      debugPrint('❌ Error initializing trailer cache: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Search trailers with smart caching logic
  /// 1. First searches in local cache
  /// 2. If not found and online, calls API and adds unique results to cache
  /// 3. If offline, only returns cached results
  /// 4. Avoids duplicates by checking trailer ID
  Future<List<TrailerSearchResult>> searchTrailers({
    required String query,
    required String tenantId,
    String trSize = '',
  }) async {
    try {
      final connectivityService = ConnectivityService();
      final isOnline = connectivityService.isOnline;

      // 1. Search in local cache first
      final cachedResults = _searchInCache(query);

      if (cachedResults.isNotEmpty) {
        debugPrint(
          '✅ Found ${cachedResults.length} trailers in cache for query: "$query"',
        );
        return cachedResults;
      }

      debugPrint('📭 No trailers found in cache for query: "$query"');

      // 2. If offline, return empty (only use cache)
      if (!isOnline) {
        debugPrint(
          '📴 Offline mode: Not calling API, returning cached results only',
        );
        return [];
      }

      // 3. If online and not found in cache, call API
      debugPrint('🔍 Searching API for trailers with query: "$query"');
      final apiResults = await _vehicleApi.searchTrailers(
        trailerRegNo: query,
        trSize: trSize,
        tenantId: tenantId,
      );

      // 4. Add unique results to cache
      int addedCount = 0;
      for (final result in apiResults) {
        if (!_isDuplicate(result)) {
          _cache.add(result);
          addedCount++;
        }
      }

      debugPrint(
        '💾 Added $addedCount new trailers to cache (API returned ${apiResults.length} total)',
      );

      return apiResults;
    } catch (e) {
      debugPrint('❌ Error searching trailers: $e');
      // On error, return cached results instead of failing
      return _searchInCache(query);
    }
  }

  /// Search within cached trailers by registration number
  List<TrailerSearchResult> _searchInCache(String query) {
    if (query.isEmpty) {
      return _cache;
    }

    final lowerQuery = query.toLowerCase();
    return _cache
        .where(
          (trailer) =>
              trailer.trailerRegNo.toLowerCase().contains(lowerQuery) ||
              trailer.trailerRegNoDisp.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Check if trailer already exists in cache by ID
  bool _isDuplicate(TrailerSearchResult trailer) {
    return _cache.any((cached) => cached.trailerID == trailer.trailerID);
  }

  /// Get all cached trailers
  List<TrailerSearchResult> getCachedTrailers() {
    return List.unmodifiable(_cache);
  }

  /// Get cache size
  int getCacheSize() {
    return _cache.length;
  }

  /// Clear cache (called on logout)
  Future<void> clearCache() async {
    _cache.clear();
    _isInitialized = false;
    debugPrint('🧹 Trailer cache cleared');
  }

  /// Reset initialization flag (useful for testing)
  void resetInitialization() {
    _isInitialized = false;
  }
}

/// Single instance of trailer search manager
final trailerSearchManager = TrailerSearchManager();

/// Riverpod provider for trailer search
final trailerSearchProvider =
    FutureProvider.family<
      List<TrailerSearchResult>,
      ({String query, String tenantId, String trSize})
    >((ref, params) async {
      return trailerSearchManager.searchTrailers(
        query: params.query,
        tenantId: params.tenantId,
        trSize: params.trSize,
      );
    });

/// Provider to initialize trailer cache (called on login)
final trailerCacheInitProvider = FutureProvider.family<void, String>((
  ref,
  tenantId,
) async {
  debugPrint('📱 Initializing trailer cache from login provider...');
  await trailerSearchManager.initializeCache(tenantId: tenantId);
});

/// Provider to get cached trailer list
final cachedTrailersProvider = Provider<List<TrailerSearchResult>>((ref) {
  return trailerSearchManager.getCachedTrailers();
});
