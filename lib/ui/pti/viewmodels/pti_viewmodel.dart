import 'package:flutter/foundation.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:vcore_v5_app/domain/repositories/pti_repository.dart';
import 'package:vcore_v5_app/models/pti_check_item_model.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';
import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// State class for PTI feature
class PTIState {
  final List<PTICheckItem> ptiChecks;
  final bool isLoading;
  final bool isSubmitting;
  final bool isOnline;
  final SyncStatus syncStatus;
  final String? errorMessage;
  final List<String> failedOperationIds;

  const PTIState({
    this.ptiChecks = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.isOnline = true,
    this.syncStatus = SyncStatus.idle,
    this.errorMessage,
    this.failedOperationIds = const [],
  });

  PTIState copyWith({
    List<PTICheckItem>? ptiChecks,
    bool? isLoading,
    bool? isSubmitting,
    bool? isOnline,
    SyncStatus? syncStatus,
    String? errorMessage,
    List<String>? failedOperationIds,
  }) {
    return PTIState(
      ptiChecks: ptiChecks ?? this.ptiChecks,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isOnline: isOnline ?? this.isOnline,
      syncStatus: syncStatus ?? this.syncStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      failedOperationIds: failedOperationIds ?? this.failedOperationIds,
    );
  }

  bool get hasChecks => ptiChecks.isNotEmpty;
  int get checkCount => ptiChecks.length;
  bool get hasOfflineOperations => failedOperationIds.isNotEmpty;
}

/// ViewModel for PTI feature
class PTIViewModel extends StateNotifier<PTIState> {
  final PTIRepository _ptiRepository;
  final ConnectivityService _connectivityService;

  PTIViewModel({
    required PTIRepository ptiRepository,
    required ConnectivityService connectivityService,
  }) : _ptiRepository = ptiRepository,
       _connectivityService = connectivityService,
       super(const PTIState()) {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivityService.addListener(() {
      final isOnline = _connectivityService.isOnline;
      state = state.copyWith(isOnline: isOnline);

      if (isOnline) {
        debugPrint('🔄 Online - refreshing PTI data');
        // Could trigger auto-refresh here if needed
      }
    });
  }

  /// Load PTI checks
  Future<void> loadPTIChecks({
    required String driverId,
    required String tenantId,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _ptiRepository.getPTIChecks(
        driverId: driverId,
        tenantId: tenantId,
      );

      if (result.isSuccess && result.getDataOrNull() != null) {
        state = state.copyWith(
          ptiChecks: result.getDataOrNull()!,
          isLoading: false,
          errorMessage: null,
        );
        debugPrint('✅ Loaded ${result.getDataOrNull()!.length} PTI checks');
      } else if (result.isOffline) {
        final cachedChecks = result.getDataOrNull() ?? [];
        state = state.copyWith(
          ptiChecks: cachedChecks,
          isLoading: false,
          isOnline: false,
          errorMessage: 'Using cached PTI data',
        );
        debugPrint('📴 Using cached PTI checks');
      } else if (result.isError) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load PTI checks',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
      debugPrint('❌ Exception loading PTI checks: $e');
    }
  }

  /// Submit PTI check
  Future<void> submitPTICheck({
    required String driverId,
    required String vehicleId,
    required List<PTICheckItem> items,
    required String tenantId,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final result = await _ptiRepository.submitPTICheck(
        driverId: driverId,
        vehicleId: vehicleId,
        items: items,
        tenantId: tenantId,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isSubmitting: false,
          syncStatus: SyncStatus.success,
          errorMessage: null,
        );
        debugPrint('✅ PTI check submitted successfully');
      } else if (result.isOffline) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Submission queued - will sync when online',
          syncStatus: SyncStatus.idle,
          failedOperationIds: [
            ...state.failedOperationIds,
            'submit_pti_${vehicleId}_${DateTime.now().millisecondsSinceEpoch}',
          ],
        );
        debugPrint('📋 PTI submission queued for sync');
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error: ${e.toString()}',
        syncStatus: SyncStatus.failure,
      );
      debugPrint('❌ Exception submitting PTI: $e');
    }
  }

  void dispose() {
    _connectivityService.removeListener(() {});
  }
}
