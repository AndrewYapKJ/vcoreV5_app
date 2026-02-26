import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:vcore_v5_app/core/font_styling.dart';

class RegistrationSuccessView extends StatefulWidget {
  const RegistrationSuccessView({super.key});

  @override
  State<RegistrationSuccessView> createState() =>
      _RegistrationSuccessViewState();
}

class _RegistrationSuccessViewState extends State<RegistrationSuccessView>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize scale animation for the checkmark
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _scaleController.forward();

    // Navigate back to login after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Success Checkmark
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(Icons.check, size: 50, color: Colors.white),
                ),
              ),
              SizedBox(height: 32.h),
              // Success Title
              Text(
                'Registration Successful!',
                style: context.font.bold(context).copyWith(fontSize: 28.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              // Success Message
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'Your account has been created successfully.\nRedirecting to login...',
                  style: context.font
                      .regular(context)
                      .copyWith(
                        fontSize: 14.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40.h),
              // Loading Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
