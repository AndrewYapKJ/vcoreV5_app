import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/providers/user_provider.dart';
import 'package:intl/intl.dart';

/// Format date string to dd MMM YYYY format
String formatDateToDdMmmYyyy(String? dateString) {
  if (dateString == null || dateString.isEmpty || dateString == 'N/A') {
    return 'N/A';
  }
  try {
    // Try to parse multiple date formats
    DateTime? date;

    // Try ISO format first (YYYY-MM-DD or YYYY-MM-DD HH:MM:SS)
    if (dateString.contains('-')) {
      date = DateTime.tryParse(dateString);
    }

    // If parsing fails, try other common formats
    if (date == null) {
      final formats = [
        'dd/MM/yyyy',
        'MM/dd/yyyy',
        'dd-MM-yyyy',
        'MM-dd-yyyy',
        'yyyy/MM/dd',
      ];

      for (var format in formats) {
        try {
          date = DateFormat(format).parse(dateString);
          break;
        } catch (e) {
          continue;
        }
      }
    }

    if (date == null) {
      return dateString; // Return original if parsing fails
    }

    return DateFormat('dd MMM yyyy').format(date);
  } catch (e) {
    return dateString; // Return original if any error
  }
}

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);

    // Use user data from API or fallback to sample data
    final userData = <String, dynamic>{
      'name': user?.name ?? 'Guest User',
      'mobile': user?.mobile ?? '0000000000',
      'employeeCode': user?.driverId ?? 'N/A',
      'dob': formatDateToDdMmmYyyy(user?.driverDob),
      'licenceNo': user?.driverLicenceNo ?? 'N/A',
      'dateOfJoin': formatDateToDdMmmYyyy(user?.driverDateOfJoining),
      'gdlExpiryDate': user?.gdlExpiryDate ?? 'Invalid Date',
      'westPortPassExpiryDate': user?.westPortExpiry ?? 'Invalid Date',
      'northPortPassExpiryDate': user?.northPortExpiry ?? 'Invalid Date',
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.h),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'profile'.tr(),
          style: context.font
              .semibold(context)
              .copyWith(fontSize: 18.sp, color: colorScheme.onSurface),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              // Profile Header Card with Avatar
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.secondary.withValues(alpha: 0.12),
                      colorScheme.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.secondary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80.h,
                      height: 80.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.tertiary,
                            colorScheme.tertiary.withValues(alpha: 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.tertiary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (userData['name'] ?? '')
                              .toString()
                              .split(' ')
                              .map((e) => e[0])
                              .join()
                              .toUpperCase(),
                          style: context.font
                              .bold(context)
                              .copyWith(
                                fontSize: 28.sp,
                                color: colorScheme.onTertiary,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Name
                    Text(
                      userData['name'],
                      style: context.font
                          .bold(context)
                          .copyWith(
                            fontSize: 20.sp,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    SizedBox(height: 6.h),
                    // Mobile with Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14.h,
                            color: colorScheme.secondary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            userData['mobile'],
                            style: context.font
                                .medium(context)
                                .copyWith(
                                  fontSize: 12.sp,
                                  color: colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),

              // Quick Info Cards
              _buildQuickInfoRow(context, colorScheme, userData),
              SizedBox(height: 28.h),

              // Personal Information Section
              _buildSectionHeader(
                context,
                'personal_information'.tr(),
                Icons.person,
              ),
              SizedBox(height: 12.h),
              _buildInfoCard(
                context: context,
                label: 'employee_code'.tr(),
                value: userData['employeeCode'],
                icon: Icons.badge_outlined,
                colorScheme: colorScheme,
              ),
              _buildInfoCard(
                context: context,
                label: 'date_of_birth'.tr(),
                value: userData['dob'],
                icon: Icons.calendar_today_outlined,
                colorScheme: colorScheme,
              ),
              _buildInfoCard(
                context: context,
                label: 'date_of_join'.tr(),
                value: userData['dateOfJoin'],
                icon: Icons.event_outlined,
                colorScheme: colorScheme,
              ),
              SizedBox(height: 28.h),

              // Licence Information Section
              _buildSectionHeader(
                context,
                'licence_information'.tr(),
                Icons.description_outlined,
              ),
              SizedBox(height: 12.h),
              _buildInfoCard(
                context: context,
                label: 'licence_number'.tr(),
                value: userData['licenceNo'],
                icon: Icons.numbers,
                colorScheme: colorScheme,
              ),
              SizedBox(height: 28.h),

              // Expiry Dates Section
              _buildSectionHeader(context, 'expiry_dates'.tr(), Icons.schedule),
              SizedBox(height: 12.h),
              _buildExpiryCard(
                context: context,
                label: 'gdl_expiry'.tr(),
                value: userData['gdlExpiryDate'].isNotEmpty
                    ? userData['gdlExpiryDate']
                    : 'Invalid Date',
                icon: Icons.time_to_leave,
                colorScheme: colorScheme,
                isExpired: userData['gdlExpiryDate'].toString().contains(
                  'Invalid',
                ),
              ),
              _buildExpiryCard(
                context: context,
                label: 'west_port_expiry'.tr(),
                value: userData['westPortPassExpiryDate'].isNotEmpty
                    ? userData['westPortPassExpiryDate']
                    : 'Invalid Date',
                icon: Icons.location_city_outlined,
                colorScheme: colorScheme,
                isExpired: userData['westPortPassExpiryDate']
                    .toString()
                    .contains('Invalid'),
              ),
              _buildExpiryCard(
                context: context,
                label: 'north_port_expiry'.tr(),
                value: userData['northPortPassExpiryDate'].isNotEmpty
                    ? userData['northPortPassExpiryDate']
                    : 'Invalid Date',
                icon: Icons.location_city_outlined,
                colorScheme: colorScheme,
                isExpired: userData['northPortPassExpiryDate']
                    .toString()
                    .contains('Invalid'),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.h),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.secondary, size: 18.h),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: context.font
              .semibold(context)
              .copyWith(fontSize: 15.sp, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 18.h),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.font
                      .regular(context)
                      .copyWith(
                        fontSize: 12.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.3,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: context.font
                      .semibold(context)
                      .copyWith(fontSize: 14.sp, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool isExpired,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isExpired || value.contains('Invalid')
              ? [
                  Colors.red.withValues(alpha: 0.08),
                  Colors.red.withValues(alpha: 0.03),
                ]
              : [
                  Colors.green.withValues(alpha: 0.08),
                  Colors.green.withValues(alpha: 0.03),
                ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpired || value.contains('Invalid')
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.green.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.h),
            decoration: BoxDecoration(
              color: isExpired || value.contains('Invalid')
                  ? Colors.red.withValues(alpha: 0.15)
                  : Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExpired || value.contains('Invalid')
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color: isExpired || value.contains('Invalid')
                  ? Colors.red
                  : Colors.green,
              size: 18.h,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.font
                      .regular(context)
                      .copyWith(
                        fontSize: 12.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.3,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: context.font
                      .semibold(context)
                      .copyWith(
                        fontSize: 14.sp,
                        color: isExpired || value.contains('Invalid')
                            ? Colors.red
                            : Colors.green,
                      ),
                ),
              ],
            ),
          ),
          if (isExpired)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Expired',
                style: context.font
                    .semibold(context)
                    .copyWith(fontSize: 11.sp, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoRow(
    BuildContext context,
    ColorScheme colorScheme,
    Map<String, dynamic> userData,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickInfoCard(
            context: context,
            label: 'Employee ID',
            value: '${userData['employeeCode']}',
            icon: Icons.badge_outlined,
            colorScheme: colorScheme,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildQuickInfoCard(
            context: context,
            label: 'License',
            value: '${userData['licenceNo']}'.substring(0, 2),
            icon: Icons.description_outlined,
            colorScheme: colorScheme,
            suffix: '...',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
    String suffix = '',
  }) {
    return Container(
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 16.h),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: context.font
                .regular(context)
                .copyWith(
                  fontSize: 11.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$value$suffix',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.font
                .bold(context)
                .copyWith(fontSize: 13.sp, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
