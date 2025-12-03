import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../dashboard/dashboard_view.dart';
import '../incentive/incentive_report_view.dart';
import '../job/job_list_view.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  static const _routes = ['/home', '/incentive-report', '/jobs'];

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;
    final location = GoRouterState.of(context).uri.toString();
    selectedIndex = _routes.indexWhere((r) => location.startsWith(r));
    if (selectedIndex == -1) selectedIndex = 0;
    final List<Widget> _pages = [
      const DashboardView(),
      const IncentiveReportView(),
      const JobListView(),
    ];
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          context.go(_routes[index]);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: 'dashboard'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.card_giftcard_outlined),
            selectedIcon: const Icon(Icons.card_giftcard),
            label: 'incentive_report'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: 'job_list'.tr(),
          ),
        ],
      ),
    );
  }
}
