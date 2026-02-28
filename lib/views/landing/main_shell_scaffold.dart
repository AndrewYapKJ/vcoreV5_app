import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vcore_v5_app/core/font_styling.dart';

class MainShellScaffold extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainShellScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainShellScaffold> createState() => _MainShellScaffoldState();
}

class _MainShellScaffoldState extends State<MainShellScaffold> {
  late GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'job_requests'.tr();
      case 1:
        return 'jobs'.tr();
      case 2:
        return 'incentive'.tr();
      default:
        return 'dashboard'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: colorScheme.onSurface),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _getPageTitle(widget.currentIndex),
          style: context.font
              .bold(context)
              .copyWith(fontSize: 20.sp, color: colorScheme.onSurface),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              context.push('/notifications');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, colorScheme),
      body: Stack(
        children: [
          widget.child,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 30.h + MediaQuery.of(context).viewPadding.bottom,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.primary.withValues(alpha: 0.5),
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Container(
          height: 54.h,
          decoration: BoxDecoration(
            color: colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 25,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFloatingNavItem(
                context: context,
                icon: Icons.mail_outline,
                label: 'Requests',
                isActive: widget.currentIndex == 0,
                onTap: () {
                  context.go('/request');
                },
                colorScheme: colorScheme,
              ),
              _buildFloatingNavItem(
                context: context,
                icon: Icons.list_alt,
                label: 'Jobs',
                isActive: widget.currentIndex == 1,
                onTap: () {
                  context.go('/jobs');
                },
                colorScheme: colorScheme,
              ),
              _buildFloatingNavItem(
                context: context,
                icon: Icons.card_giftcard,
                label: 'Incentive',
                isActive: widget.currentIndex == 2,
                onTap: () {
                  context.go('/incentive-report');
                },
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ColorScheme colorScheme) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Modern Header with gradient background
            Container(
              padding: EdgeInsets.all(12.h),
              margin: EdgeInsets.all(8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.secondary.withValues(alpha: 0.15),
                    colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.secondary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.h,
                    height: 48.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colorScheme.secondary, colorScheme.tertiary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.secondary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person,
                      color: colorScheme.onPrimary,
                      size: 24.h,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Muhammad Hakimie',
                    style: context.font
                        .bold(context)
                        .copyWith(
                          fontSize: 15.sp,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user,
                        size: 10.h,
                        color: Colors.green,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Driver • ID: 0',
                        style: context.font
                            .regular(context)
                            .copyWith(
                              fontSize: 10.sp,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.h, vertical: 2.h),
                children: [
                  _buildDrawerSectionHeader(
                    context,
                    'account'.tr(),
                    colorScheme,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_outline,
                    label: 'profile'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    label: 'settings'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: 6.h),
                  _buildDrawerSectionHeader(
                    context,
                    'application'.tr(),
                    colorScheme,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.assignment_turned_in_outlined,
                    label: 'rest_request'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/rest-request');
                    },
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.payment,
                    label: 'return_to_base'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/return-to-base');
                    },
                    colorScheme: colorScheme,
                  ),
                  SizedBox(height: 6.h),
                  _buildDrawerSectionHeader(
                    context,
                    'support'.tr(),
                    colorScheme,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.security_outlined,
                    label: 'safety_questions'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/safety-questions');
                    },
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.bug_report_outlined,
                    label: 'bug_report'.tr(),
                    onTap: null,
                    colorScheme: colorScheme,
                    isDisabled: true,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.help_outline,
                    label: 'help_support'.tr(),
                    onTap: null,
                    colorScheme: colorScheme,
                    isDisabled: true,
                  ),
                ],
              ),
            ),
            // Logout button
            Padding(
              padding: EdgeInsets.all(8.h),
              child: SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.logout, size: 16.h),
                  label: Text(
                    'logout'.tr(),
                    style: context.font
                        .semibold(context)
                        .copyWith(fontSize: 12.sp, color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSectionHeader(
    BuildContext context,
    String title,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 4.h, 6.w, 6.h),
      child: Text(
        title,
        style: context.font
            .semibold(context)
            .copyWith(
              fontSize: 10.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.3,
            ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required ColorScheme colorScheme,
    bool isDisabled = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 32.h,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: isDisabled
                          ? colorScheme.outline.withValues(alpha: 0.1)
                          : colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 16.h,
                      color: isDisabled
                          ? colorScheme.outline.withValues(alpha: 0.4)
                          : colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      label,
                      style: context.font
                          .medium(context)
                          .copyWith(
                            fontSize: 12.sp,
                            color: isDisabled
                                ? colorScheme.onSurface.withValues(alpha: 0.4)
                                : colorScheme.onSurface,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.h,
                    color: isDisabled
                        ? colorScheme.onSurface.withValues(alpha: 0.1)
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6.h),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20.h,
              color: isActive ? colorScheme.primary : Colors.grey,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: context.font
                .regular(context)
                .copyWith(
                  fontSize: 9.sp,
                  color: isActive ? colorScheme.primary : Colors.grey,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}
