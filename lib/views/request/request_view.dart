import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';

class RequestView extends StatefulWidget {
  const RequestView({super.key});

  @override
  State<RequestView> createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView> {
  String? selectedJobType; // 'delivery' or 'collection'
  String? selectedSize; // '20', '40', or '60'
  final containerNoController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    containerNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.03),
                colorScheme.secondary.withValues(alpha: 0.03),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PM ID Section
                Container(
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PM ID',
                        style: context.font
                            .regular(context)
                            .copyWith(
                              fontSize: 11.sp,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'PM ID DUMMY',
                        style: context.font
                            .bold(context)
                            .copyWith(fontSize: 16.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Job Type Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Type',
                      style: context.font
                          .semibold(context)
                          .copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRadioOption(
                            context: context,
                            label: 'Delivery',
                            value: 'delivery',
                            groupValue: selectedJobType,
                            onChanged: (value) {
                              setState(() => selectedJobType = value);
                            },
                            colorScheme: colorScheme,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildRadioOption(
                            context: context,
                            label: 'Collection',
                            value: 'collection',
                            groupValue: selectedJobType,
                            onChanged: (value) {
                              setState(() => selectedJobType = value);
                            },
                            colorScheme: colorScheme,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Size Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Container Size',
                      style: context.font
                          .semibold(context)
                          .copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRadioOption(
                            context: context,
                            label: '20',
                            value: '20',
                            groupValue: selectedSize,
                            onChanged: (value) {
                              setState(() => selectedSize = value);
                            },
                            colorScheme: colorScheme,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildRadioOption(
                            context: context,
                            label: '40',
                            value: '40',
                            groupValue: selectedSize,
                            onChanged: (value) {
                              setState(() => selectedSize = value);
                            },
                            colorScheme: colorScheme,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildRadioOption(
                            context: context,
                            label: '60',
                            value: '60',
                            groupValue: selectedSize,
                            onChanged: (value) {
                              setState(() => selectedSize = value);
                            },
                            colorScheme: colorScheme,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Container No Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Container Number',
                      style: context.font
                          .semibold(context)
                          .copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: containerNoController,
                      decoration: InputDecoration(
                        hintText: 'Enter container number',
                        prefixIcon: Icon(
                          Icons.inventory_2_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 18.h,
                        ),
                        suffixIcon: Icon(
                          Icons.qr_code_2,
                          color: colorScheme.primary,
                          size: 20.h,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        isDense: true,
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        hintStyle: context.font
                            .regular(context)
                            .copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                      ),
                      style: context.font
                          .regular(context)
                          .copyWith(fontSize: 14.sp),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Request Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (selectedJobType != null &&
                                selectedSize != null &&
                                containerNoController.text.isNotEmpty) {
                              setState(() => isLoading = true);
                              Future.delayed(const Duration(seconds: 1), () {
                                if (mounted) {
                                  setState(() => isLoading = false);
                                  CustomSnackBar.showSuccess(
                                    context,
                                    message:
                                        'Job request submitted successfully!',
                                  );
                                  containerNoController.clear();
                                  setState(() {
                                    selectedJobType = null;
                                    selectedSize = null;
                                  });
                                }
                              });
                            } else {
                              CustomSnackBar.showWarning(
                                context,
                                message: 'Please fill all fields',
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: colorScheme.primary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Request',
                            style: context.font
                                .semibold(context)
                                .copyWith(
                                  fontSize: 16.sp,
                                  color: colorScheme.onPrimary,
                                ),
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required BuildContext context,
    required String label,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
    required ColorScheme colorScheme,
  }) {
    final isSelected = groupValue == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18.h,
              height: 18.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8.h,
                        height: 8.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: context.font
                  .medium(context)
                  .copyWith(
                    fontSize: 14.sp,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
