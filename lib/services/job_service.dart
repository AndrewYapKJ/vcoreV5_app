import 'package:dio/dio.dart';
import 'api/job_api.dart';
import '../models/job_model.dart';

class JobService {
  final JobApi _jobApi = JobApi();

  /// Fetch jobs based on status
  /// status: 'pending', 'in-progress', or 'completed'
  /// siteType: 'HMS' or 'TMS'
  Future<List<Job>> getJobs({
    required String driverId,
    required String status,
    required String pm,
    required String siteType,
    required String tenantId,
  }) async {
    try {
      if (status == 'completed') {
        // Use Z_GetJobListToday for completed jobs
        return await _jobApi.getJobListToday(
          driverId: driverId,
          pm: pm,
          siteType: siteType,
          tenantId: tenantId,
        );
      } else {
        // Use GetJobswithdriver for pending and in-progress
        final apiStatus = status == 'pending' ? '0' : '1';
        return await _jobApi.getJobsWithDriver(
          driverId: driverId,
          status: apiStatus,
          pm: pm,
          siteType: siteType,
          tenantId: tenantId,
        );
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to fetch jobs');
    }
  }
}
