import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
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
        context.go('/dashboard');
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Spacer(),
            Icon(Icons.g_mobiledata, size: 240.h, color: Colors.white),
            Spacer(),
            ThemeChanger(),
            ThemeModeToggle(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24.w,
                12.h,
                24.w,
                12.h + MediaQuery.of(context).viewInsets.bottom + 12.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    onChanged: notifier.setUserId,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      labelStyle: context.font
                          .semibold(context)
                          .copyWith(fontSize: 14.sp),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        // color: Theme.of(context).colorScheme.surface,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.2,
                          // color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.5,
                          // color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1.2, color: Colors.red),
                      ),
                      errorText: login.userId.isEmpty ? "Required" : null,
                      errorStyle: context.font
                          .mediumError(context)
                          .copyWith(fontSize: 12.sp),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  TextField(
                    obscureText: true,
                    onChanged: notifier.setPassword,
                    style: context.font.copyWith(fontSize: 14.sp),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: context.font
                          .semibold(context)
                          .copyWith(fontSize: 14.sp),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        // color: Theme.of(context).colorScheme.surface,
                      ),
                      suffixIcon: Icon(
                        Icons.visibility_off_outlined,
                        // color: Theme.of(context).colorScheme.surface,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.2,
                          // color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.5,
                          // color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1.2, color: Colors.red),
                      ),
                      errorText: login.password.length < 6
                          ? "Min 6 chars"
                          : null,
                      errorStyle: context.font
                          .mediumError(context)
                          .copyWith(fontSize: 12.sp),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 0,
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Row(
                    children: [
                      Checkbox(
                        value: login.rememberMe,
                        onChanged: (b) {
                          if (b != null) {
                            notifier.toggleRememberMe(b);
                          }
                        },
                      ),
                      Text(
                        "Remember Me",
                        style: context.font
                            .semibold(context)
                            .copyWith(fontSize: 13.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login.isLoading
                          ? null
                          : () => notifier.login(),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: colorScheme.primary,
                        elevation: 0,
                      ),
                      child: login.isLoading
                          ? CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2.2,
                            )
                          : Text(
                              'Login',
                              style: context.font
                                  .semibold(context)
                                  .copyWith(fontSize: 14.sp),
                            ),
                    ),
                  ),
                  if (login.errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        login.errorMessage!,
                        style: context.font
                            .medium(context)
                            .copyWith(fontSize: 13.sp),
                      ),
                    ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: Text(
                          'Forgot password?',
                          // style: context.font
                          //     .medium(context)
                          //     .copyWith(fontSize: 13.sp),
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
    );
  }
}
