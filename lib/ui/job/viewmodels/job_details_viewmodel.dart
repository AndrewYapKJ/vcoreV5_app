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

/// ViewModel for Job Details feature
/// Handles job detail data, updates, and image uploads
/// Supports offline mode with automatic queueing
class JobDetailsViewModel extends StateNotifier<JobDetailsState> {
  final JobRepository _jobRepository;
  final ConnectivityService _connectivityService;
  final Job initialJob;

  JobDetailsViewModel({
    required JobRepository jobRepository,
    required ConnectivityService connectivityService,
    required Job job,
  }) : initialJob = job,
       _jobRepository = jobRepository,
       _connectivityService = connectivityService,
       super(JobDetailsState(job: job)) {
    _setupConnectivityListener();
    _loadJobImages();
    _populateFormFromJob();
  }

  /// Setup connectivity listener to handle offline/online transitions
  void _setupConnectivityListener() {
    _connectivityService.addListener(() {
      final isOnline = _connectivityService.isOnline;
      state = state.copyWith(
        isOnline: isOnline,
        showImageUploadBanner: !isOnline && state.uploadedImages.isNotEmpty,
      );

      if (isOnline) {
        debugPrint('🔄 Online - could sync pending operations');
        state = state.copyWith(syncStatus: SyncStatus.syncing);
      } else {
        debugPrint('📴 Offline - operations will be queued');
      }
    });
  }

  /// Load job images for display
  Future<void> _loadJobImages() async {
    try {
      final jobNo = initialJob.id?.toString() ?? '';
      if (jobNo.isEmpty) return;

      final result = await _jobRepository.getJobImages(jobNo: jobNo);

      if (result.isSuccess && result.getDataOrNull() != null) {
        final imageNames = result
            .getDataOrNull()!
            .map((img) => img.name ?? 'unknown')
            .toList();

        state = state.copyWith(uploadedImages: imageNames);
        debugPrint('✅ Loaded ${imageNames.length} images');
      } else if (result.isOffline) {
        debugPrint('📴 Using cached images');
        final imageNames =
            result
                .getDataOrNull()
                ?.map((img) => img.name ?? 'unknown')
                .toList() ??
            [];
        state = state.copyWith(uploadedImages: imageNames);
      }
    } catch (e) {
      debugPrint('❌ Error loading images: $e');
    }
  }

  /// Populate form fields from job data
  void _populateFormFromJob() {
    state = state.copyWith(
      containerNo: initialJob.containerNo,
      sealNo: initialJob.sealNo,
      trailerNo: initialJob.trailerNo,
      remarks: initialJob.remarks,
      headRun: initialJob.headRun ?? false,
      trailerRun: initialJob.trailerRun ?? false,
    );
  }

  /// Update job with new details
  /// Automatically queues if offline
  Future<void> updateJobDetails({
    required String trailerID,
    required String pickQty,
    required String dropQty,
  }) async {
    state = state.copyWith(isUpdating: true, updateErrorMessage: null);

    try {
      final tenantId = LoginCacheService().getCachedTenantId() ?? '';
      final result = await _jobRepository.updateJobDetails(
        jobNo: initialJob.no ?? '',
        trailerID: trailerID,
        trailerNo: state.trailerNo ?? '',
        containerNo: state.containerNo ?? '',
        sealNo: state.sealNo ?? '',
        remarks: state.remarks ?? '',
        siteType: 'HMS', // TODO: Get from somewhere
        pickQty: pickQty,
        dropQty: dropQty,
        tenantId: tenantId,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isUpdating: false,
          updateErrorMessage: null,
          syncStatus: SyncStatus.success,
        );
        debugPrint('✅ Job details updated successfully');
      } else if (result.isOffline) {
        state = state.copyWith(
          isUpdating: false,
          updateErrorMessage: 'Changes queued - will sync when online',
          syncStatus: SyncStatus.idle,
          failedOperationIds: [
            ...state.failedOperationIds,
            'update_job_details_${initialJob.no}',
          ],
        );
        debugPrint('📋 Job details update queued for sync');
      } else if (result.isError) {
        state = state.copyWith(
          isUpdating: false,
          updateErrorMessage: (result as ErrorResult).message,
          syncStatus: SyncStatus.failure,
        );
        debugPrint('❌ Error updating job: ${result.toString()}');
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        updateErrorMessage: 'Error: ${e.toString()}',
        syncStatus: SyncStatus.failure,
      );
      debugPrint('❌ Exception updating job: $e');
    }
  }

  /// Upload image for job
  /// Automatically queues if offline
  Future<void> uploadImage({
    required String filePath,
    required String fileName,
  }) async {
    state = state.copyWith(isUploadingImages: true, uploadErrorMessage: null);

    try {
      if (initialJob.no == null) {
        throw Exception('No job loaded');
      }

      final result = await _jobRepository.uploadJobImage(
        jobNo: initialJob.no ?? '',
        filePath: filePath,
        fileName: fileName,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isUploadingImages: false,
          uploadedImages: [...state.uploadedImages, fileName],
          uploadErrorMessage: null,
        );
        debugPrint('✅ Image uploaded successfully: $fileName');
      } else if (result.isOffline) {
        state = state.copyWith(
          isUploadingImages: false,
          uploadedImages: [...state.uploadedImages, fileName],
          uploadErrorMessage: 'Image queued for upload when online',
          showImageUploadBanner: true,
          failedOperationIds: [
            ...state.failedOperationIds,
            'upload_image_${initialJob.no}_$fileName',
          ],
        );
        debugPrint('📋 Image upload queued: $fileName');
      } else if (result.isError) {
        state = state.copyWith(
          isUploadingImages: false,
          uploadErrorMessage: (result as ErrorResult).message,
        );
        debugPrint('❌ Error uploading image: ${result.toString()}');
      }
    } catch (e) {
      state = state.copyWith(
        isUploadingImages: false,
        uploadErrorMessage: 'Error: ${e.toString()}',
      );
      debugPrint('❌ Exception uploading image: $e');
    }
  }

  /// Update a form field
  void updateFormField(String field, dynamic value) {
    switch (field) {
      case 'containerNo':
        state = state.copyWith(containerNo: value as String);
        break;
      case 'sealNo':
        state = state.copyWith(sealNo: value as String);
        break;
      case 'trailerNo':
        state = state.copyWith(trailerNo: value as String);
        break;
      case 'remarks':
        state = state.copyWith(remarks: value as String);
        break;
      case 'headRun':
        state = state.copyWith(headRun: value as bool);
        break;
      case 'trailerRun':
        state = state.copyWith(trailerRun: value as bool);
        break;
      case 'selectedTrailerId':
        state = state.copyWith(selectedTrailerId: value as String);
        break;
    }
  }

  /// Dismiss offline banner
  void dismissOfflineBanner() {
    state = state.copyWith(showImageUploadBanner: false);
  }

  /// Dispose resources
  void dispose() {
    _connectivityService.removeListener(() {});
  }
}
