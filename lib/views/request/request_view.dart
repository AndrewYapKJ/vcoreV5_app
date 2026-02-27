import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';

// Sample data for dropdowns
final List<String> Function(BuildContext) getTrailerOptions = (context) => [
  'flatbed'.tr(),
  'refrigerated'.tr(),
  'tanker'.tr(),
  'cargo_van'.tr(),
  'enclosed'.tr(),
  'open_deck'.tr(),
  'side_loader'.tr(),
];

final List<String> Function(BuildContext) getVehicleOptions = (context) => [
  '1 Vehicle',
  '2 Vehicles',
  '3 Vehicles',
  '4 Vehicles',
  '5+ Vehicles',
];

class RequestView extends StatefulWidget {
  const RequestView({super.key});

  @override
  State<RequestView> createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView> {
  String? selectedJobType; // 'delivery' or 'collection'
  String? selectedSize; // '20', '40', or '60'
  String? selectedTrailer; // trailer type
  String? selectedVehicles; // vehicle count
  final containerNoController = TextEditingController();
  final trailerController = TextEditingController();
  final vehiclesController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    containerNoController.dispose();
    trailerController.dispose();
    vehiclesController.dispose();
    super.dispose();
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            margin: EdgeInsets.only(bottom: 60.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PM ID Section - Enhanced Card
                // Container(
                //   width: double.infinity,
                //   padding: EdgeInsets.all(16.h),
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       colors: [
                //         colorScheme.primary.withValues(alpha: 0.08),
                //         colorScheme.primary.withValues(alpha: 0.03),
                //       ],
                //     ),
                //     borderRadius: BorderRadius.circular(16),
                //     border: Border.all(
                //       color: colorScheme.primary.withValues(alpha: 0.15),
                //       width: 1,
                //     ),
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Row(
                //         children: [
                //           Container(
                //             padding: EdgeInsets.all(8.h),
                //             decoration: BoxDecoration(
                //               color: colorScheme.primary.withValues(alpha: 0.15),
                //               borderRadius: BorderRadius.circular(10),
                //             ),
                //             child: Icon(
                //               Icons.badge_outlined,
                //               color: colorScheme.primary,
                //               size: 20.h,
                //             ),
                //           ),
                //           SizedBox(width: 12.w),
                //           // Expanded(
                //           //   child: Column(
                //           //     crossAxisAlignment: CrossAxisAlignment.start,
                //           //     children: [
                //           //       Text(
                //           //         'Your PM ID',
                //           //         style: context.font
                //           //             .regular(context)
                //           //             .copyWith(
                //           //               fontSize: 12.sp,
                //           //               color: colorScheme.onSurface.withValues(
                //           //                 alpha: 0.6,
                //           //               ),
                //           //               letterSpacing: 0.3,
                //           //             ),
                //           //       ),
                //           //       SizedBox(height: 4.h),
                //           //       Text(
                //           //         'PM ID DUMMY',
                //           //         style: context.font
                //           //             .bold(context)
                //           //             .copyWith(
                //           //               fontSize: 18.sp,
                //           //               color: colorScheme.primary,
                //           //             ),
                //           //       ),
                //           //     ],
                //           //   ),
                //           // ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: 28.h),

                // Job Type Section - Enhanced
                _buildSectionLabel(
                  context,
                  'job_type'.tr(),
                  Icons.work_outline,
                ),
                SizedBox(height: 8.h),
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
                          setState(() => selectedJobType = value);
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
                          setState(() => selectedJobType = value);
                        },
                        colorScheme: colorScheme,
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
                SizedBox(height: 8.h),
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
                          setState(() => selectedSize = value);
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
                          setState(() => selectedSize = value);
                        },
                        colorScheme: colorScheme,
                        compact: true,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildRadioOption(
                        context: context,
                        label: '60\'',
                        value: '60',
                        icon: Icons.crop_din,
                        groupValue: selectedSize,
                        onChanged: (value) {
                          setState(() => selectedSize = value);
                        },
                        colorScheme: colorScheme,
                        compact: true,
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
                SizedBox(height: 12.h),
                _buildModernTextField(
                  context: context,
                  controller: containerNoController,
                  hint: 'Enter or scan container number',
                  prefixIcon: Icons.inventory_2_outlined,
                  suffixIcon: Icons.qr_code_2,
                  colorScheme: colorScheme,
                ),
                SizedBox(height: 20.h),

                // Trailer Section - Enhanced with Typeahead
                _buildSectionLabel(
                  context,
                  'trailer'.tr(),
                  Icons.directions_car,
                ),
                SizedBox(height: 12.h),
                _buildTypeaheadField(
                  context: context,
                  controller: trailerController,
                  options: getTrailerOptions(context),
                  hint: 'Search trailer type',
                  icon: Icons.local_shipping_outlined,
                  onSelected: (value) {
                    setState(() {
                      selectedTrailer = value;
                      trailerController.text = value;
                    });
                  },
                  colorScheme: colorScheme,
                ),
                SizedBox(height: 20.h),

                // Vehicles Section - Enhanced with Typeahead
                _buildSectionLabel(
                  context,
                  'vehicles'.tr(),
                  Icons.directions_bus,
                ),
                SizedBox(height: 12.h),
                _buildTypeaheadField(
                  context: context,
                  controller: vehiclesController,
                  options: getVehicleOptions(context),
                  hint: 'Search vehicle count',
                  icon: Icons.directions_car_filled,
                  onSelected: (value) {
                    setState(() {
                      selectedVehicles = value;
                      vehiclesController.text = value;
                    });
                  },
                  colorScheme: colorScheme,
                ),
                SizedBox(height: 36.h),

                // Request Button - Enhanced
                Container(
                  width: double.infinity,
                  height: 52.h,
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
                          : () {
                              if (selectedJobType != null &&
                                  selectedSize != null &&
                                  selectedTrailer != null &&
                                  selectedVehicles != null &&
                                  containerNoController.text.isNotEmpty) {
                                setState(() => isLoading = true);
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (mounted) {
                                    setState(() => isLoading = false);
                                    CustomSnackBar.showSuccess(
                                      context,
                                      message: 'request_submitted'.tr(),
                                    );
                                    containerNoController.clear();
                                    setState(() {
                                      selectedJobType = null;
                                      selectedSize = null;
                                      selectedTrailer = null;
                                      selectedVehicles = null;
                                    });
                                  }
                                });
                              } else {
                                CustomSnackBar.showWarning(
                                  context,
                                  message: 'Please fill all fields'.tr(),
                                );
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
                SizedBox(height: 20.h),
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
        suffixIcon: Icon(
          suffixIcon,
          color: colorScheme.primary.withValues(alpha: 0.7),
          size: 18.h,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        isDense: true,
        filled: true,
        fillColor: colorScheme.surface,
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
        hintStyle: context.font
            .regular(context)
            .copyWith(
              fontSize: 14.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
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
          color: isSelected ? null : colorScheme.surface,
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

  Widget _buildTypeaheadField({
    required BuildContext context,
    required TextEditingController controller,
    required List<String> options,
    required String hint,
    required IconData icon,
    required Function(String) onSelected,
    required ColorScheme colorScheme,
  }) {
    return TypeAheadField<String?>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: colorScheme.primary.withValues(alpha: 0.6),
            size: 18.h,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    setState(() {
                      if (hint.contains('trailer')) {
                        selectedTrailer = null;
                      } else {
                        selectedVehicles = null;
                      }
                    });
                  },
                  child: Icon(
                    Icons.clear,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    size: 18.h,
                  ),
                )
              : Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  size: 20.h,
                ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          isDense: true,
          filled: true,
          fillColor: colorScheme.surface,
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
          hintStyle: context.font
              .regular(context)
              .copyWith(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
        ),
        style: context.font.regular(context).copyWith(fontSize: 14.sp),
        onChanged: (value) {
          setState(() {});
        },
      ),

      suggestionsCallback: (pattern) {
        return options.where((option) {
          return option.toLowerCase().contains(pattern.toLowerCase());
        }).toList();
      },
      itemBuilder: (context, suggestion) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: colorScheme.primary,
                  size: 16.h,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                suggestion ?? "",
                style: context.font
                    .regular(context)
                    .copyWith(fontSize: 14.sp, color: colorScheme.onSurface),
              ),
            ],
          ),
        );
      },
      noItemsFoundBuilder: (context) {
        return Padding(
          padding: EdgeInsets.all(12.h),
          child: Text(
            'No matches found',
            style: context.font
                .regular(context)
                .copyWith(
                  fontSize: 12.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
        );
      },
      hideOnEmpty: false,
      hideOnLoading: false,
      debounceDuration: const Duration(milliseconds: 300),
      onSuggestionSelected: (suggestion) {
        controller.text = suggestion ?? "";
        onSelected(suggestion ?? "");
      },
    );
  }
}
