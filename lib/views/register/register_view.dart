import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:vcore_v5_app/controllers/register_controller.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/views/register/registration_success_view.dart';

class RegisterView extends ConsumerWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final register = ref.watch(registerControllerProvider);
    final notifier = ref.read(registerControllerProvider.notifier);

    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(registerControllerProvider, (prev, next) {
      if (next.success) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RegistrationSuccessView()),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text(
                  'create_account'.tr(),
                  style: context.font.bold(context).copyWith(fontSize: 32.sp),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8.h),
                Text(
                  'join_us_started'.tr(),
                  style: context.font
                      .regular(context)
                      .copyWith(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 16.h),
                // Form Section
                Column(
                  children: [
                    // Full Name Field
                    _buildModernTextField(
                      context: context,
                      label: 'full_name'.tr(),
                      icon: Icons.person_outline,
                      onChanged: notifier.setFullName,
                      errorText: register.fullName.isEmpty
                          ? 'required'.tr()
                          : null,
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 16.h),
                    // Email Field
                    _buildModernTextField(
                      context: context,
                      label: 'email_address'.tr(),
                      icon: Icons.email_outlined,
                      onChanged: notifier.setEmail,
                      errorText:
                          register.email.isNotEmpty && !register.isValidEmail
                          ? 'invalid_email'.tr()
                          : (register.email.isEmpty ? 'required'.tr() : null),
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 16.h),
                    // Password Field
                    _buildModernTextField(
                      context: context,
                      label: 'password'.tr(),
                      icon: Icons.lock_outline,
                      obscure: true,
                      onChanged: notifier.setPassword,
                      errorText:
                          register.password.isNotEmpty &&
                              !register.isPasswordStrong
                          ? 'min_password_requirements'.tr()
                          : (register.password.isEmpty
                                ? 'required'.tr()
                                : null),
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 16.h),
                    // Confirm Password Field
                    _buildModernTextField(
                      context: context,
                      label: 'confirm_password'.tr(),
                      icon: Icons.lock_outline,
                      obscure: true,
                      onChanged: notifier.setConfirmPassword,
                      errorText:
                          register.confirmPassword.isNotEmpty &&
                              !register.isPasswordMatch
                          ? 'passwords_dont_match'.tr()
                          : (register.confirmPassword.isEmpty
                                ? 'required'.tr()
                                : null),
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 16.h),
                    // Terms and Conditions Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: register.agreeToTerms,
                          onChanged: (b) {
                            if (b != null) {
                              notifier.setAgreeToTerms(b);
                            }
                          },
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          fillColor: MaterialStatePropertyAll(
                            colorScheme.primary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'agree_to_terms'.tr(),
                            style: context.font
                                .regular(context)
                                .copyWith(fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    // Error Message
                    if (register.errorMessage != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 18.h,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                register.errorMessage!,
                                style: context.font
                                    .regular(context)
                                    .copyWith(
                                      fontSize: 12.sp,
                                      color: Colors.red,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (register.errorMessage != null) SizedBox(height: 16.h),
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: register.isLoading || !register.isValid
                            ? null
                            : () => notifier.register(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: colorScheme.primary
                              .withValues(alpha: 0.5),
                        ),
                        child: register.isLoading
                            ? CircularProgressIndicator(
                                color: colorScheme.onPrimary,
                                strokeWidth: 2,
                              )
                            : Text(
                                'sign_up_button'.tr(),
                                style: context.font
                                    .semibold(context)
                                    .copyWith(
                                      fontSize: 16.sp,
                                      color: colorScheme.onPrimary,
                                    ),
                              ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'already_have_account'.tr(),
                          style: context.font
                              .regular(context)
                              .copyWith(fontSize: 13.sp),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.secondary,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'sign_in'.tr(),
                            style: context.font
                                .semibold(context)
                                .copyWith(
                                  fontSize: 13.sp,
                                  color: colorScheme.secondary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required BuildContext context,
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    String? errorText,
    bool obscure = false,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.font
              .medium(context)
              .copyWith(fontSize: 13.sp, color: colorScheme.onSurface),
        ),
        SizedBox(height: 6.h),
        TextField(
          obscureText: obscure,
          onChanged: onChanged,
          style: context.font
              .regular(context)
              .copyWith(fontSize: 14.sp, color: colorScheme.onSurface),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 18.h,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
            isDense: true,
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colorScheme.secondary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.red.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            hintStyle: context.font
                .regular(context)
                .copyWith(
                  fontSize: 14.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
            errorText: errorText,
            errorStyle: context.font
                .regular(context)
                .copyWith(fontSize: 11.sp, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
