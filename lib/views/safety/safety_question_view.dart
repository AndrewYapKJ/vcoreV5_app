import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';

class SafetyQuestionView extends ConsumerStatefulWidget {
  final bool fromLogin;

  const SafetyQuestionView({super.key, this.fromLogin = true});

  @override
  ConsumerState<SafetyQuestionView> createState() => _SafetyQuestionViewState();
}

class _SafetyQuestionViewState extends ConsumerState<SafetyQuestionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  void _handleAgree() {
    context.push('/select-vehicle');
  }

  void _handleDisagree() async {
    // Clear all cache directly and navigate to login
    await LoginCacheService().clearCache();
    if (mounted) {
      // ignore: use_build_context_synchronously
      context.go('/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          Positioned(
            top: -100.h,
            right: -60.h,
            child: Container(
              width: 230.h,
              height: 230.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.15),
                    colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80.h,
            left: -100.h,
            child: Container(
              width: 500.h,
              height: 250.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.secondary.withValues(alpha: 0.1),
                    colorScheme.secondary.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Container(
              height: size.height,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  SizedBox(height: 50.h),
                  // Animated icon
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Container(
                      width: 80.h,
                      height: 80.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.amber.shade300.withValues(alpha: 0.25),
                            Colors.orange.shade200.withValues(alpha: 0.15),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.amber.shade300.withValues(alpha: 0.3),
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        Icons.error_rounded,
                        size: 60.h,
                        color: Colors.amber.shade600,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  // Title
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Safety Alert',
                          style: context.font
                              .semibold(context)
                              .copyWith(
                                fontSize: 24.sp,
                                color: colorScheme.primary,
                                letterSpacing: 1.5,
                              ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Road Safety Commitment',
                          style: context.font
                              .bold(context)
                              .copyWith(
                                fontSize: 18.sp,
                                color: Colors.black,
                                height: 1.1,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Language cards
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildBeautifulCard(
                          context,
                          colorScheme,
                          '🇬🇧 ENGLISH',
                          'By agreeing to this, you acknowledge and agree that you will adhere to the road safety regulations where ',
                          'you will ',
                          'NOT ',
                          'use or attempt to use this application while operating your vehicle(s).',
                        ),
                        SizedBox(height: 12.h),
                        _buildBeautifulCard(
                          context,
                          colorScheme,
                          '🇲🇾 MALAY',
                          'Anda bersetuju bahawa anda akan mematuhi peraturan keselamatan jalan raya dan ',
                          'anda ',
                          'TIDAK ',
                          'akan mengguna atau cuba menggunakan aplikasi ini semasa kenderaan bergerak.',
                        ),
                        SizedBox(height: 12.h),
                        _buildBeautifulCard(
                          context,
                          colorScheme,
                          '🇨🇳 CHINESE',
                          '您同意您将遵守道路安全法规，',
                          '',
                          '',
                          '在操作车辆时不会使用或尝试使用此应用程序。',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  // Buttons - only show if from login
                  if (widget.fromLogin)
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(
                                0.5,
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                      child: Row(
                        children: [
                          // Agree button
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primary.withValues(alpha: 0.85),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: TextButton.icon(
                                onPressed: _handleAgree,
                                icon: Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 24.h,
                                ),
                                label: Text(
                                  'Agree',
                                  style: context.font
                                      .bold(context)
                                      .copyWith(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Disagree button
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.red.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.red.shade50,
                              ),
                              child: TextButton.icon(
                                onPressed: _handleDisagree,
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: Colors.red.shade600,
                                  size: 24.h,
                                ),
                                label: Text(
                                  'Disagree',
                                  style: context.font
                                      .bold(context)
                                      .copyWith(
                                        fontSize: 14.sp,
                                        color: Colors.red.shade600,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!widget.fromLogin)
            SafeArea(
              child: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(
                  Platform.isIOS
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_back_rounded,
                  size: Theme.of(context).appBarTheme.iconTheme?.size ?? 24,
                  color: Colors.black,
                ),
              ),
            ),
          // Background gradient decoration
        ],
      ),
    );
  }

  Widget _buildBeautifulCard(
    BuildContext context,
    ColorScheme colorScheme,
    String language,
    String text1,
    String text2,
    String text3,
    String text4,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade50.withValues(alpha: 0.8),
            Colors.orange.shade50.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.red.shade200.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language badge
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade100, Colors.orange.shade100],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: Text(
              language,
              style: context.font
                  .bold(context)
                  .copyWith(fontSize: 10.sp, color: Colors.red.shade700),
            ),
          ),
          SizedBox(height: 8.h),
          // Text content
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              text: text1,
              style: context.font
                  .regular(context)
                  .copyWith(
                    fontSize: 13.sp,
                    color: Colors.black.withValues(alpha: 0.75),
                  ),
              children: [
                if (text2.isNotEmpty)
                  TextSpan(
                    text: text2,
                    style: context.font
                        .regular(context)
                        .copyWith(fontSize: 13.sp, color: Colors.red.shade600),
                  ),
                if (text3.isNotEmpty)
                  TextSpan(
                    text: text3,
                    style: context.font
                        .bold(context)
                        .copyWith(fontSize: 14.sp, color: Colors.red.shade700),
                  ),
                if (text4.isNotEmpty)
                  TextSpan(
                    text: text4,
                    style: context.font
                        .regular(context)
                        .copyWith(fontSize: 13.sp, color: Colors.red.shade600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
