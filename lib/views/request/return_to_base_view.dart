import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:vcore_v5_app/core/font_styling.dart';

class ReturnToBaseView extends StatefulWidget {
  const ReturnToBaseView({super.key});

  @override
  State<ReturnToBaseView> createState() => _ReturnToBaseViewState();
}

class _ReturnToBaseViewState extends State<ReturnToBaseView> {
  final _formKey = GlobalKey<FormState>();
  String? selectedReason;
  final reasonsController = TextEditingController();

  final List<String> reasons = [
    'Completed All Deliveries',
    'Vehicle Malfunction',
    'Emergency',
    'End of Shift',
    'Others',
  ];

  @override
  void dispose() {
    reasonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'return_to_base'.tr(),
          style: context.font
              .bold(context)
              .copyWith(fontSize: 20.sp, color: colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Information Card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 24.h),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'You are requesting to return to the base station.',
                          style: context.font
                              .regular(context)
                              .copyWith(fontSize: 13.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Reason Section
                Text(
                  'Reason for Return',
                  style: context.font
                      .semibold(context)
                      .copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: DropdownButtonFormField<String>(
                      value: selectedReason,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Select a reason',
                      ),
                      items: reasons.map((String reason) {
                        return DropdownMenuItem<String>(
                          value: reason,
                          child: Text(reason),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a reason';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Additional Details
                Text(
                  'Additional Details',
                  style: context.font
                      .semibold(context)
                      .copyWith(fontSize: 16.sp),
                ),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextFormField(
                    controller: reasonsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12.w),
                      hintText: 'Provide additional details if needed',
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle form submission
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Return to base request submitted'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Submit Return Request',
                      style: context.font
                          .bold(context)
                          .copyWith(
                            fontSize: 16.sp,
                            color: colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
