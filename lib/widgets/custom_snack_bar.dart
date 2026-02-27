import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';

enum SnackBarType { success, error, info, warning }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    late IconData icon;
    late Color backgroundColor;
    late Color iconColor;
    late Color textColor;

    switch (type) {
      case SnackBarType.success:
        icon = Icons.check_circle_outline;
        backgroundColor = Colors.green.shade50;
        iconColor = Colors.green;
        textColor = Colors.green.shade900;
        break;
      case SnackBarType.error:
        icon = Icons.error_outline;
        backgroundColor = Colors.red.shade50;
        iconColor = Colors.red;
        textColor = Colors.red.shade900;
        break;
      case SnackBarType.warning:
        icon = Icons.warning_outlined;
        backgroundColor = Colors.amber.shade50;
        iconColor = Colors.amber.shade700;
        textColor = Colors.amber.shade900;
        break;
      case SnackBarType.info:
        icon = Icons.info_outline;
        backgroundColor = colorScheme.secondary.withValues(alpha: 0.1);
        iconColor = colorScheme.secondary;
        textColor = colorScheme.onSurface;
        break;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20.h),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: iconColor.withValues(alpha: 0.2), width: 1),
        ),
        duration: duration,
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }
}
