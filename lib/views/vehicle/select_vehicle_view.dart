import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcore_v5_app/constant/font_styling.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';
import 'package:vcore_v5_app/services/vehicle_service.dart';
import 'package:vcore_v5_app/models/vehicle_model.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';
import 'package:vcore_v5_app/providers/user_provider.dart';

class SelectVehicleView extends ConsumerStatefulWidget {
  const SelectVehicleView({super.key});

  @override
  ConsumerState<SelectVehicleView> createState() => _SelectVehicleViewState();
}

class _SelectVehicleViewState extends ConsumerState<SelectVehicleView> {
  String? selectedVehicle;
  String searchQuery = '';
  String? lastSelectedVehicleId;
  String? defaultVehicleId;
  late Future<List<Vehicle>> _vehiclesFuture;
  bool _isLoadingDefaults = true;
  final VehicleService _vehicleService = VehicleService();
  final LoginCacheService _cacheService = LoginCacheService();

  @override
  void initState() {
    super.initState();
    _initializeVehicles();
  }

  Future<void> _initializeVehicles() async {
    // Get driver ID and tenant ID from cache and provider
    final driverId = _cacheService.getCachedDriverId();
    final tenantId = ref.read(tenantIdProvider);

    if (driverId != null && tenantId != null) {
      // Initialize the future immediately (don't wait)
      _vehiclesFuture = _vehicleService.getVehicles(
        driverId: driverId,
        tenantId: tenantId,
      );

      // Load defaults in background
      _loadDefaults(driverId, tenantId);
    } else {
      setState(() {
        _vehiclesFuture = Future.error('Driver ID or Tenant ID not found');
        _isLoadingDefaults = false;
      });
    }
  }

  Future<void> _loadDefaults(String driverId, String tenantId) async {
    // Try to load default vehicle first
    await _loadDefaultVehicle(driverId, tenantId);

    // If no default vehicle, load last selected from cache
    if (defaultVehicleId == null) {
      await _loadLastSelectedVehicle();
    }

    if (mounted) {
      setState(() {
        _isLoadingDefaults = false;
      });
    }
  }

  Future<void> _loadDefaultVehicle(String driverId, String tenantId) async {
    try {
      final defaultVehicle = await _vehicleService.getDefaultVehicle(
        driverId: driverId,
        tenantId: tenantId,
      );

      if (defaultVehicle != null && mounted) {
        setState(() {
          defaultVehicleId = defaultVehicle.id;
          selectedVehicle = defaultVehicle.id;
        });
        debugPrint(
          '✅ Default vehicle loaded: ${defaultVehicle.plateNumber} (ID: ${defaultVehicle.id})',
        );
      } else {
        debugPrint('ℹ️ No default vehicle assigned to this driver');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load default vehicle: $e');
    }
  }

  Future<void> _loadLastSelectedVehicle() async {
    final cachedVehicle = _cacheService.getCachedVehicleSelection();
    if (cachedVehicle != null && mounted) {
      setState(() {
        lastSelectedVehicleId = cachedVehicle['vehicleId'];
        selectedVehicle = cachedVehicle['vehicleId'];
      });
      debugPrint(
        '✅ Last selected vehicle loaded: ${cachedVehicle['vehicleName']} (ID: ${cachedVehicle['vehicleId']})',
      );
    } else {
      debugPrint('ℹ️ No cached vehicle selection found');
    }
  }

  List<Vehicle> _getSortedAndFilteredVehicles(List<Vehicle> vehicles) {
    // Filter by search query
    var filtered = vehicles.where((vehicle) {
      final plate = vehicle.plateNumber.toLowerCase();
      final query = searchQuery.toLowerCase();
      return plate.contains(query);
    }).toList();

    // Sort: default vehicle first, then last selected, then others
    filtered.sort((a, b) {
      // Default vehicle always first
      if (a.id == defaultVehicleId) return -1;
      if (b.id == defaultVehicleId) return 1;

      // Then last selected vehicle
      if (a.id == lastSelectedVehicleId) return -1;
      if (b.id == lastSelectedVehicleId) return 1;

      return 0;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'select_vehicle'.tr(),
          style: context.font
              .semibold(context)
              .copyWith(fontSize: 18.sp, color: colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Vehicle>>(
          future: _vehiclesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                _isLoadingDefaults) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated vehicle icon
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeInOut,
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: 0.8 + (value * 0.2),
                          child: Opacity(
                            opacity: 0.3 + (value * 0.7),
                            child: Container(
                              padding: EdgeInsets.all(32.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primary.withValues(alpha: 0.2),
                                    colorScheme.secondary.withValues(
                                      alpha: 0.1,
                                    ),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.directions_car_rounded,
                                size: 80.sp,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 32.h),
                    // Loading indicator
                    SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Loading text with animation
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Column(
                            children: [
                              Text(
                                _isLoadingDefaults &&
                                        snapshot.connectionState !=
                                            ConnectionState.waiting
                                    ? 'Preparing your vehicle...'
                                    : 'Loading vehicles...',
                                style: context.font
                                    .semibold(context)
                                    .copyWith(
                                      fontSize: 16.sp,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Please wait a moment',
                                style: context.font
                                    .regular(context)
                                    .copyWith(
                                      fontSize: 13.sp,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(28.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withValues(alpha: 0.1),
                            Colors.red.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Failed to load vehicles',
                      style: context.font
                          .semibold(context)
                          .copyWith(
                            fontSize: 14.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: context.font
                          .regular(context)
                          .copyWith(
                            fontSize: 12.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _initializeVehicles();
                        });
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final vehicles = snapshot.data ?? [];
            final filteredVehicles = _getSortedAndFilteredVehicles(vehicles);

            return Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose your vehicle',
                        style: context.font
                            .semibold(context)
                            .copyWith(
                              fontSize: 16.sp,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        defaultVehicleId != null
                            ? 'Your assigned vehicle is pre-selected'
                            : lastSelectedVehicleId != null
                            ? 'Your last used vehicle is highlighted'
                            : 'Select the vehicle you want to use for today',
                        style: context.font
                            .regular(context)
                            .copyWith(
                              fontSize: 12.sp,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                      ),
                    ],
                  ),
                ),

                // Search bar and QR scan
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      // Search field
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() => searchQuery = value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search vehicle...',
                            hintStyle: context.font
                                .regular(context)
                                .copyWith(
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              size: 20.h,
                            ),
                            suffixIcon: searchQuery.isNotEmpty
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() => searchQuery = '');
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                      size: 20.h,
                                    ),
                                  )
                                : null,
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHigh
                                .withValues(alpha: 1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // QR Scan button
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              CustomSnackBar.show(
                                context,
                                message: 'QR scan coming soon',
                                type: SnackBarType.info,
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(10.h),
                              child: Icon(
                                Icons.qr_code_scanner,
                                color: colorScheme.primary,
                                size: 24.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vehicle list
                Expanded(
                  child: filteredVehicles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(28.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      colorScheme.primary.withValues(
                                        alpha: 0.05,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.directions_car_outlined,
                                  size: 64.sp,
                                  color: colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'No vehicles found',
                                style: context.font
                                    .semibold(context)
                                    .copyWith(
                                      fontSize: 14.sp,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: filteredVehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = filteredVehicles[index];
                            final isSelected = selectedVehicle == vehicle.id;
                            final isDefaultVehicle =
                                vehicle.id == defaultVehicleId;
                            final isLastSelected =
                                vehicle.id == lastSelectedVehicleId;

                            return Padding(
                              padding: EdgeInsets.only(bottom: 7.h),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => selectedVehicle = vehicle.id);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : colorScheme.surfaceContainerHigh,
                                    gradient: isSelected
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              colorScheme.primary.withValues(
                                                alpha: 0.01,
                                              ),
                                              colorScheme.primary.withValues(
                                                alpha: 0.05,
                                              ),
                                            ],
                                          )
                                        : isDefaultVehicle
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.green.withValues(
                                                alpha: 0.08,
                                              ),
                                              Colors.teal.withValues(
                                                alpha: 0.04,
                                              ),
                                            ],
                                          )
                                        : isLastSelected
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.amber.withValues(
                                                alpha: 0.08,
                                              ),
                                              Colors.orange.withValues(
                                                alpha: 0.04,
                                              ),
                                            ],
                                          )
                                        : LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              colorScheme.surfaceContainerHigh,
                                              colorScheme.surfaceContainerHigh,
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : isDefaultVehicle
                                          ? Colors.green.shade400
                                          : isLastSelected
                                          ? Colors.amber.shade300
                                          : colorScheme.outline.withValues(
                                              alpha: 0.1,
                                            ),
                                      width: isSelected
                                          ? 2
                                          : isDefaultVehicle || isLastSelected
                                          ? 1.5
                                          : 1,
                                    ),
                                    boxShadow: isDefaultVehicle && !isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.green.withValues(
                                                alpha: 0.25,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : isLastSelected && !isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.amber.withValues(
                                                alpha: 0.25,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : isSelected
                                        ? [
                                            BoxShadow(
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.05),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Column(
                                    children: [
                                      // Highlight badge for default or last selected
                                      if ((isDefaultVehicle ||
                                              isLastSelected) &&
                                          !isSelected)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 10.h,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10.w,
                                                  vertical: 6.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: isDefaultVehicle
                                                        ? [
                                                            Colors
                                                                .green
                                                                .shade400,
                                                            Colors
                                                                .teal
                                                                .shade400,
                                                          ]
                                                        : [
                                                            Colors
                                                                .amber
                                                                .shade400,
                                                            Colors
                                                                .orange
                                                                .shade400,
                                                          ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          (isDefaultVehicle
                                                                  ? Colors.green
                                                                  : Colors
                                                                        .amber)
                                                              .withValues(
                                                                alpha: 0.4,
                                                              ),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isDefaultVehicle
                                                          ? Icons
                                                                .check_circle_rounded
                                                          : Icons.star_rounded,
                                                      size: 14.h,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 5.w),
                                                    Text(
                                                      isDefaultVehicle
                                                          ? 'Assigned Vehicle'
                                                          : 'Last used',
                                                      style: context.font
                                                          .bold(context)
                                                          .copyWith(
                                                            fontSize: 11.sp,
                                                            color: Colors.white,
                                                            letterSpacing: 0.3,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          // Vehicle icon
                                          Container(
                                            width: 30.h,
                                            height: 30.h,
                                            decoration: BoxDecoration(
                                              color: colorScheme.secondary
                                                  .withValues(
                                                    alpha: isSelected
                                                        ? 0.15
                                                        : 0.1,
                                                  ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              CupertinoIcons.car_fill,
                                              color: colorScheme.secondary,
                                              size: 24.h,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),

                                          // Vehicle info
                                          Expanded(
                                            child: Text(
                                              "${vehicle.id} - ${vehicle.plateNumber}",
                                              style: context.font
                                                  .semibold(context)
                                                  .copyWith(
                                                    fontSize: 14.sp,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                            ),
                                          ),

                                          // Selection indicator
                                          if (isSelected)
                                            Container(
                                              width: 28.h,
                                              height: 28.h,
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color: colorScheme.onPrimary,
                                                size: 16.h,
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 28.h,
                                              height: 28.h,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: colorScheme.outline
                                                      .withValues(alpha: 0.3),
                                                  width: 1.5,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Continue button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: selectedVehicle != null
                          ? () async {
                              // Find selected vehicle data
                              final selectedVehicleData = vehicles.firstWhere(
                                (v) => v.id == selectedVehicle,
                              );

                              // Cache the selection
                              await _vehicleService.cacheSelectedVehicle(
                                vehicleId: selectedVehicleData.id,
                                vehicleName: selectedVehicleData.plateNumber,
                                plateNumber: selectedVehicleData.plateNumber,
                              );

                              if (mounted) {
                                context.push(
                                  '/pti',
                                  extra: {
                                    'vehicleId': selectedVehicleData.id,
                                    'vehicleName':
                                        selectedVehicleData.plateNumber,
                                    'plateNumber':
                                        selectedVehicleData.plateNumber,
                                  },
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        disabledBackgroundColor: colorScheme.primary.withValues(
                          alpha: 0.5,
                        ),
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'continue'.tr(),
                        style: context.font
                            .semibold(context)
                            .copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
