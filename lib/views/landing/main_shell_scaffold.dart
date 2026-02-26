import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:go_router/go_router.dart';
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
        return 'Job Requests';
      case 1:
        return 'Jobs';
      case 2:
        return 'Incentives';
      default:
        return 'Dashboard';
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
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, colorScheme),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        selectedIconTheme: IconThemeData(size: 26),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        selectedItemColor: colorScheme.primary,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/request');
              break;
            case 1:
              context.go('/jobs');
              break;
            case 2:
              context.go('/incentive-report');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: 'Requests',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Jobs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Incentive',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ColorScheme colorScheme) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header with logo/user info
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.1),
                    colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50.h,
                    height: 50.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: colorScheme.onPrimary,
                      size: 28.h,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Welcome Back',
                    style: context.font.bold(context).copyWith(fontSize: 16.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'admin@example.com',
                    style: context.font
                        .regular(context)
                        .copyWith(
                          fontSize: 12.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            Divider(height: 0),
            SizedBox(height: 8.h),
            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.assignment_turned_in_outlined,
                    label: 'Leave Application',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/leave-application');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.payment,
                    label: 'Advance Payment',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/advance-payment');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.security_outlined,
                    label: 'Safety Questions',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/safety-questions');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.bug_report_outlined,
                    label: 'Report Bug',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/bug-report');
                    },
                  ),
                  Divider(indent: 16.w, endIndent: 16.w),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement help
                    },
                  ),
                ],
              ),
            ),
            Divider(height: 0),
            // Logout button
            Padding(
              padding: EdgeInsets.all(12.h),
              child: SizedBox(
                width: double.infinity,
                height: 44.h,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Implement logout
                    context.go('/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.logout, size: 18.h),
                  label: Text(
                    'Logout',
                    style: context.font
                        .semibold(context)
                        .copyWith(fontSize: 14.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        size: 20.h,
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(
        label,
        style: context.font
            .regular(context)
            .copyWith(fontSize: 14.sp, color: colorScheme.onSurface),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
