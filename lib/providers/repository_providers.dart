import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:vcore_v5_app/data/datasources/job_datasource.dart';
import 'package:vcore_v5_app/data/datasources/job_local_datasource_impl.dart';
import 'package:vcore_v5_app/data/datasources/job_remote_datasource_impl.dart';
import 'package:vcore_v5_app/data/datasources/offline_queue_datasource_impl.dart';
import 'package:vcore_v5_app/data/repositories/job_repository_impl.dart';
import 'package:vcore_v5_app/domain/repositories/job_repository.dart';
import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';
import 'package:vcore_v5_app/services/api/job_api.dart';
import 'package:vcore_v5_app/services/offline/offline_storage_service.dart';
import 'package:vcore_v5_app/ui/job/states/job_states.dart';
import 'package:vcore_v5_app/ui/job/viewmodels/job_details_viewmodel.dart';
import 'package:vcore_v5_app/ui/job/viewmodels/job_list_viewmodel.dart';

part 'repository_providers.g.dart';

// ============================================================================
// SERVICE PROVIDERS (Bottom of dependency tree)
// ============================================================================

/// Connectivity Service provider
final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

/// JobApi provider
final jobApiProvider = Provider<JobApi>((ref) => JobApi());

/// OfflineStorageService provider
final offlineStorageServiceProvider = Provider<OfflineStorageService>(
  (ref) => OfflineStorageService(),
);

// ============================================================================
// DATA SOURCE PROVIDERS (Middle of dependency tree)
// ============================================================================

/// Remote data source for Job operations
final jobRemoteDataSourceProvider = Provider<JobRemoteDataSource>((ref) {
  final jobApi = ref.watch(jobApiProvider);
  return JobRemoteDataSourceImpl(jobApi: jobApi);
});

/// Local data source for Job caching
final jobLocalDataSourceProvider = Provider<JobLocalDataSource>((ref) {
  return JobLocalDataSourceImpl();
});

/// Offline queue data source
final offlineQueueDataSourceProvider = Provider<OfflineQueueDataSource>((ref) {
  return OfflineQueueDataSourceImpl();
});

// ============================================================================
// REPOSITORY PROVIDERS (Clean Architecture - Business Logic)
// ============================================================================

/// Job Repository provider
/// This is the single source of truth for all job-related operations
/// Automatically handles offline/online switching and caching
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final remoteDataSource = ref.watch(jobRemoteDataSourceProvider);
  final localDataSource = ref.watch(jobLocalDataSourceProvider);
  final queueDataSource = ref.watch(offlineQueueDataSourceProvider);

  return JobRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    offlineQueueDataSource: queueDataSource,
  );
});

// ============================================================================
// EXPORT - Use these providers in your ViewModels
// ============================================================================

// ============================================================================
// VIEW MODEL PROVIDERS
// ============================================================================

/// Job List ViewModel provider
@riverpod
JobListViewModel jobListViewModel(Ref ref) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  final viewModel = JobListViewModel(
    jobRepository: jobRepository,
    connectivityService: connectivityService,
  );

  ref.onDispose(() {
    viewModel.dispose();
  });

  return viewModel;
}

/// Job Details ViewModel provider - supports multiple instances per job
@riverpod
JobDetailsViewModel jobDetailsViewModel(Ref ref, Job job) {
  final jobRepository = ref.watch(jobRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  final viewModel = JobDetailsViewModel(
    jobRepository: jobRepository,
    connectivityService: connectivityService,
    job: job,
  );

  ref.onDispose(() {
    viewModel.dispose();
  });

  return viewModel;
}
