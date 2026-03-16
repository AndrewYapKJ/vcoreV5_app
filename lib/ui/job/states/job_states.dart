import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// State for JobList feature
class JobListState {
  // Job list data
  final List<Job> jobs;

  // Loading state
  final bool isLoading;
  final bool isRefreshing;

  // Error handling
  final String? errorMessage;

  // Offline state
  final bool isOnline;
  final SyncStatus syncStatus;
  final int? pendingRequests;

  // User session data (needed for filters)
  final String? driverId;
  final String? tenantId;
  final String? vehicleId;
  final String currentStatus; // "pending", "in-progress", "completed"
  final String currentSiteType; // "HMS" or "TMS"

  const JobListState({
    this.jobs = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.isOnline = true,
    this.syncStatus = SyncStatus.idle,
    this.pendingRequests,
    this.driverId,
    this.tenantId,
    this.vehicleId,
    this.currentStatus = 'pending',
    this.currentSiteType = 'HMS',
  });

  /// Create initial state
  factory JobListState.initial() {
    return const JobListState();
  }

  /// Copy with - create new state with some fields replaced
  JobListState copyWith({
    List<Job>? jobs,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool? isOnline,
    SyncStatus? syncStatus,
    int? pendingRequests,
    String? driverId,
    String? tenantId,
    String? vehicleId,
    String? currentStatus,
    String? currentSiteType,
  }) {
    return JobListState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage ?? this.errorMessage,
      isOnline: isOnline ?? this.isOnline,
      syncStatus: syncStatus ?? this.syncStatus,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      driverId: driverId ?? this.driverId,
      tenantId: tenantId ?? this.tenantId,
      vehicleId: vehicleId ?? this.vehicleId,
      currentStatus: currentStatus ?? this.currentStatus,
      currentSiteType: currentSiteType ?? this.currentSiteType,
    );
  }

  /// Check if showing cached data
  bool get isShowingCachedData => !isOnline && jobs.isNotEmpty;

  /// Check if has any jobs
  bool get hasJobs => jobs.isNotEmpty;

  /// Get total job count
  int get jobCount => jobs.length;
}

/// State for JobDetails feature
class JobDetailsState {
  // Current job
  final Job? job;

  // Loading states
  final bool isLoading;
  final bool isUpdating;
  final bool isUploadingImages;

  // Error handling
  final String? errorMessage;
  final String? updateErrorMessage;
  final String? uploadErrorMessage;

  // Offline state
  final bool isOnline;
  final SyncStatus syncStatus;
  final List<String>
  failedOperationIds; // Track which operations failed offline

  // Form state
  final String? containerNo;
  final String? sealNo;
  final String? trailerNo;
  final String? remarks;
  final String? selectedTrailerId;
  final bool headRun;
  final bool trailerRun;

  // Images
  final List<String> uploadedImages;
  final bool showImageUploadBanner;

  const JobDetailsState({
    this.job,
    this.isLoading = false,
    this.isUpdating = false,
    this.isUploadingImages = false,
    this.errorMessage,
    this.updateErrorMessage,
    this.uploadErrorMessage,
    this.isOnline = true,
    this.syncStatus = SyncStatus.idle,
    this.failedOperationIds = const [],
    this.containerNo,
    this.sealNo,
    this.trailerNo,
    this.remarks,
    this.selectedTrailerId,
    this.headRun = false,
    this.trailerRun = false,
    this.uploadedImages = const [],
    this.showImageUploadBanner = false,
  });

  /// Create initial state
  factory JobDetailsState.initial() {
    return const JobDetailsState();
  }

  /// Copy with - create new state with some fields replaced
  JobDetailsState copyWith({
    Job? job,
    bool? isLoading,
    bool? isUpdating,
    bool? isUploadingImages,
    String? errorMessage,
    String? updateErrorMessage,
    String? uploadErrorMessage,
    bool? isOnline,
    SyncStatus? syncStatus,
    List<String>? failedOperationIds,
    String? containerNo,
    String? sealNo,
    String? trailerNo,
    String? remarks,
    String? selectedTrailerId,
    bool? headRun,
    bool? trailerRun,
    List<String>? uploadedImages,
    bool? showImageUploadBanner,
  }) {
    return JobDetailsState(
      job: job ?? this.job,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isUploadingImages: isUploadingImages ?? this.isUploadingImages,
      errorMessage: errorMessage ?? this.errorMessage,
      updateErrorMessage: updateErrorMessage ?? this.updateErrorMessage,
      uploadErrorMessage: uploadErrorMessage ?? this.uploadErrorMessage,
      isOnline: isOnline ?? this.isOnline,
      syncStatus: syncStatus ?? this.syncStatus,
      failedOperationIds: failedOperationIds ?? this.failedOperationIds,
      containerNo: containerNo ?? this.containerNo,
      sealNo: sealNo ?? this.sealNo,
      trailerNo: trailerNo ?? this.trailerNo,
      remarks: remarks ?? this.remarks,
      selectedTrailerId: selectedTrailerId ?? this.selectedTrailerId,
      headRun: headRun ?? this.headRun,
      trailerRun: trailerRun ?? this.trailerRun,
      uploadedImages: uploadedImages ?? this.uploadedImages,
      showImageUploadBanner:
          showImageUploadBanner ?? this.showImageUploadBanner,
    );
  }

  /// Check if valid job is loaded
  bool get hasValidJob => job != null && job!.id != null;

  /// Check if showing cached data
  bool get isShowingCachedData => !isOnline && job != null;

  /// Get count of failed operations
  int get failedOperationCount => failedOperationIds.length;

  /// Check if any operation is queued offline
  bool get hasOfflineOperations => !isOnline && failedOperationIds.isNotEmpty;
}
