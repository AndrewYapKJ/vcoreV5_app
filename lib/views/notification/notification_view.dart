import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vcore_v5_app/core/font_styling.dart';

// Notification Model
class Notification {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final NotificationType type;
  final bool isRead;
  final IconData icon;
  final Color color;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
    required this.icon,
    required this.color,
  });
}

enum NotificationType { delivery, system, reminder, alert, update }

// Dummy Notifications Data
final List<Notification> dummyNotifications = [
  // Notification(
  //   id: '1',
  //   title: 'Delivery Completed',
  //   message: 'Your delivery to Kuala Lumpur has been completed successfully.',
  //   timestamp: '2 mins ago',
  //   type: NotificationType.delivery,
  //   isRead: false,
  //   icon: Icons.local_shipping_outlined,
  //   color: Colors.green,
  // ),
  // Notification(
  //   id: '2',
  //   title: 'New Job Available',
  //   message: 'A new delivery job matching your route is available now.',
  //   timestamp: '15 mins ago',
  //   type: NotificationType.alert,
  //   isRead: false,
  //   icon: Icons.info_outline,
  //   color: Colors.blue,
  // ),
  // Notification(
  //   id: '3',
  //   title: 'Document Expiry Reminder',
  //   message: 'Your driver license will expire in 30 days. Please renew it.',
  //   timestamp: '1 hour ago',
  //   type: NotificationType.reminder,
  //   isRead: true,
  //   icon: Icons.warning_outlined,
  //   color: Colors.orange,
  // ),
  // Notification(
  //   id: '4',
  //   title: 'System Maintenance',
  //   message:
  //       'The app will undergo maintenance on Feb 28. We apologize for the inconvenience.',
  //   timestamp: '3 hours ago',
  //   type: NotificationType.system,
  //   isRead: true,
  //   icon: Icons.build_outlined,
  //   color: Colors.purple,
  // ),
  // Notification(
  //   id: '5',
  //   title: 'Payment Received',
  //   message: 'You have received RM 250.00 for completed deliveries.',
  //   timestamp: 'Yesterday',
  //   type: NotificationType.update,
  //   isRead: true,
  //   icon: Icons.account_balance_wallet_outlined,
  //   color: Colors.teal,
  // ),
  // Notification(
  //   id: '6',
  //   title: 'Route Update',
  //   message: 'Your assigned route has been updated due to traffic conditions.',
  //   timestamp: 'Yesterday',
  //   type: NotificationType.delivery,
  //   isRead: true,
  //   icon: Icons.location_on_outlined,
  //   color: Colors.indigo,
  // ),
];

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late List<Notification> notifications;

  @override
  void initState() {
    super.initState();
    notifications = List.from(dummyNotifications);
  }

  void _markAsRead(String id) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = Notification(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          timestamp: notifications[index].timestamp,
          type: notifications[index].type,
          isRead: true,
          icon: notifications[index].icon,
          color: notifications[index].color,
        );
      }
    });
  }

  void _dismissNotification(String id) {
    setState(() {
      notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.h),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'notifications'.tr(),
              style: context.font
                  .semibold(context)
                  .copyWith(fontSize: 18.sp, color: colorScheme.onSurface),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount ${'unread'.tr()}',
                style: context.font
                    .regular(context)
                    .copyWith(
                      fontSize: 11.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
          ],
        ),
        centerTitle: false,
        actions: [
          if (notifications.isNotEmpty)
            PopupMenuButton(
              icon: Icon(Icons.more_vert, size: 20.h),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('mark_all_as_read'.tr()),
                  onTap: () {
                    setState(() {
                      notifications = notifications
                          .map(
                            (n) => Notification(
                              id: n.id,
                              title: n.title,
                              message: n.message,
                              timestamp: n.timestamp,
                              type: n.type,
                              isRead: true,
                              icon: n.icon,
                              color: n.color,
                            ),
                          )
                          .toList();
                    });
                  },
                ),
                PopupMenuItem(
                  child: Text('clear_all'.tr()),
                  onTap: () {
                    setState(() {
                      notifications.clear();
                    });
                  },
                ),
              ],
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context, colorScheme)
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    ...notifications.asMap().entries.map((entry) {
                      final index = entry.key;
                      final notification = entry.value;
                      return _buildNotificationCard(
                        context: context,
                        notification: notification,
                        colorScheme: colorScheme,
                        isLast: index == notifications.length - 1,
                      );
                    }).toList(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.h,
            height: 100.h,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 50.h,
              color: colorScheme.secondary.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'no_notifications'.tr(),
            style: context.font
                .semibold(context)
                .copyWith(fontSize: 16.sp, color: colorScheme.onSurface),
          ),
          SizedBox(height: 8.h),
          Text(
            'all_caught_up'.tr(),
            style: context.font
                .regular(context)
                .copyWith(
                  fontSize: 14.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required Notification notification,
    required ColorScheme colorScheme,
    required bool isLast,
  }) {
    return GestureDetector(
      onTap: () => _markAsRead(notification.id),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
        decoration: BoxDecoration(
          color: notification.isRead
              ? colorScheme.surface
              : notification.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? colorScheme.outline.withValues(alpha: 0.1)
                : notification.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _markAsRead(notification.id),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: EdgeInsets.all(14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Badge
                  Container(
                    width: 48.h,
                    height: 48.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          notification.color.withValues(alpha: 0.2),
                          notification.color.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        notification.icon,
                        color: notification.color,
                        size: 24.h,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: context.font
                                    .semibold(context)
                                    .copyWith(
                                      fontSize: 14.sp,
                                      color: colorScheme.onSurface,
                                      fontWeight: notification.isRead
                                          ? FontWeight.w600
                                          : FontWeight.w700,
                                    ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8.h,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: notification.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          notification.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.font
                              .regular(context)
                              .copyWith(
                                fontSize: 12.sp,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                                height: 1.4,
                              ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          notification.timestamp,
                          style: context.font
                              .regular(context)
                              .copyWith(
                                fontSize: 11.sp,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Dismiss Button
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(Icons.close, size: 18.h),
                    onPressed: () => _dismissNotification(notification.id),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 32.h,
                      minHeight: 32.h,
                    ),
                    splashRadius: 16.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
