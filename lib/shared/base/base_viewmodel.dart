/// Base class for all ViewModels
/// Provides common functionality for state management and lifecycle
abstract class BaseViewModel {
  /// Initialize ViewModel - called when first created
  Future<void> initialize() async {}

  /// Cleanup ViewModel - called when disposed
  Future<void> dispose() async {}

  /// Check if ViewModel is initialized
  bool get isInitialized => false;
}

/// Result wrapper for API calls and async operations
/// Supports success, error, and loading states
sealed class ApiResult<T> {
  const ApiResult();

  /// Success result with data
  factory ApiResult.success(T data) => SuccessResult(data);

  /// Error result with message
  factory ApiResult.error(String message, {dynamic error}) =>
      ErrorResult(message, error);

  /// Loading state
  factory ApiResult.loading() => LoadingResult();

  /// Offline state - data queued for sync
  factory ApiResult.offline(T? data, {String? message}) =>
      OfflineResult(data, message);

  /// Map result to different type
  ApiResult<U> map<U>(U Function(T data) callback) {
    return this is SuccessResult<T>
        ? ApiResult.success(callback((this as SuccessResult<T>).data))
        : this as ApiResult<U>;
  }

  /// Get data or null
  T? getDataOrNull() {
    return this is SuccessResult<T> ? (this as SuccessResult<T>).data : null;
  }

  /// Check if success
  bool get isSuccess => this is SuccessResult<T>;

  /// Check if error
  bool get isError => this is ErrorResult<T>;

  /// Check if loading
  bool get isLoading => this is LoadingResult<T>;

  /// Check if offline
  bool get isOffline => this is OfflineResult<T>;
}

class SuccessResult<T> extends ApiResult<T> {
  final T data;
  const SuccessResult(this.data);
}

class ErrorResult<T> extends ApiResult<T> {
  final String message;
  final dynamic error;
  const ErrorResult(this.message, this.error);
}

class LoadingResult<T> extends ApiResult<T> {
  const LoadingResult();
}

class OfflineResult<T> extends ApiResult<T> {
  final T? data;
  final String? message;
  const OfflineResult(this.data, this.message);
}

/// Enum for sync status
enum SyncStatus { idle, syncing, success, failure }

/// Base state for features that support offline mode
class OfflineSyncState {
  final bool isOnline;
  final SyncStatus syncStatus;
  final String? lastSyncError;
  final int pendingRequests;

  const OfflineSyncState({
    this.isOnline = true,
    this.syncStatus = SyncStatus.idle,
    this.lastSyncError,
    this.pendingRequests = 0,
  });

  OfflineSyncState copyWith({
    bool? isOnline,
    SyncStatus? syncStatus,
    String? lastSyncError,
    int? pendingRequests,
  }) {
    return OfflineSyncState(
      isOnline: isOnline ?? this.isOnline,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncError: lastSyncError ?? this.lastSyncError,
      pendingRequests: pendingRequests ?? this.pendingRequests,
    );
  }
}
