import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// Model for payment data
class Payment {
  final String id;
  final String jobNo;
  final double amount;
  final String status; // pending, completed, failed
  final DateTime date;
  final String? notes;

  Payment({
    required this.id,
    required this.jobNo,
    required this.amount,
    required this.status,
    required this.date,
    this.notes,
  });
}

/// Repository interface for Payment operations
abstract class PaymentRepository {
  /// Get all payments for a driver
  Future<ApiResult<List<Payment>>> getPayments({
    required String driverId,
    required String tenantId,
  });

  /// Get payment details by ID
  Future<ApiResult<Payment>> getPaymentById({
    required String paymentId,
    required String tenantId,
  });

  /// Get payments for a specific job
  Future<ApiResult<List<Payment>>> getJobPayments({
    required String jobNo,
    required String tenantId,
  });

  /// Submit payment for a job
  Future<ApiResult<void>> submitPayment({
    required String jobNo,
    required double amount,
    required String paymentMethod,
    required String tenantId,
  });

  /// Clear payment cache
  Future<void> clearCache();

  /// Get cache status
  Future<ApiResult<Map<String, dynamic>>> getCacheStatus();
}
