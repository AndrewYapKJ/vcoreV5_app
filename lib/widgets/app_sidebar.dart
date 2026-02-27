import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  final String userName;
  final String tenantName;
  final String avatarUrl;
  final void Function()? onLogout;

  const AppSidebar({
    super.key,
    required this.userName,
    required this.tenantName,
    required this.avatarUrl,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                const SizedBox(height: 12),
                Text(userName, style: Theme.of(context).textTheme.titleMedium),
                Text(tenantName, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('dashboard'.tr()),
            onTap: () => context.push('/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: Text('incentive_report'.tr()),
            onTap: () => context.push('/incentive'),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: Text('job_list'.tr()),
            onTap: () => context.push('/jobs'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('user_profile'.tr()),
            onTap: () => context.push('/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: Text('bug_report'.tr()),
            onTap: () => context.push('/bug-report'),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('Logout'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
