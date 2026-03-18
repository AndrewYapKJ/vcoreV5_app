import 'package:flutter/foundation.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:vcore_v5_app/domain/repositories/vehicle_repository.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';
import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// State class for Vehicle feature
class VehicleState {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final List<Vehicle> searchResults;
  final bool isLoading;
  final bool isSearching;
  final bool isOnline;
  final SyncStatus syncStatus;
  final String? errorMessage;

  const VehicleState({
    this.vehicles = const [],
    this.selectedVehicle,
    this.searchResults = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.isOnline = true,
    this.syncStatus = SyncStatus.idle,
    this.errorMessage,
  });

  VehicleState copyWith({
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    List<Vehicle>? searchResults,
    bool? isLoading,
    bool? isSearching,
    bool? isOnline,
    SyncStatus? syncStatus,
    String? errorMessage,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      isOnline: isOnline ?? this.isOnline,
      syncStatus: syncStatus ?? this.syncStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasVehicles => vehicles.isNotEmpty;
  int get vehicleCount => vehicles.length;
}

/// ViewModel for Vehicle feature
class VehicleViewModel extends StateNotifier<VehicleState> {
  final VehicleRepository _vehicleRepository;
  final ConnectivityService _connectivityService;
  final LoginCacheService _cacheService = LoginCacheService();

  VehicleViewModel({
    required VehicleRepository vehicleRepository,
    required ConnectivityService connectivityService,
  }) : _vehicleRepository = vehicleRepository,
       _connectivityService = connectivityService,
       super(const VehicleState()) {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivityService.addListener(() {
      final isOnline = _connectivityService.isOnline;
      state = state.copyWith(isOnline: isOnline);
    });
  }

  /// Load all vehicles
  Future<void> loadVehicles({
    required String driverId,
    required String tenantId,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: Implement vehicle loading from repository
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Vehicle loading not yet implemented',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  /// Search vehicles
  Future<void> searchVehicles(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    state = state.copyWith(isSearching: true);

    try {
      // TODO: Implement vehicle search from repository
      state = state.copyWith(
        isSearching: false,
        errorMessage: 'Vehicle search not yet implemented',
      );
    } catch (e) {
      debugPrint('❌ Search error: $e');
      state = state.copyWith(
        isSearching: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  /// Load assigned vehicle for today
  /// First checks cache, then tries API if online
  /// Falls back to cached/last-used vehicle if offline
  Future<void> loadAssignedVehicleForToday({
    required String driverId,
    required String tenantId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // First check if we have a cached assigned vehicle for today
      final cachedVehicle = await _cacheService.getTodayAssignedVehicle();
      if (cachedVehicle != null) {
        debugPrint('✅ Using cached assigned vehicle for today');
        state = state.copyWith(
          selectedVehicle: _buildVehicleFromCache(cachedVehicle),
          isLoading: false,
        );
        return;
      }

      // If not cached and online, try to fetch from API
      if (_connectivityService.isOnline) {
        debugPrint('📡 Fetching assigned vehicle from API...');
        // TODO: Call API to get assigned vehicle
        // For now, just mark as not yet implemented
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Assigned vehicle API not yet implemented',
        );
        return;
      }

      // Offline: try to get vehicle for offline mode (prefers today's assigned, falls back to last used)
      final offlineVehicle = await _cacheService.getVehicleForOfflineMode();
      if (offlineVehicle != null) {
        debugPrint('📱 Using cached vehicle in offline mode');
        state = state.copyWith(
          selectedVehicle: _buildVehicleFromCache(offlineVehicle),
          isLoading: false,
          isOnline: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No vehicle available (offline with no cached data)',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  /// Select a vehicle
  /// Caches as both current selection and assigned vehicle for today
  Future<void> selectVehicle(Vehicle vehicle) async {
    state = state.copyWith(selectedVehicle: vehicle);

    try {
      // Cache as current selection
      await _cacheService.cacheVehicleSelection(
        vehicleId: vehicle.id,
        vehicleName: vehicle.regNo,
        plateNumber: vehicle.regNo,
      );

      // Also cache as assigned vehicle for today
      await _cacheService.cacheAssignedVehicleForToday(
        vehicleId: vehicle.id,
        vehicleName: vehicle.regNo,
        plateNumber: vehicle.regNo,
      );

      debugPrint('✅ Vehicle selected and cached: ${vehicle.regNo}');
    } catch (e) {
      debugPrint('⚠️ Error caching vehicle selection: $e');
    }
  }

  /// Helper: Build Vehicle object from cached data
  /// Used when retrieving from cache
  Vehicle _buildVehicleFromCache(Map<String, dynamic> cachedData) {
    return Vehicle(
      id: cachedData['vehicleId'] as String? ?? 'unknown',
      regNo:
          cachedData['vehicleName'] as String? ??
          cachedData['plateNumber'] as String? ??
          'unknown',
      make: 'Cached',
      model: 'Vehicle',
      year: DateTime.now().year.toString(),
      currentLocation: null,
    );
  }

  void dispose() {
    _connectivityService.removeListener(() {});
  }
}
