import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:vcore_v5_app/constant/font_styling.dart';

class IncentiveReportView extends StatefulWidget {
  const IncentiveReportView({super.key});

  @override
  State<IncentiveReportView> createState() => _IncentiveReportViewState();
}

class _IncentiveReportViewState extends State<IncentiveReportView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            // Custom TabBar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildCustomTabBar(context, colorScheme),
            ),
            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Today Tab
                  _buildPeriodTab(context, colorScheme, 'Today', 'RM 0.00'),
                  // This Month Tab
                  _buildPeriodTab(
                    context,
                    colorScheme,
                    'This Month',
                    'RM 0.00',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(4.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _tabController.index == 0
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Today',
                    style: context.font
                        .medium(context)
                        .copyWith(
                          fontSize: 12.sp,
                          color: _tabController.index == 0
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _tabController.index == 1
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'This Month',
                    style: context.font
                        .medium(context)
                        .copyWith(
                          fontSize: 12.sp,
                          color: _tabController.index == 1
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(
    BuildContext context,
    ColorScheme colorScheme,
    String period,
    String amount,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Section
          _buildSectionHeader(context, colorScheme, 'Summary'),
          SizedBox(height: 12.h),

          // Period Stats
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.tertiary.withValues(alpha: 0.15),
                  colorScheme.tertiary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.tertiary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: context.font
                      .regular(context)
                      .copyWith(
                        fontSize: 11.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
                SizedBox(height: 6.h),
                Text(
                  amount,
                  style: context.font
                      .semibold(context)
                      .copyWith(fontSize: 16.sp, color: colorScheme.tertiary),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Breakdown Section
          _buildSectionHeader(context, colorScheme, 'Breakdown'),
          SizedBox(height: 12.h),

          // Estimated Incentive Row
          _buildIncentiveRow(
            context,
            colorScheme,
            'Estimated Incentive',
            '0.00',
            'RM 0.00',
            Icons.trending_up_outlined,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
  ) {
    return Text(
      title,
      style: context.font
          .semibold(context)
          .copyWith(fontSize: 14.sp, color: colorScheme.onSurface),
    );
  }



  Widget _buildIncentiveRow(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
    String count,
    String amount,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.secondary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.h,
            height: 36.h,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18.h, color: colorScheme.secondary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.font
                      .regular(context)
                      .copyWith(fontSize: 12.sp, color: colorScheme.onSurface),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Count: $count',
                  style: context.font
                      .regular(context)
                      .copyWith(
                        fontSize: 10.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: context.font
                .semibold(context)
                .copyWith(fontSize: 12.sp, color: colorScheme.secondary),
          ),
        ],
      ),
    );
  }

}
