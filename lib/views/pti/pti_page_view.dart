import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';

class PTIPageView extends StatefulWidget {
  const PTIPageView({super.key});

  @override
  State<PTIPageView> createState() => _PTIPageViewState();
}

class _PTIPageViewState extends State<PTIPageView> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> ptiChecks = [
    {
      'title': 'Vehicle Inspection',
      'description': 'Comprehensive vehicle safety check',
      'icon': Icons.directions_car,
      'items': ['Brakes', 'Lights', 'Wipers', 'Horn', 'Tires'],
    },
    {
      'title': 'Documentation',
      'description': 'Verify all required documents',
      'icon': Icons.description,
      'items': ['Insurance', 'License', 'Registration', 'Fitness', 'Tax'],
    },
    {
      'title': 'Final Approval',
      'description': 'Confirm you are ready to start',
      'icon': Icons.check_circle,
      'items': [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentPage < ptiChecks.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Show completion dialog
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success checkmark
                  Container(
                    width: 80.h,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.withValues(alpha: 0.2),
                          Colors.green.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 40.h,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    'PTI Completed!',
                    style: context.font
                        .bold(context)
                        .copyWith(
                          fontSize: 20.sp,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 8.h),

                  // Description
                  Text(
                    'All checks have been verified.\nYou are ready to start your day.',
                    textAlign: TextAlign.center,
                    style: context.font
                        .regular(context)
                        .copyWith(
                          fontSize: 14.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),
                  SizedBox(height: 32.h),

                  // Skip button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Cache PTI completion status
                        await LoginCacheService().cachePTIStatus(
                          isCompleted: true,
                        );

                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          // ignore: use_build_context_synchronously
                          context.go('/jobs');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: context.font
                            .semibold(context)
                            .copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Redo button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _currentPage = 0;
                        _pageController.jumpToPage(0);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Re-do PTI',
                        style: context.font
                            .semibold(context)
                            .copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.primary,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'PTI Checklist'.tr(),
          style: context.font
              .semibold(context)
              .copyWith(fontSize: 18.sp, color: colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Step ${_currentPage + 1} of ${ptiChecks.length}',
                        style: context.font
                            .regular(context)
                            .copyWith(
                              fontSize: 12.sp,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                      ),
                      Text(
                        '${((_currentPage + 1) / ptiChecks.length * 100).toStringAsFixed(0)}%',
                        style: context.font
                            .semibold(context)
                            .copyWith(
                              fontSize: 12.sp,
                              color: colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / ptiChecks.length,
                      minHeight: 6.h,
                      backgroundColor: colorScheme.outline.withValues(
                        alpha: 0.1,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ptiChecks.length,
                itemBuilder: (context, index) {
                  final check = ptiChecks[index];
                  return _buildCheckPage(context, colorScheme, check);
                },
              ),
            ),

            // Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == ptiChecks.length - 1 ? 'Complete' : 'Next',
                    style: context.font
                        .semibold(context)
                        .copyWith(
                          fontSize: 14.sp,
                          color: colorScheme.onPrimary,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckPage(
    BuildContext context,
    ColorScheme colorScheme,
    Map<String, dynamic> check,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 80.h,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.tertiary.withValues(alpha: 0.2),
                    colorScheme.tertiary.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: colorScheme.tertiary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                check['icon'] as IconData,
                size: 40.h,
                color: colorScheme.tertiary,
              ),
            ),
            SizedBox(height: 24.h),

            // Title
            Text(
              check['title'] as String,
              style: context.font
                  .bold(context)
                  .copyWith(fontSize: 22.sp, color: colorScheme.onSurface),
            ),
            SizedBox(height: 8.h),

            // Description
            Text(
              check['description'] as String,
              style: context.font
                  .regular(context)
                  .copyWith(
                    fontSize: 14.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            SizedBox(height: 32.h),

            // Items list
            if ((check['items'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items to check:',
                    style: context.font
                        .semibold(context)
                        .copyWith(
                          fontSize: 14.sp,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  ...(check['items'] as List<String>).map((item) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          Container(
                            width: 28.h,
                            height: 28.h,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16.h,
                              color: colorScheme.secondary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            item,
                            style: context.font
                                .regular(context)
                                .copyWith(
                                  fontSize: 14.sp,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              )
            else
              // Final approval
              Container(
                padding: EdgeInsets.all(16.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.withValues(alpha: 0.1),
                      Colors.green.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.verified, size: 40.h, color: Colors.green),
                    SizedBox(height: 12.h),
                    Text(
                      'All checks completed',
                      textAlign: TextAlign.center,
                      style: context.font
                          .semibold(context)
                          .copyWith(
                            fontSize: 16.sp,
                            color: Colors.green.shade700,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'You are all set to start your day',
                      textAlign: TextAlign.center,
                      style: context.font
                          .regular(context)
                          .copyWith(
                            fontSize: 13.sp,
                            color: Colors.green.shade600,
                          ),
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
