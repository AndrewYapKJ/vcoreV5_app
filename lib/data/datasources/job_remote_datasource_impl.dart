import 'package:flutter/foundation.dart';
import 'package:vcore_v5_app/data/datasources/job_datasource.dart';
import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/models/uploaded_file_model.dart';
import 'package:vcore_v5_app/services/api/job_api.dart';
import 'package:vcore_v5_app/shared/base/base_viewmodel.dart';

/// Implementation of JobRemoteDataSource
/// Uses JobApi to fetch data from the backend
class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final JobApi _jobApi;

  JobRemoteDataSourceImpl({required JobApi jobApi}) : _jobApi = jobApi;

  @override
  Future<ApiResult<List<Job>>> getJobsWithDriver({
    required String driverId,
    required String status,
    required String pm,
    required String siteType,
    required String tenantId,
  }) async {
    try {
      final jobs = await _jobApi.getJobsWithDriver(
        driverId: driverId,
        status: status,
        pm: pm,
        siteType: siteType,
        tenantId: tenantId,
      );

      if (jobs.isEmpty) {
        return ApiResult.success([]);
      }

      return ApiResult.success(jobs);
    } catch (e) {
      debugPrint('Remote DataSource Error in getJobsWithDriver: $e');
      return ApiResult.error('Failed to fetch jobs: ${e.toString()}', error: e);
    }
  }

  @override
  Future<ApiResult<List<Job>>> getJobListToday({
    required String driverId,
    required String pm,
    required String siteType,
    required String tenantId,
  }) async {
    try {
      final jobs = await _jobApi.getJobListToday(
        driverId: driverId,
        pm: pm,
        siteType: siteType,
        tenantId: tenantId,
      );

      if (jobs.isEmpty) {
        return ApiResult.success([]);
      }

      return ApiResult.success(jobs);
    } catch (e) {
      debugPrint('Remote DataSource Error in getJobListToday: $e');
      return ApiResult.error('Failed to fetch jobs: ${e.toString()}', error: e);
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> updateJobWithDateTime({
    required String jobId,
    required String driverId,
    required String mdtCode,
    required String jobLastStatusDateTime,
    required String tenantId,
    String lat = '0.0',
    String lon = '0.0',
  }) async {
    try {
      final result = await _jobApi.updateJobWithDateTime(
        jobId: jobId,
        driverId: driverId,
        mdtCode: mdtCode,
        jobLastStatusDateTime: jobLastStatusDateTime,
        tenantId: tenantId,
        lat: lat,
        lon: lon,
      );

      if (result['result'] == true) {
        return ApiResult.success(result);
      }

      return ApiResult.error(
        result['error'] ?? 'Failed to update job',
        error: result,
      );
    } catch (e) {
      debugPrint('Remote DataSource Error in updateJobWithDateTime: $e');
      return ApiResult.error('Failed to update job: ${e.toString()}', error: e);
    }
  }

  @override
  Future<ApiResult<List<UploadedFile>>> getJobImages({
    required String jobNo,
  }) async {
    try {
      final images = await _jobApi.getJobImages(jobNo: jobNo);

      return ApiResult.success(images);
    } catch (e) {
      debugPrint('Remote DataSource Error in getJobImages: $e');
      return ApiResult.error(
        'Failed to fetch images: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> uploadJobImage({
    required String jobNo,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final result = await _jobApi.uploadJobImage(
        jobNo: jobNo,
        filePath: filePath,
        fileName: fileName,
      );

      if (result['result'] == true) {
        return ApiResult.success(result);
      }

      return ApiResult.error(
        result['message'] ?? 'Failed to upload image',
        error: result,
      );
    } catch (e) {
      debugPrint('Remote DataSource Error in uploadJobImage: $e');
      return ApiResult.error(
        'Failed to upload image: ${e.toString()}',
        error: e,
      );
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> updateJobDetails({
    required String jobNo,
    required String trailerID,
    required String trailerNo,
    required String containerNo,
    required String sealNo,
    required String remarks,
    required String siteType,
    required String pickQty,
    required String dropQty,
    required String tenantId,
  }) async {
    try {
      final result = await _jobApi.updateJobDetails(
        jobNo: jobNo,
        trailerID: trailerID,
        trailerNo: trailerNo,
        containerNo: containerNo,
        sealNo: sealNo,
        remarks: remarks,
        siteType: siteType,
        pickQty: pickQty,
        dropQty: dropQty,
        tenantId: tenantId,
      );

      if (result['result'] == true) {
        return ApiResult.success(result);
      }

      return ApiResult.error(
        result['message'] ?? 'Failed to update job details',
        error: result,
      );
    } catch (e) {
      debugPrint('Remote DataSource Error in updateJobDetails: $e');
      return ApiResult.error(
        'Failed to update job details: ${e.toString()}',
        error: e,
      );
    }
  }
}
