import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:vcore_v5_app/domain/repositories/job_repository.dart';
import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';
import 'package:vcore_v5_app/providers/repository_providers.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';
import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';
import 'package:vcore_v5_app/ui/job/states/job_states.dart';

/// ViewModel for Job List feature
/// Handles all business logic and state management for job list view
/// Automatically manages offline/online transitions
class JobListViewModel extends StateNotifier<JobListState> {
  final JobRepository _jobRepository;
  final ConnectivityService _connectivityService;

  JobListViewModel({
    required JobRepository jobRepository,
    required ConnectivityService connectivityService,
  }) : _jobRepository = jobRepository,
       _connectivityService = connectivityService,
       super(JobListState.initial()) {
    _initialize();
  }

  /// Initialize ViewModel
  /// - Load initial state from cache
  /// - Set up listeners for connectivity changes
  Future<void> _initialize() async {
    _setupConnectivityListener();
    await _loadUserSession();
    await loadJobs();
  }

  /// Setup listener for connectivity changes
  void _setupConnectivityListener() {
    _connectivityService.addListener(() {
      final isOnline = _connectivityService.isOnline;
      state = state.copyWith(
        isOnline: isOnline,
        syncStatus: isOnline ? SyncStatus.syncing : SyncStatus.idle,
      );

      if (isOnline) {
        // Refresh data when coming back online
        debugPrint('🔄 Online - refreshing job list');
        loadJobs();
      } else {
        debugPrint('📴 Offline - using cached data');
      }
    });
  }

  /// Load user session data from cache
  /// Sets driverId, tenantId, vehicleId for API calls
  Future<void> _loadUserSession() async {
    try {
      final driverId = LoginCacheService().getCachedDriverId();
      final tenantId = LoginCacheService().getCachedTenantId();
      final vehicleId = LoginCacheService().getCachedVehicleId();

      state = state.copyWith(
        driverId: driverId,
        tenantId: tenantId,
        vehicleId: vehicleId,
      );

      debugPrint('✅ Loaded user session: $driverId, $tenantId, $vehicleId');
    } catch (e) {
      debugPrint('❌ Error loading user session: $e');
    }
  }

  /// Load jobs from repository
  /// Respects current filters (status, siteType)
  /// Returns cached data if offline
  Future<void> loadJobs() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Validate required data
      if (state.driverId == null || state.tenantId == null) {
        await _loadUserSession();
      }

      final result = await _jobRepository.getJobsWithDriver(
        driverId: state.driverId ?? '',
        status: state.currentStatus,
        pm: state.vehicleId ?? '',
        siteType: state.currentSiteType,
        tenantId: state.tenantId ?? '',
      );

      if (result.isSuccess && result.getDataOrNull() != null) {
        state = state.copyWith(
          jobs: result.getDataOrNull()!,
          isLoading: false,
          isOnline: true,
          errorMessage: null,
        );
        debugPrint('✅ Loaded ${result.getDataOrNull()!.length} jobs');
      } else if (result.isOffline) {
        // Show cached data with offline indicator
        final cachedJobs = result.getDataOrNull() ?? [];
        String? offlineMessage;
        if (result is OfflineResult<List<Job>>) {
          offlineMessage = (result as OfflineResult<List<Job>>).message;
        }
        state = state.copyWith(
          jobs: cachedJobs,
          isLoading: false,
          isOnline: false,
          errorMessage: offlineMessage,
        );
        debugPrint('📴 Using cached jobs (${cachedJobs.length} jobs)');
      } else if (result.isError) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load jobs',
        );
        debugPrint('❌ Error loading jobs: ${result.toString()}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error: ${e.toString()}',
      );
      debugPrint('❌ Exception loading jobs: $e');
    }
  }

  /// Refresh jobs (pull-to-refresh)
  Future<void> refreshJobs() async {
    state = state.copyWith(isRefreshing: true);
    try {
      await loadJobs();
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  /// Change job status filter and reload
  Future<void> setStatus(String newStatus) async {
    state = state.copyWith(currentStatus: newStatus);
    await loadJobs();
  }

  /// Change site type filter and reload
  Future<void> setSiteType(String newSiteType) async {
    state = state.copyWith(currentSiteType: newSiteType);
    await loadJobs();
  }

  /// Pre-cache all job lists for offline availability
  Future<void> preCacheAllJobs() async {
    debugPrint('🔄 Starting job pre-cache...');

    for (final siteType in ['HMS', 'TMS']) {
      for (final status in ['pending', 'in-progress', 'completed']) {
        try {
          await _jobRepository.getJobsWithDriver(
            driverId: state.driverId ?? '',
            status: status,
            pm: state.vehicleId ?? '',
            siteType: siteType,
            tenantId: state.tenantId ?? '',
          );
          debugPrint('✅ Pre-cached: $siteType $status');
        } catch (e) {
          debugPrint('⚠️ Failed to pre-cache $siteType $status: $e');
        }
      }
    }

    debugPrint('✅ Job pre-caching complete');
  }

  /// Clear all cached jobs
  Future<void> clearCache() async {
    await _jobRepository.clearCache();
    state = state.copyWith(jobs: [], errorMessage: null);
    debugPrint('✅ Cache cleared');
  }

  /// Dispose resources
  void dispose() {
    _connectivityService.removeListener(() {});
  }
}
