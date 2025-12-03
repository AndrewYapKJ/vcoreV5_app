// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:easy_localization/easy_localization.dart';
// import '../dashboard/dashboard_view.dart';
// import '../incentive/incentive_report_view.dart';
// import '../job/job_list_view.dart';

// class LandingView extends StatelessWidget {
//   const LandingView({super.key});

//   static const _routes = ['/dashboard', '/incentive-report', '/jobs'];

//   @override
//   Widget build(BuildContext context) {
//     int selectedIndex = 0;
//     final location = GoRouterState.of(context).uri.toString();
//     selectedIndex = _routes.indexWhere((r) => location.startsWith(r));
//     if (selectedIndex == -1) selectedIndex = 0;

//     final List<Widget> pages = [
//       const DashboardView(),
//       const IncentiveReportView(),
//       const JobListView(),
//     ];

//     return Scaffold(
//       body: IndexedStack(index: selectedIndex, children: pages),
//       bottomNavigationBar: _CustomBottomNavBar(
//         currentIndex: selectedIndex,
//         onTap: (index) => context.go(_routes[index]),
//       ),
//     );
//   }
// }

// class _CustomBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const _CustomBottomNavBar({required this.currentIndex, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap,
//       items: [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home_outlined),
//           activeIcon: Icon(Icons.home),
//           label: 'dashboard'.tr(),
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.card_giftcard_outlined),
//           activeIcon: Icon(Icons.card_giftcard),
//           label: 'incentive_report'.tr(),
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.list_alt_outlined),
//           activeIcon: Icon(Icons.list_alt),
//           label: 'job_list'.tr(),
//         ),
//       ],
//     );
//   }
// }
