import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';

class SelectVehicleView extends StatefulWidget {
  const SelectVehicleView({super.key});

  @override
  State<SelectVehicleView> createState() => _SelectVehicleViewState();
}

class _SelectVehicleViewState extends State<SelectVehicleView> {
  String? selectedVehicle;
  String searchQuery = '';
  String? lastSelectedVehicleId;

  // Sample vehicle data
  final List<Map<String, dynamic>> vehicles = [
    {
      'id': 'VH001',
      'name': 'Toyota Hiace',
      'plateNumber': 'ABC 1234',
      'registrationYear': 2022,
      'icon': Icons.local_shipping,
    },
    {
      'id': 'VH002',
      'name': 'Proton Persona',
      'plateNumber': 'XYZ 5678',
      'registrationYear': 2021,
      'icon': Icons.directions_car,
    },
    {
      'id': 'VH003',
      'name': 'Nissan Van',
      'plateNumber': 'MNO 9012',
      'registrationYear': 2023,
      'icon': Icons.local_shipping,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLastSelectedVehicle();
  }

  Future<void> _loadLastSelectedVehicle() async {
    final cachedVehicle = await LoginCacheService().getCachedVehicleSelection();
    if (cachedVehicle != null && mounted) {
      setState(() {
        lastSelectedVehicleId = cachedVehicle['vehicleId'];
        selectedVehicle = cachedVehicle['vehicleId'];
      });
    }
  }

  List<Map<String, dynamic>> _getSortedAndFilteredVehicles() {
    // Filter by search query
    var filtered = vehicles.where((vehicle) {
      final name = vehicle['name'].toString().toLowerCase();
      final plate = vehicle['plateNumber'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || plate.contains(query);
    }).toList();

    // Sort: last selected vehicle first, then others
    filtered.sort((a, b) {
      if (a['id'] == lastSelectedVehicleId) return -1;
      if (b['id'] == lastSelectedVehicleId) return 1;
      return 0;
    });

    return filtered;
  }

  void _selectVehicleFromQR(String vehicleId) {
    final vehicle = vehicles.firstWhere((v) => v['id'] == vehicleId);
    setState(() => selectedVehicle = vehicle['id']);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredVehicles = _getSortedAndFilteredVehicles();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
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
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                  SizedBox(height: 6.h),
                  Text(
                    'Select the vehicle you want to use for today',
                    style: context.font
                        .regular(context)
                        .copyWith(
                          fontSize: 12.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),

            // Search bar and QR scan
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                        fillColor: colorScheme.surface.withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.1),
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
                          // TODO: Implement QR scan
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('QR scan coming soon'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: colorScheme.primary,
                            ),
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
                          Icon(
                            Icons.directions_car_outlined,
                            size: 48.h,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No vehicles found',
                            style: context.font
                                .regular(context)
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
                        final isSelected = selectedVehicle == vehicle['id'];
                        final isLastSelected =
                            vehicle['id'] == lastSelectedVehicleId;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedVehicle = vehicle['id']);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(14.h),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colorScheme.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          colorScheme.primary.withValues(
                                            alpha: 0.05,
                                          ),
                                        ],
                                      )
                                    : isLastSelected
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.amber.withValues(alpha: 0.08),
                                          Colors.orange.withValues(alpha: 0.04),
                                        ],
                                      )
                                    : LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colorScheme.surface,
                                          colorScheme.surface,
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : isLastSelected
                                      ? Colors.amber.shade300
                                      : colorScheme.outline.withValues(
                                          alpha: 0.1,
                                        ),
                                  width: isSelected
                                      ? 2
                                      : isLastSelected
                                      ? 1.5
                                      : 1,
                                ),
                                boxShadow: isLastSelected && !isSelected
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
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  // Highlight badge for last selected
                                  if (isLastSelected && !isSelected)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10.h),
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
                                                colors: [
                                                  Colors.amber.shade400,
                                                  Colors.orange.shade400,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.amber
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  size: 14.h,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 5.w),
                                                Text(
                                                  'Last used',
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
                                        width: 50.h,
                                        height: 50.h,
                                        decoration: BoxDecoration(
                                          color: colorScheme.secondary
                                              .withValues(
                                                alpha: isSelected ? 0.15 : 0.1,
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          vehicle['icon'] as IconData,
                                          color: colorScheme.secondary,
                                          size: 28.h,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),

                                      // Vehicle info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vehicle['name'] as String,
                                              style: context.font
                                                  .semibold(context)
                                                  .copyWith(
                                                    fontSize: 14.sp,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              '${vehicle['plateNumber']} • ${vehicle['registrationYear']}',
                                              style: context.font
                                                  .regular(context)
                                                  .copyWith(
                                                    fontSize: 11.sp,
                                                    color: colorScheme.onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                            ),
                                          ],
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: selectedVehicle != null
                      ? () async {
                          // Find selected vehicle data
                          final selectedVehicleData = vehicles.firstWhere(
                            (v) => v['id'] == selectedVehicle,
                          );
                          // Cache vehicle selection
                          await LoginCacheService().cacheVehicleSelection(
                            vehicleId: selectedVehicleData['id'] as String,
                            vehicleName: selectedVehicleData['name'] as String,
                            plateNumber:
                                selectedVehicleData['plateNumber'] as String,
                          );

                          // Navigate to PTI
                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            context.push('/pti');
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
        ),
      ),
    );
  }
}
