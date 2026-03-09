import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';
import 'package:vcore_v5_app/widgets/custom_typeahead_field.dart';
import 'package:vcore_v5_app/services/api/vehicle_api.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';
import 'package:vcore_v5_app/models/trailer_search_model.dart';
import 'package:vcore_v5_app/models/rest_value_model.dart';
import 'package:vcore_v5_app/providers/user_provider.dart';

class RestRequestView extends ConsumerStatefulWidget {
  const RestRequestView({super.key});

  @override
  ConsumerState<RestRequestView> createState() => _RestRequestViewState();
}

class _RestRequestViewState extends ConsumerState<RestRequestView> {
  final _formKey = GlobalKey<FormState>();
  final trailerController = TextEditingController();
  final remarksController = TextEditingController();
  bool isLoading = false;

  // Services
  final VehicleApi _vehicleApi = VehicleApi();
  final LoginCacheService _cacheService = LoginCacheService();

  // Data
  String? selectedTrailerId;

  // Rest state management
  String restState = 'request'; // 'request', 'start', 'end'
  String? restId; // ID from API when in start/end state
  bool _isLoadingRestState = false;
  RestValueModel? _currentRestValue;

  String driverName = '';
  String pmId = '';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadRestState();
  }

  @override
  void dispose() {
    trailerController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    final userInfo = _cacheService.getCachedUserInfo();
    final cachedVehicle = _cacheService.getCachedVehicleSelection();

    if (mounted) {
      setState(() {
        driverName = userInfo?['Name'] ?? 'Guest User';
        pmId = cachedVehicle?['vehicleName'] as String? ?? 'N/A';
      });
    }
  }

  Future<void> _loadRestState() async {
    setState(() => _isLoadingRestState = true);
    try {
      final tenantId = ref.read(tenantIdProvider);
      final driverId = _cacheService.getCachedDriverId();
      final cachedVehicle = _cacheService.getCachedVehicleSelection();
      final vehicleId = cachedVehicle?['vehicleId'] as String?;

      if (tenantId == null || driverId == null || vehicleId == null) {
        throw Exception('Missing required data');
      }

      final restValue = await _vehicleApi.getRestValue(
        driverId: driverId,
        pmid: vehicleId,
        tenantId: tenantId,
      );

      if (mounted) {
        setState(() {
          _currentRestValue = restValue;
          restState = restValue.restState;
          restId = restValue.id.isNotEmpty ? restValue.id : null;
          _isLoadingRestState = false;

          // Pre-fill data if in start/end state
          if (restState != 'request') {
            if (restValue.trailerName != null &&
                restValue.trailerName!.isNotEmpty) {
              trailerController.text = restValue.trailerName!;
              selectedTrailerId = restValue.trailerId;
            }
            if (restValue.remarks != null && restValue.remarks!.isNotEmpty) {
              remarksController.text = restValue.remarks!;
            }
          }
        });

        debugPrint(
          '✅ Rest state loaded: ${restValue.stateDescription} (${restValue.restState})',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading rest state: $e');
      if (mounted) {
        setState(() {
          _isLoadingRestState = false;
          restState = 'request';
        });
      }
    }
  }

  Future<List<TrailerSearchResult>> _searchTrailers(String query) async {
    debugPrint('🔍 Searching trailers with query: "$query"');
    try {
      final tenantId = ref.read(tenantIdProvider);
      if (tenantId == null) {
        throw Exception('Tenant ID not found');
      }

      final results = await _vehicleApi.searchTrailers(
        trailerRegNo: query,
        trSize: '40',
        tenantId: tenantId,
      );

      debugPrint('✅ Got ${results.length} trailer results');
      return results;
    } catch (e) {
      debugPrint('❌ Error searching trailers: $e');
      return [];
    }
  }

  Future<String?> _scanQRCode() async {
    CustomSnackBar.showInfo(context, message: 'QR Scanner - Coming Soon');
    return null;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedTrailerId == null || selectedTrailerId!.isEmpty) {
        CustomSnackBar.showError(
          context,
          message: 'Please select a valid trailer',
        );
        return;
      }

      setState(() => isLoading = true);

      try {
        final tenantId = ref.read(tenantIdProvider);
        final driverId = _cacheService.getCachedDriverId();
        final cachedVehicle = _cacheService.getCachedVehicleSelection();
        final vehicleId = cachedVehicle?['vehicleId'] as String?;

        if (tenantId == null || driverId == null || vehicleId == null) {
          throw Exception('Missing required data');
        }

        Map<String, dynamic> result;

        // Execute different API based on current state
        switch (restState) {
          case 'request':
            // Request Rest
            result = await _vehicleApi.requestRest(
              driverId: driverId,
              pmid: vehicleId,
              trailer: selectedTrailerId!,
              tenantId: tenantId,
              remark: remarksController.text.trim(),
              startEndlat: 0.0, // TODO: Get from location service
              startEndlon: 0.0, // TODO: Get from location service
            );
            break;

          case 'start':
            // Start rest - need RestRequestNo from restId
            if (restId == null || restId!.isEmpty) {
              throw Exception('Rest Request ID not found');
            }
            result = await _vehicleApi.updateRestStart(
              restRequestNo: restId!,
              driverId: driverId,
              startEndlat: '0.0', // TODO: Get from location service
              startEndlon: '0.0', // TODO: Get from location service
            );
            break;

          case 'end':
            // End rest - need RestRequestNo from restId
            if (restId == null || restId!.isEmpty) {
              throw Exception('Rest Request ID not found');
            }
            result = await _vehicleApi.updateRestEnd(
              restRequestNo: restId!,
              driverId: driverId,
              startEndlat: '0.0', // TODO: Get from location service
              startEndlon: '0.0', // TODO: Get from location service
            );
            break;

          default:
            throw Exception('Unknown rest state');
        }

        if (mounted) {
          setState(() => isLoading = false);

          final bool success = result['Result'] as bool? ?? false;
          final String? error = result['Error'] as String?;

          if (success) {
            CustomSnackBar.showSuccess(context, message: _getSuccessMessage());

            // Reload the rest state to get updated status
            await _loadRestState();

            // Clear form only for request state
            if (restState == 'request') {
              trailerController.clear();
              remarksController.clear();
              selectedTrailerId = null;
            }
          } else {
            CustomSnackBar.showError(
              context,
              message: error ?? 'Operation failed',
            );
          }
        }
      } catch (e) {
        debugPrint('❌ Error submitting form: $e');
        if (mounted) {
          setState(() => isLoading = false);
          CustomSnackBar.showError(context, message: 'Error: $e');
        }
      }
    }
  }

  String _getSuccessMessage() {
    switch (restState) {
      case 'request':
        return 'Rest requested successfully';
      case 'start':
        return 'Rest started successfully';
      case 'end':
        return 'Rest completed successfully';
      default:
        return 'Operation completed';
    }
  }

  String _getPageTitle() {
    switch (restState) {
      case 'request':
        return 'Request Rest';
      case 'start':
        return 'Start Rest';
      case 'end':
        return 'End Rest';
      default:
        return 'Rest';
    }
  }

  String _getButtonText() {
    switch (restState) {
      case 'request':
        return 'Request Rest';
      case 'start':
        return 'Start Rest';
      case 'end':
        return 'End Rest';
      default:
        return 'Submit';
    }
  }

  Widget _buildSectionLabel(String label, IconData icon) {
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

  Widget _buildReadOnlyField(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.font
              .regular(context)
              .copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.outline,
              ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.outline.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: context.font
                      .regular(context)
                      .copyWith(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    IconData? prefixIcon,
    bool isRequired = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.font
              .regular(context)
              .copyWith(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.outline,
                letterSpacing: 0.3,
              ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: colorScheme.primary.withValues(alpha: 0.6),
                    size: 18.h,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            isDense: true,
            filled: true,
            fillColor: colorScheme.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
                .copyWith(
                  fontSize: 12.sp,
                  color: colorScheme.error,
                  height: 0.8,
                ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 52.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          onTap: isLoading ? null : _submitForm,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24.h,
                    width: 24.h,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 20.h,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        _getButtonText(),
                        style: context.font
                            .bold(context)
                            .copyWith(
                              fontSize: 16.sp,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getPageTitle(),
          style: context.font
              .bold(context)
              .copyWith(fontSize: 20.sp, color: colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _isLoadingRestState
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading rest state...',
                      style: context.font
                          .regular(context)
                          .copyWith(
                            fontSize: 14.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  margin: EdgeInsets.only(bottom: 20.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // State indicator badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStateColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getStateColor(),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStateIcon(),
                                color: _getStateColor(),
                                size: 18.h,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                _currentRestValue?.stateDescription ??
                                    'Request Rest',
                                style: context.font
                                    .semibold(context)
                                    .copyWith(
                                      fontSize: 13.sp,
                                      color: _getStateColor(),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Driver Information Section
                        _buildSectionLabel(
                          'Driver Information',
                          Icons.person_outline,
                        ),
                        SizedBox(height: 12.h),
                        _buildReadOnlyField('Driver Name', driverName),
                        SizedBox(height: 14.h),
                        _buildReadOnlyField('PM ID', pmId),
                        SizedBox(height: 24.h),

                        // Rest Details Section
                        _buildSectionLabel(
                          'Rest Details',
                          Icons.access_time_outlined,
                        ),
                        SizedBox(height: 12.h),

                        // Trailer ID with Typeahead Search
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trailer ID',
                              style: context.font
                                  .regular(context)
                                  .copyWith(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.outline,
                                    letterSpacing: 0.3,
                                  ),
                            ),
                            SizedBox(height: 8.h),
                            CustomTypeAheadField<TrailerSearchResult>(
                              controller: trailerController,
                              hint: 'Search trailer registration number',
                              prefixIcon: Icons.local_shipping_outlined,
                              suffixIcon: Icons.qr_code_2,
                              onQRScan: _scanQRCode,
                              suggestionsCallback: (pattern) async {
                                await Future.delayed(
                                  const Duration(milliseconds: 300),
                                );
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trailer.trailerRegNo,
                                            style: context.font
                                                .semibold(context)
                                                .copyWith(fontSize: 14.sp),
                                          ),
                                          Text(
                                            'ID: ${trailer.trailerID}',
                                            style: context.font
                                                .regular(context)
                                                .copyWith(
                                                  fontSize: 12.sp,
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.6),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                              onSuggestionSelected: (trailer) {
                                setState(() {
                                  selectedTrailerId = trailer.trailerID;
                                  trailerController.text = trailer.trailerRegNo;
                                });
                              },
                              suggestionDisplay: (trailer) =>
                                  trailer.trailerRegNo,
                              colorScheme: colorScheme,
                              context: context,
                              maxSuggestions: 5,
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // Remarks Section
                        _buildSectionLabel(
                          'Additional Remarks',
                          Icons.description_outlined,
                        ),
                        SizedBox(height: 12.h),
                        _buildInputField(
                          'Driver Remarks',
                          remarksController,
                          hint: 'Enter any additional remarks or notes',
                          maxLines: 6,
                          prefixIcon: Icons.edit_outlined,
                          isRequired: false,
                        ),
                        SizedBox(height: 32.h),

                        // Submit Button
                        _buildSubmitButton(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Color _getStateColor() {
    final colorScheme = Theme.of(context).colorScheme;
    switch (restState) {
      case 'request':
        return Colors.blue;
      case 'start':
        return Colors.orange;
      case 'end':
        return Colors.green;
      default:
        return colorScheme.primary;
    }
  }

  IconData _getStateIcon() {
    switch (restState) {
      case 'request':
        return Icons.send_outlined;
      case 'start':
        return Icons.play_arrow_outlined;
      case 'end':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }
}
