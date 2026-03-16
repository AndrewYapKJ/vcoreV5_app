import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcore_v5_app/constant/font_styling.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';
import 'package:vcore_v5_app/widgets/custom_typeahead_field.dart';
import 'package:vcore_v5_app/services/api/vehicle_api.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';
import 'package:vcore_v5_app/models/trailer_search_model.dart';
import 'package:vcore_v5_app/models/yard_model.dart';
import 'package:vcore_v5_app/models/return_value_model.dart';
import 'package:vcore_v5_app/providers/user_provider.dart';

class ReturnToBaseView extends ConsumerStatefulWidget {
  const ReturnToBaseView({super.key});

  @override
  ConsumerState<ReturnToBaseView> createState() => _ReturnToBaseViewState();
}

class _ReturnToBaseViewState extends ConsumerState<ReturnToBaseView> {
  final _formKey = GlobalKey<FormState>();
  final trailerController = TextEditingController();
  final stagingYardController = TextEditingController();
  final remarksController = TextEditingController();
  bool isLoading = false;

  // Services
  final VehicleApi _vehicleApi = VehicleApi();
  final LoginCacheService _cacheService = LoginCacheService();

  // Data
  String? selectedTrailerId;
  String? selectedYardId;
  List<YardModel> _availableYards = [];
  bool _isLoadingYards = false;

  // Return state management
  String returnState = 'request'; // 'request', 'start', 'end'
  String? returnId; // ID from API when in start/end state
  bool _isLoadingReturnState = false;
  ReturnValueModel? _currentReturnValue;

  String driverName = '';
  String pmId = '';

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadReturnState();
    _loadYards();
  }

  @override
  void dispose() {
    trailerController.dispose();
    stagingYardController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    final userInfo = _cacheService.getCachedUserInfo();
    final cachedVehicle = _cacheService.getCachedVehicleSelection();

    if (mounted) {
      setState(() {
        // Get driver name from userInfo
        driverName = userInfo?['Name'] ?? 'Guest User';

        // Get PM ID from cached vehicle
        pmId = cachedVehicle?['vehicleName'] as String? ?? 'N/A';
      });
    }
  }

  Future<void> _loadReturnState() async {
    setState(() => _isLoadingReturnState = true);
    try {
      final tenantId = ref.read(tenantIdProvider);
      final driverId = _cacheService.getCachedDriverId();
      final cachedVehicle = _cacheService.getCachedVehicleSelection();
      final vehicleId = cachedVehicle?['vehicleId'] as String?;

      if (tenantId == null || driverId == null || vehicleId == null) {
        throw Exception('Missing required data');
      }

      final returnValue = await _vehicleApi.getReturnValue(
        driverId: driverId,
        pmid: vehicleId,
        tenantId: tenantId,
      );

      if (mounted) {
        setState(() {
          _currentReturnValue = returnValue;
          returnState = returnValue.returnState;
          returnId = returnValue.id.isNotEmpty ? returnValue.id : null;
          _isLoadingReturnState = false;
          print("reutrn id: $returnId");
          // Pre-fill data if in start/end state
          if (returnState != 'request') {
            if (returnValue.trailerName != null &&
                returnValue.trailerName!.isNotEmpty) {
              trailerController.text = returnValue.trailerName!;
              selectedTrailerId = returnValue.trailerId;
            }
            if (returnValue.yardName != null &&
                returnValue.yardName!.isNotEmpty) {
              stagingYardController.text = returnValue.yardName!;
              selectedYardId = returnValue.yardID;
            }
            if (returnValue.remarks != null &&
                returnValue.remarks!.isNotEmpty) {
              remarksController.text = returnValue.remarks!;
            }
          }
        });

        debugPrint(
          '✅ Return state loaded: ${returnValue.stateDescription} (${returnValue.returnState})',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading return state: $e');
      if (mounted) {
        setState(() {
          _isLoadingReturnState = false;
          returnState = 'request'; // Default to request state on error
        });
      }
    }
  }

  Future<void> _loadYards() async {
    setState(() => _isLoadingYards = true);
    try {
      final tenantId = ref.read(tenantIdProvider);
      if (tenantId == null) {
        throw Exception('Tenant ID not found');
      }

      final yards = await _vehicleApi.getRTBYards(tenantId: tenantId, name: '');

      if (mounted) {
        setState(() {
          _availableYards = yards;
          _isLoadingYards = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading yards: $e');
      if (mounted) {
        setState(() => _isLoadingYards = false);
        CustomSnackBar.showError(
          context,
          message: 'Failed to load staging yards',
        );
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
        trSize: '40', // Default size
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

      if (selectedYardId == null || selectedYardId!.isEmpty) {
        CustomSnackBar.showError(
          context,
          message: 'Please select a staging yard',
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
        switch (returnState) {
          case 'request':
            // Request RTB
            result = await _vehicleApi.requestRTB(
              driverId: driverId,
              pmid: vehicleId,
              trailer: selectedTrailerId!,
              returnTo: selectedYardId!,
              tenantId: tenantId,
              remark: remarksController.text.trim(),
              startEndlat: 0.0, // TODO: Get from location service
              startEndlon: 0.0, // TODO: Get from location service
            );
            break;

          case 'start':
            // Start return - need RTBRequestNo from returnId
            if (returnId == null || returnId!.isEmpty) {
              throw Exception('RTB Request ID not found');
            }
            result = await _vehicleApi.updateRTBStart(
              rtbRequestNo: returnId!,
              driverId: driverId,
              startEndlat: '0.0', // TODO: Get from location service
              startEndlon: '0.0', // TODO: Get from location service
            );
            break;

          case 'end':
            // End return - need RTBRequestNo from returnId
            if (returnId == null || returnId!.isEmpty) {
              throw Exception('RTB Request ID not found');
            }
            result = await _vehicleApi.updateRTBEnd(
              rtbRequestNo: returnId!,
              driverId: driverId,
              startEndlat: '0.0', // TODO: Get from location service
              startEndlon: '0.0', // TODO: Get from location service
            );
            break;

          default:
            throw Exception('Unknown return state');
        }

        if (mounted) {
          setState(() => isLoading = false);
          final data = result['d'] as Map<String, dynamic>? ?? {};
          final bool success = data['Result'] as bool? ?? false;
          final String? error = data['Error'] as String?;

          if (success) {
            CustomSnackBar.showSuccess(context, message: _getSuccessMessage());

            // Reload the return state to get updated status
            await _loadReturnState();

            // Clear form only for request state
            if (returnState == 'request') {
              trailerController.clear();
              stagingYardController.clear();
              remarksController.clear();
              selectedTrailerId = null;
              selectedYardId = null;
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
    switch (returnState) {
      case 'request':
        return 'Return to base requested successfully';
      case 'start':
        return 'Return started successfully';
      case 'end':
        return 'Return completed successfully';
      default:
        return 'Operation completed';
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
                letterSpacing: 0.3,
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
    Widget? suffixIcon,
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
            suffixIcon: suffixIcon,
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

  String _getPageTitle() {
    switch (returnState) {
      case 'request':
        return 'Request Return to Base';
      case 'start':
        return 'Start Return to Base';
      case 'end':
        return 'End Return to Base';
      default:
        return 'Return to Base';
    }
  }

  String _getButtonText() {
    switch (returnState) {
      case 'request':
        return 'Request Return';
      case 'start':
        return 'Start Return';
      case 'end':
        return 'End Return';
      default:
        return 'Return to Base';
    }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _isLoadingReturnState
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading return state...',
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
                                _currentReturnValue?.stateDescription ??
                                    'Request Return',
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

                        // Return Details Section
                        _buildSectionLabel(
                          'Return Details',
                          Icons.assignment_turned_in_outlined,
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
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Staging Yard Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Staging Yard',
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
                            DropdownButtonFormField<String>(
                              value: selectedYardId,

                              isExpanded: true,
                              decoration: InputDecoration(
                                hintText: 'Select staging yard',
                                prefixIcon: Icon(
                                  Icons.location_on_outlined,
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                  size: 18.h,
                                ),
                                // contentPadding: EdgeInsets.symmetric(
                                //   horizontal: 14.w,
                                //   vertical: 12.h,
                                // ),
                                // isDense: true,
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHigh,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.15,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                    width: 1.5,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: _isLoadingYards
                                  ? []
                                  : _availableYards.map((yard) {
                                      return DropdownMenuItem<String>(
                                        value: yard.yardID,
                                        child: Text(
                                          yard.yardName,
                                          style: context.font
                                              .regular(context)
                                              .copyWith(fontSize: 12.sp),
                                        ),
                                      );
                                    }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedYardId = value;
                                  final selectedYard = _availableYards
                                      .firstWhere(
                                        (yard) => yard.yardID == value,
                                      );
                                  stagingYardController.text =
                                      selectedYard.yardName;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a staging yard';
                                }
                                return null;
                              },
                            ),
                            if (_isLoadingYards)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 16.h,
                                      height: 16.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Loading staging yards...',
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
    switch (returnState) {
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
    switch (returnState) {
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
