import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_sidebar.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppSidebar(
        userName: 'Driver Name',
        tenantName: 'Tenant Co.',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        onLogout: null,
      ),
      appBar: AppBar(
        title: Text('dashboard'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'dashboard'.tr()} 👋',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DashboardStatCard(
                  icon: Icons.assignment_turned_in,
                  label: 'Jobs Today',
                  value: '5',
                ),
                _DashboardStatCard(
                  icon: Icons.attach_money,
                  label: 'Incentives',
                  value: 'RM 120',
                ),
                _DashboardStatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  value: '12',
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Job List'),
                  onPressed: () => context.push('/jobs'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Incentive'),
                  onPressed: () => context.push('/incentive-report'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Bug Report'),
                  onPressed: () => context.push('/bug-report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DashboardStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
