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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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

            // Vehicle list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final isSelected = selectedVehicle == vehicle['id'];

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
                                    colorScheme.primary.withValues(alpha: 0.1),
                                    colorScheme.primary.withValues(alpha: 0.05),
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
                                : colorScheme.outline.withValues(alpha: 0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Vehicle icon
                            Container(
                              width: 50.h,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: colorScheme.secondary.withValues(
                                  alpha: isSelected ? 0.15 : 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicle['name'] as String,
                                    style: context.font
                                        .semibold(context)
                                        .copyWith(
                                          fontSize: 14.sp,
                                          color: colorScheme.onSurface,
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
                                    color: colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
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
