import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcore_v5_app/constant/font_styling.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';
import 'package:vcore_v5_app/widgets/custom_typeahead_field.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';
import 'package:vcore_v5_app/services/vehicle_service.dart';
import 'package:vcore_v5_app/services/api/vehicle_api.dart';
import 'package:vcore_v5_app/services/api/jobs_api.dart';
import 'package:vcore_v5_app/models/vehicle_model.dart';
import 'package:vcore_v5_app/models/trailer_search_model.dart';
import 'package:vcore_v5_app/providers/user_provider.dart';

class RequestView extends ConsumerStatefulWidget {
  const RequestView({super.key});

  @override
  ConsumerState<RequestView> createState() => _RequestViewState();
}

class _RequestViewState extends ConsumerState<RequestView> {
  String? selectedJobType; // 'delivery' or 'collection'
  String? selectedSize; // '20', '40', or '60'
  String? selectedTrailer; // trailer type
  String? selectedVehicle; // vehicle plate number
  final containerNoController = TextEditingController();
  final trailerController = TextEditingController();
  final vehicleController = TextEditingController();
  bool isLoading = false;
  String? jobTypeError;
  String? sizeError;
  String? containerError;
  String? trailerError;
  String? vehicleError;

  // Services
  final LoginCacheService _cacheService = LoginCacheService();
  final VehicleService _vehicleService = VehicleService();
  final VehicleApi _vehicleApi = VehicleApi();
  final JobsApi _jobsApi = JobsApi();

  // Data lists
  List<Vehicle> _availableVehicles = [];
  bool _isLoadingVehicles = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _loadCachedVehicle();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoadingVehicles = true);
    try {
      // Use Riverpod provider to get driver ID (handles session properly)
      final driverId = ref.read(driverIdProvider);
      final tenantId = ref.read(tenantIdProvider);

      if (driverId != null && tenantId != null) {
        final vehicles = await _vehicleService.getVehicles(
          driverId: driverId,
          tenantId: tenantId,
        );
        if (mounted) {
          setState(() {
            _availableVehicles = vehicles;
            _isLoadingVehicles = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingVehicles = false);
      }
    }
  }

  Future<void> _loadCachedVehicle() async {
    final cachedVehicle = _cacheService.getCachedVehicleSelection();
    if (cachedVehicle != null && mounted) {
      setState(() {
        selectedVehicle = cachedVehicle['plateNumber'];
        vehicleController.text = cachedVehicle['plateNumber'] != null
            ? "${cachedVehicle['vehicleId']} - ${cachedVehicle['plateNumber']}"
            : '';
      });
    }
  }

  Future<List<TrailerSearchResult>> _searchTrailers(String query) async {
    debugPrint(
      '🔍 Searching trailers with query: "$query" and size: "$selectedSize"',
    );
    try {
      final tenantId = ref.read(tenantIdProvider);
      if (tenantId == null) {
        throw Exception('Tenant ID not found');
      }

      debugPrint(
        '🔍 Searching trailers: query=, size=$selectedSize, tenantId=$tenantId',
      );

      final results = await _vehicleApi.searchTrailers(
        trailerRegNo: query,
        trSize: selectedSize ?? '40',
        tenantId: tenantId,
      );

      debugPrint('✅ Got ${results.length} trailer results');
      return results;
    } catch (e) {
      debugPrint('❌ Error searching trailers: $e');
      return [];
    }
  }

  Future<void> _submitRequestJob() async {
    try {
      setState(() => isLoading = true);

      // Use Riverpod provider to get driver ID (handles session properly)
      final driverId = ref.read(driverIdProvider);
      final vehicleData = _availableVehicles.firstWhere(
        (v) => v.plateNumber == selectedVehicle,
      );

      if (driverId == null || driverId.isEmpty) {
        throw Exception('Session expired. Please re-login to continue');
      }

      debugPrint(
        '📤 Submitting request job: driverId=$driverId, vehicleId=${vehicleData.id}, trailer=$selectedTrailer, container=$selectedSize',
      );

      final response = await _jobsApi.requestJob(
        driverId: driverId,
        pmid: vehicleData.id, // Vehicle ID
        delCol: selectedJobType == 'delivery' ? 'DEL' : 'COL',
        containerNo: containerNoController.text,
        containerSize: selectedSize!,
        trailerId: selectedTrailer ?? "",
        lat: 0.0,
        lon: 0.0,
      );
      if (mounted) {
        setState(() => isLoading = false);

        if (response.success) {
          debugPrint('✅ Request job submitted successfully');
          CustomSnackBar.showSuccess(
            context,
            message: response.message ?? 'request_submitted'.tr(),
          );

          // Clear form
          containerNoController.clear();
          trailerController.clear();
          vehicleController.clear();
          setState(() {
            selectedJobType = null;
            selectedSize = null;
            selectedTrailer = null;
            selectedVehicle = null;
          });
        } else {
          CustomSnackBar.showError(
            context,
            message: response.message ?? 'Failed to submit request',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error submitting request: ${e.toString()}');
      if (mounted) {
        setState(() => isLoading = false);
        CustomSnackBar.showError(context, message: 'Error: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    containerNoController.dispose();
    trailerController.dispose();
    vehicleController.dispose();
    super.dispose();
  }

  Future<String?> _scanQRCode() async {
    try {
      // TODO: Implement actual QR code scanning
      // For now, show a placeholder dialog
      CustomSnackBar.showInfo(context, message: 'QR Scanner - Coming Soon');

      // Uncomment when QR scanner package is added:
      // final result = await BarcodeScanner.scan();
      // if (result.isValidFormat && result.formatNote != 'null') {
      //   return result.rawContent;
      // }
      return null;
    } catch (e) {
      CustomSnackBar.showError(context, message: 'Error scanning QR code: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            margin: EdgeInsets.only(bottom: 60.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(
                  context,
                  'job_type'.tr(),
                  Icons.work_outline,
                ),
                SizedBox(height: 4.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildRadioOption(
                            context: context,
                            label: 'delivery'.tr(),
                            value: 'delivery',
                            icon: Icons.local_shipping_outlined,
                            groupValue: selectedJobType,
                            onChanged: (value) {
                              setState(() {
                                selectedJobType = value;
                                jobTypeError = null;
                              });
                            },
                            colorScheme: colorScheme,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildRadioOption(
                            context: context,
                            label: 'collection'.tr(),
                            value: 'collection',
                            icon: Icons.inventory_2_outlined,
                            groupValue: selectedJobType,
                            onChanged: (value) {
                              setState(() {
                                selectedJobType = value;
                                jobTypeError = null;
                              });
                            },
                            colorScheme: colorScheme,
                          ),
                        ),
                      ],
                    ),
                    if (jobTypeError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 4.w),
                        child: Text(
                          jobTypeError!,
                          style: context.font
                              .regular(context)
                              .copyWith(
                                fontSize: 12.sp,
                                color: colorScheme.error,
                              ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Container Size Section - Enhanced
                _buildSectionLabel(
                  context,
                  'container_size'.tr(),
                  Icons.square_foot,
                ),
                SizedBox(height: 4.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildRadioOption(
                            context: context,
                            label: '20\'',
                            value: '20',
                            icon: Icons.crop_din,
                            groupValue: selectedSize,
                            onChanged: (value) {
                              setState(() {
                                selectedSize = value;
                                sizeError = null;
                              });
                            },
                            colorScheme: colorScheme,
                            compact: true,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildRadioOption(
                            context: context,
                            label: '40\'',
                            value: '40',
                            icon: Icons.crop_din,
                            groupValue: selectedSize,
                            onChanged: (value) {
                              setState(() {
                                selectedSize = value;
                                sizeError = null;
                              });
                            },
                            colorScheme: colorScheme,
                            compact: true,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildRadioOption(
                            context: context,
                            label: '45\'',
                            value: '45',
                            icon: Icons.crop_din,
                            groupValue: selectedSize,
                            onChanged: (value) {
                              setState(() {
                                selectedSize = value;
                                sizeError = null;
                              });
                            },
                            colorScheme: colorScheme,
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                    if (sizeError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 4.w),
                        child: Text(
                          sizeError!,
                          style: context.font
                              .regular(context)
                              .copyWith(
                                fontSize: 12.sp,
                                color: colorScheme.error,
                              ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Container Number Section - Enhanced
                _buildSectionLabel(
                  context,
                  'container_number'.tr(),
                  Icons.inventory,
                ),
                SizedBox(height: 4.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModernTextField(
                      context: context,
                      controller: containerNoController,
                      hint: 'Enter or scan container number',
                      prefixIcon: Icons.inventory_2_outlined,
                      suffixIcon: Icons.qr_code_2,
                      colorScheme: colorScheme,
                      onSuffixTap: _scanQRCode,
                    ),
                    if (containerError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 4.w),
                        child: Text(
                          containerError!,
                          style: context.font
                              .regular(context)
                              .copyWith(
                                fontSize: 12.sp,
                                color: colorScheme.error,
                              ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Trailer Section - Enhanced with Custom Typeahead
                _buildSectionLabel(
                  context,
                  'trailer'.tr(),
                  Icons.directions_car,
                ),
                SizedBox(height: 4.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTypeAheadField<TrailerSearchResult>(
                      controller: trailerController,
                      hint: 'Search trailer registration number',
                      prefixIcon: Icons.local_shipping_outlined,
                      suffixIcon: Icons.qr_code_2,
                      onQRScan: _scanQRCode,
                      suggestionsCallback: (pattern) async {
                        await Future.delayed(const Duration(milliseconds: 300));
                        return await _searchTrailers(pattern);
                      },
                      itemBuilder: (context, trailer) {
                        return Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.h),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.local_shipping,
                                color: colorScheme.primary,
                                size: 16.h,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trailer.trailerRegNo,
                                    style: context.font
                                        .semibold(context)
                                        .copyWith(fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      onSuggestionSelected: (trailer) {
                        setState(() {
                          selectedTrailer = trailer.trailerID;
                          trailerController.text = trailer.trailerRegNo;
                          trailerError = null;
                          //  = [];
                        });
                      },
                      suggestionDisplay: (trailer) => trailer.trailerRegNo,
                      colorScheme: colorScheme,
                      context: context,
                      maxSuggestions: 5,
                    ),
                    if (trailerError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 4.w),
                        child: Text(
                          trailerError!,
                          style: context.font
                              .regular(context)
                              .copyWith(
                                fontSize: 12.sp,
                                color: colorScheme.error,
                              ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 36),
                // Request Button - Enhanced
                Container(
                  width: double.infinity,
                  height: 52.h,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isLoading
                          ? null
                          : () async {
                              bool hasError = false;
                              setState(() {
                                jobTypeError = null;
                                sizeError = null;
                                // containerError = null;
                                // trailerError = null;
                                // vehicleError = null;
                              });

                              if (selectedJobType == null) {
                                setState(
                                  () => jobTypeError = 'Job type is required',
                                );
                                hasError = true;
                              }
                              if (selectedSize == null) {
                                setState(
                                  () =>
                                      sizeError = 'Container size is required',
                                );
                                hasError = true;
                              }
                              // if (containerNoController.text.isEmpty) {
                              //   setState(
                              //     () => containerError =
                              //         'Container number is required',
                              //   );
                              //   hasError = true;
                              // }
                              // if (selectedTrailer == null) {
                              //   setState(
                              //     () => trailerError = 'Trailer is required',
                              //   );
                              //   hasError = true;
                              // }
                              // if (selectedVehicle == null) {
                              //   setState(
                              //     () => vehicleError = 'Vehicle is required',
                              //   );
                              //   hasError = true;
                              // }

                              if (!hasError) {
                                if (selectedSize != null &&
                                    selectedJobType != null) {
                                  await _submitRequestJob();
                                }
                              }
                            },
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                height: 24.h,
                                width: 24.h,
                                child: CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send_rounded,
                                    color: colorScheme.onPrimary,
                                    size: 20.h,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'submit_request'.tr(),
                                    style: context.font
                                        .bold(context)
                                        .copyWith(
                                          fontSize: 16.sp,
                                          color: colorScheme.onPrimary,
                                          letterSpacing: 0.5,
                                        ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50.h + MediaQuery.of(context).viewPadding.bottom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.h),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.secondary, size: 16.h),
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: context.font
              .semibold(context)
              .copyWith(fontSize: 14.sp, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required IconData suffixIcon,
    required ColorScheme colorScheme,
    VoidCallback? onSuffixTap,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          prefixIcon,
          color: colorScheme.primary.withValues(alpha: 0.6),
          size: 18.h,
        ),
        suffixIcon: GestureDetector(
          onTap: onSuffixTap,
          child: Icon(
            suffixIcon,
            color: colorScheme.primary.withValues(alpha: 0.7),
            size: 18.h,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        isDense: true,
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: context.font
            .regular(context)
            .copyWith(
              fontSize: 14.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
        errorStyle: context.font
            .regular(context)
            .copyWith(fontSize: 12.sp, color: colorScheme.error, height: 0.8),
      ),
      style: context.font.regular(context).copyWith(fontSize: 14.sp),
    );
  }

  Widget _buildRadioOption({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
    required ColorScheme colorScheme,
    bool compact = false,
  }) {
    final isSelected = groupValue == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: compact ? 10.h : 14.h,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.1),
                    colorScheme.primary.withValues(alpha: 0.05),
                  ],
                )
              : null,
          color: isSelected ? null : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.5)
                : colorScheme.outline.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : colorScheme.outline.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.5),
                size: 18.h,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.font
                  .semibold(context)
                  .copyWith(
                    fontSize: compact ? 13.sp : 14.sp,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
