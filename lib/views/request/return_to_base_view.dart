import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';

class ReturnToBaseView extends StatefulWidget {
  const ReturnToBaseView({super.key});

  @override
  State<ReturnToBaseView> createState() => _ReturnToBaseViewState();
}

class _ReturnToBaseViewState extends State<ReturnToBaseView> {
  final _formKey = GlobalKey<FormState>();
  final trailerController = TextEditingController();
  final stagingYardController = TextEditingController();
  final remarksController = TextEditingController();
  bool isLoading = false;

  String driverName = 'Mohd Shahren'; // From cached data
  String pmId = 'TTK_125 (TTK125_JTL8243)'; // From cached data

  @override
  void dispose() {
    trailerController.dispose();
    stagingYardController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  Future<String?> _scanQRCode() async {
    CustomSnackBar.showInfo(context, message: 'QR Scanner - Coming Soon');
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => isLoading = false);
          CustomSnackBar.showSuccess(
            context,
            message: 'Return to base request submitted',
          );
          trailerController.clear();
          stagingYardController.clear();
          remarksController.clear();
        }
      });
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
            color: colorScheme.surface,
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
            fillColor: colorScheme.surface,
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
                        'Return to Base',
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
          'Return to Base',
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
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            margin: EdgeInsets.only(bottom: 20.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  _buildInputField(
                    'Trailer ID',
                    trailerController,
                    hint: 'Enter or scan trailer ID',
                    prefixIcon: Icons.local_shipping_outlined,
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: IconButton(
                        icon: Icon(
                          Icons.qr_code_2,
                          color: colorScheme.primary,
                          size: 20.h,
                        ),
                        onPressed: _scanQRCode,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildInputField(
                    'Staging Yard',
                    stagingYardController,
                    hint: 'Enter or select staging yard',
                    prefixIcon: Icons.location_on_outlined,
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
}
