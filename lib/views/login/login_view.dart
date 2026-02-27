import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vcore_v5_app/controllers/login_controller.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/widgets/theme_changer.dart';
import 'package:vcore_v5_app/widgets/theme_mode.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(loginControllerProvider);
    final notifier = ref.read(loginControllerProvider.notifier);

    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(loginControllerProvider, (prev, next) {
      if (next.success) {
        context.go('/jobs');
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              children: [
                // Top toolbar with theme controls

                // Header Section
                Column(
                  children: [
                    Image.asset(
                      'assets/images/Gussmann-logo-web.png',
                      height: 120.h,
                    ),
                    Text(
                      'Welcome Back',
                      style: context.font
                          .bold(context)
                          .copyWith(fontSize: 32.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to your account',
                      style: context.font.copyWith(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                // Form Section
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Email Field
                      _buildModernTextField(
                        context: context,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        onChanged: notifier.setUserId,
                        errorText: login.userId.isEmpty ? "Required" : null,
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
                        errorText: login.password.length < 6
                            ? "Min 6 characters"
                            : null,
                        colorScheme: colorScheme,
                      ),
                      SizedBox(height: 12.h),
                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: login.rememberMe,
                            onChanged: (b) {
                              if (b != null) {
                                notifier.toggleRememberMe(b);
                              }
                            },
                            side: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.5),
                            ),
                            fillColor: MaterialStatePropertyAll(
                              colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Remember me',
                            style: context.font.copyWith(fontSize: 14.sp),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      // Error Message
                      if (login.errorMessage != null)
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
                                  login.errorMessage!,
                                  style: context.font.copyWith(
                                    fontSize: 12.sp,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (login.errorMessage != null) SizedBox(height: 16.h),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: login.isLoading
                              ? null
                              : () => notifier.login(),
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
                          child: login.isLoading
                              ? CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                  strokeWidth: 2,
                                )
                              : Text(
                                  'Sign In',
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
                      // Forgot Password Link
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                        child: Text(
                          'Forgot your password?',
                          style: context.font
                              .medium(context)
                              .copyWith(
                                fontSize: 13.sp,
                                color: colorScheme.primary,
                              ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: context.font
                                .regular(context)
                                .copyWith(fontSize: 13.sp),
                          ),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'Sign Up',
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
          style: context.font.copyWith(
            fontSize: 14.sp,
            color: colorScheme.onSurface,
          ),
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
            hintStyle: context.font.copyWith(
              fontSize: 14.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            errorText: errorText,
            errorStyle: context.font.copyWith(
              fontSize: 11.sp,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
