import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text(
                  'Create Account',
                  style: context.font.bold(context).copyWith(fontSize: 32.sp),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Join us to get started',
                  style: context.font
                      .regular(context)
                      .copyWith(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 32.h),
                // Form Section
                Column(
                  children: [
                    // Full Name Field
                    _buildModernTextField(
                      context: context,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      onChanged: notifier.setFullName,
                      errorText: register.fullName.isEmpty ? "Required" : null,
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 16.h),
                    // Email Field
                    _buildModernTextField(
                      context: context,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      onChanged: notifier.setEmail,
                      errorText:
                          register.email.isNotEmpty && !register.isValidEmail
                          ? "Invalid email"
                          : (register.email.isEmpty ? "Required" : null),
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 16.h),
                    // Password Field
                    _buildModernTextField(
                      context: context,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscure: true,
                      onChanged: notifier.setPassword,
                      errorText:
                          register.password.isNotEmpty &&
                              !register.isPasswordStrong
                          ? "Min 6 chars, 1 uppercase, 1 number"
                          : (register.password.isEmpty ? "Required" : null),
                      colorScheme: colorScheme,
                    ),
                    SizedBox(height: 16.h),
                    // Confirm Password Field
                    _buildModernTextField(
                      context: context,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscure: true,
                      onChanged: notifier.setConfirmPassword,
                      errorText:
                          register.confirmPassword.isNotEmpty &&
                              !register.isPasswordMatch
                          ? "Passwords don't match"
                          : (register.confirmPassword.isEmpty
                                ? "Required"
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
                            'I agree to the Terms and Conditions',
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
                                'Create Account',
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
                          'Already have an account? ',
                          style: context.font
                              .regular(context)
                              .copyWith(fontSize: 13.sp),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Sign In',
                            style: context.font
                                .semibold(context)
                                .copyWith(
                                  fontSize: 13.sp,
                                  color: colorScheme.primary,
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
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
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
