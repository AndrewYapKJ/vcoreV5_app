// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Job List ViewModel provider

@ProviderFor(jobListViewModel)
final jobListViewModelProvider = JobListViewModelProvider._();

/// Job List ViewModel provider

final class JobListViewModelProvider
    extends
        $FunctionalProvider<
          JobListViewModel,
          JobListViewModel,
          JobListViewModel
        >
    with $Provider<JobListViewModel> {
  /// Job List ViewModel provider
  JobListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobListViewModelHash();

  @$internal
  @override
  $ProviderElement<JobListViewModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JobListViewModel create(Ref ref) {
    return jobListViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobListViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobListViewModel>(value),
    );
  }
}

String _$jobListViewModelHash() => r'bf1d07aa631841afebd692fd330f55e4d1f629bb';

/// Job Details ViewModel provider - supports multiple instances per job

@ProviderFor(jobDetailsViewModel)
final jobDetailsViewModelProvider = JobDetailsViewModelFamily._();

/// Job Details ViewModel provider - supports multiple instances per job

final class JobDetailsViewModelProvider
    extends
        $FunctionalProvider<
          JobDetailsViewModel,
          JobDetailsViewModel,
          JobDetailsViewModel
        >
    with $Provider<JobDetailsViewModel> {
  /// Job Details ViewModel provider - supports multiple instances per job
  JobDetailsViewModelProvider._({
    required JobDetailsViewModelFamily super.from,
    required Job super.argument,
  }) : super(
         retry: null,
         name: r'jobDetailsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$jobDetailsViewModelHash();

  @override
  String toString() {
    return r'jobDetailsViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<JobDetailsViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  JobDetailsViewModel create(Ref ref) {
    final argument = this.argument as Job;
    return jobDetailsViewModel(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobDetailsViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobDetailsViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JobDetailsViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$jobDetailsViewModelHash() =>
    r'71a0ae9469cf9d5009a69ae5e6725c646ed91b3f';

/// Job Details ViewModel provider - supports multiple instances per job

final class JobDetailsViewModelFamily extends $Family
    with $FunctionalFamilyOverride<JobDetailsViewModel, Job> {
  JobDetailsViewModelFamily._()
    : super(
        retry: null,
        name: r'jobDetailsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Job Details ViewModel provider - supports multiple instances per job

  JobDetailsViewModelProvider call(Job job) =>
      JobDetailsViewModelProvider._(argument: job, from: this);

  @override
  String toString() => r'jobDetailsViewModelProvider';
}
