import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mdt_functions_model.dart';
import '../services/api/jobs_api.dart';
import 'user_provider.dart';

final jobsApiProvider = Provider((ref) => JobsApi());

/// Provider to fetch available MDT Functions
final mdtFunctionsProvider = FutureProvider<MDTFunctionsResponse>((ref) async {
  final jobsApi = ref.watch(jobsApiProvider);
  final tenantId = ref.watch(tenantIdProvider);

  if (tenantId == null) {
    throw Exception('Tenant ID not available');
  }

  return jobsApi.getMDTFunctions(tenantId: tenantId);
});

// Simple mutable state provider for current job activity
class _JobActivityNotifier extends Notifier<int?> {
  @override
  int? build() => null;
}

/// Provider to get/set the current job activity code (MDT Code)
/// This should be set when a job is selected/opened
final currentJobActivityProvider = NotifierProvider<_JobActivityNotifier, int?>(
  _JobActivityNotifier.new,
);

/// Provider to check if an activity is enabled based on current job activity
/// Activities with code <= current activity code are disabled
final isActivityEnabledProvider = Provider.family<bool, int>((
  ref,
  activityCode,
) {
  final currentActivity = ref.watch(currentJobActivityProvider);

  // If no current activity, all are enabled
  if (currentActivity == null) {
    return true;
  }

  // Disable activities with code less than or equal to current activity
  return activityCode > currentActivity;
});

/// Provider to get list of available MDT functions
final availableMDTFunctionsProvider = Provider<AsyncValue<List<MDTFunction>>>((
  ref,
) {
  final response = ref.watch(mdtFunctionsProvider);

  return response.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (mdtResponse) => AsyncValue.data(mdtResponse.functions),
  );
});

/// Provider to get enabled MDT functions (filtered by current activity)
final enabledMDTFunctionsProvider = Provider<AsyncValue<List<MDTFunction>>>((
  ref,
) {
  final functionsAsync = ref.watch(availableMDTFunctionsProvider);
  final currentActivity = ref.watch(currentJobActivityProvider);

  return functionsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (functions) {
      // If no current activity, return all functions
      if (currentActivity == null) {
        return AsyncValue.data(functions);
      }

      // Filter: only activities with code > current activity code
      final enabled = functions
          .where((f) => f.mdtCode > currentActivity)
          .toList();
      return AsyncValue.data(enabled);
    },
  );
});

/// Provider to get a specific MDT function by code
final mdtFunctionByCodeProvider =
    Provider.family<AsyncValue<MDTFunction?>, int>((ref, code) {
      final functionsAsync = ref.watch(availableMDTFunctionsProvider);

      return functionsAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
        data: (functions) {
          try {
            final function = functions.firstWhere((f) => f.mdtCode == code);
            return AsyncValue.data(function);
          } catch (e) {
            return AsyncValue.data(null);
          }
        },
      );
    });
