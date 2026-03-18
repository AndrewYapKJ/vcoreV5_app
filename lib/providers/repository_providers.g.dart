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

String _$jobListViewModelHash() => r'10998538d7f0f259d8cfe450eb21301faaf58f9a';

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
    r'7f34bdcf2bfb6be4c3303a5c69790917c3032375';

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

/// PTI ViewModel provider

@ProviderFor(ptiViewModel)
final ptiViewModelProvider = PtiViewModelProvider._();

/// PTI ViewModel provider

final class PtiViewModelProvider
    extends $FunctionalProvider<PTIViewModel, PTIViewModel, PTIViewModel>
    with $Provider<PTIViewModel> {
  /// PTI ViewModel provider
  PtiViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ptiViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ptiViewModelHash();

  @$internal
  @override
  $ProviderElement<PTIViewModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PTIViewModel create(Ref ref) {
    return ptiViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PTIViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PTIViewModel>(value),
    );
  }
}

String _$ptiViewModelHash() => r'9a658a3c846e9c2d19e3228a1b15722e8e19ed73';

/// Vehicle ViewModel provider

@ProviderFor(vehicleViewModel)
final vehicleViewModelProvider = VehicleViewModelProvider._();

/// Vehicle ViewModel provider

final class VehicleViewModelProvider
    extends
        $FunctionalProvider<
          VehicleViewModel,
          VehicleViewModel,
          VehicleViewModel
        >
    with $Provider<VehicleViewModel> {
  /// Vehicle ViewModel provider
  VehicleViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleViewModelHash();

  @$internal
  @override
  $ProviderElement<VehicleViewModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VehicleViewModel create(Ref ref) {
    return vehicleViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleViewModel>(value),
    );
  }
}

String _$vehicleViewModelHash() => r'cadcd15722cd32efa8a6e4ac04888df04fb50881';

/// Payment ViewModel provider

@ProviderFor(paymentViewModel)
final paymentViewModelProvider = PaymentViewModelProvider._();

/// Payment ViewModel provider

final class PaymentViewModelProvider
    extends
        $FunctionalProvider<
          PaymentViewModel,
          PaymentViewModel,
          PaymentViewModel
        >
    with $Provider<PaymentViewModel> {
  /// Payment ViewModel provider
  PaymentViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentViewModelHash();

  @$internal
  @override
  $ProviderElement<PaymentViewModel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PaymentViewModel create(Ref ref) {
    return paymentViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentViewModel>(value),
    );
  }
}

String _$paymentViewModelHash() => r'ecec2cb4104d9dfaba1b4fca00d4a87e95425c4d';
