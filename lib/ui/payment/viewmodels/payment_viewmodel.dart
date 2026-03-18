import 'package:flutter/foundation.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:vcore_v5_app/domain/repositories/payment_repository.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';
import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// State class for Payment feature
class PaymentState {
  final List<Payment> payments;
  final bool isLoading;
  final bool isSubmitting;
  final bool isOnline;
  final SyncStatus syncStatus;
  final String? errorMessage;
  final List<String> failedPaymentIds;

  const PaymentState({
    this.payments = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.isOnline = true,
    this.syncStatus = SyncStatus.idle,
    this.errorMessage,
    this.failedPaymentIds = const [],
  });

  PaymentState copyWith({
    List<Payment>? payments,
    bool? isLoading,
    bool? isSubmitting,
    bool? isOnline,
    SyncStatus? syncStatus,
    String? errorMessage,
    List<String>? failedPaymentIds,
  }) {
    return PaymentState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isOnline: isOnline ?? this.isOnline,
      syncStatus: syncStatus ?? this.syncStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      failedPaymentIds: failedPaymentIds ?? this.failedPaymentIds,
    );
  }

  bool get hasPayments => payments.isNotEmpty;
  double get totalAmount => payments.fold(0, (sum, p) => sum + p.amount);
  int get paymentCount => payments.length;
  bool get hasPendingPayments =>
      payments.any((p) => p.status.toLowerCase() == 'pending');
}

/// ViewModel for Payment feature
class PaymentViewModel extends StateNotifier<PaymentState> {
  final PaymentRepository _paymentRepository;
  final ConnectivityService _connectivityService;

  PaymentViewModel({
    required PaymentRepository paymentRepository,
    required ConnectivityService connectivityService,
  }) : _paymentRepository = paymentRepository,
       _connectivityService = connectivityService,
       super(const PaymentState()) {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivityService.addListener(() {
      final isOnline = _connectivityService.isOnline;
      state = state.copyWith(isOnline: isOnline);

      if (isOnline) {
        debugPrint('🔄 Online - could process pending payments');
      }
    });
  }

  /// Load all payments
  Future<void> loadPayments({
    required String driverId,
    required String tenantId,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _paymentRepository.getPayments(
        driverId: driverId,
        tenantId: tenantId,
      );

      if (result.isSuccess && result.getDataOrNull() != null) {
        state = state.copyWith(
          payments: result.getDataOrNull()!,
          isLoading: false,
        );
        debugPrint('✅ Loaded ${result.getDataOrNull()!.length} payments');
      } else if (result.isOffline) {
        final cached = result.getDataOrNull() ?? [];
        state = state.copyWith(
          payments: cached,
          isLoading: false,
          isOnline: false,
        );
      } else if (result.isError) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load payments',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  /// Load payments for a specific job
  Future<void> loadJobPayments({
    required String jobNo,
    required String tenantId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _paymentRepository.getJobPayments(
        jobNo: jobNo,
        tenantId: tenantId,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          payments: result.getDataOrNull() ?? [],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  /// Submit a payment
  Future<void> submitPayment({
    required String jobNo,
    required double amount,
    required String paymentMethod,
    required String tenantId,
  }) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final result = await _paymentRepository.submitPayment(
        jobNo: jobNo,
        amount: amount,
        paymentMethod: paymentMethod,
        tenantId: tenantId,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          isSubmitting: false,
          syncStatus: SyncStatus.success,
        );
        debugPrint('✅ Payment submitted successfully');
      } else if (result.isOffline) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Payment queued - will process when online',
          syncStatus: SyncStatus.idle,
          failedPaymentIds: [...state.failedPaymentIds, jobNo],
        );
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  void dispose() {
    _connectivityService.removeListener(() {});
  }
}
