import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:vcore_v5_app/core/font_styling.dart';

// Sample user data
const Map<String, dynamic> sampleUserData = {
  'name': 'Muhammad Hakimie',
  'mobile': '0138686055',
  'employeeCode': '0',
  'dob': '2 Apr 2026',
  'licenceNo': '851206136217',
  'dateOfJoin': '2 Apr 2026',
  'gdlExpiryDate': 'Invalid Date',
  'westPortPassExpiryDate': 'Invalid Date',
  'northPortPassExpiryDate': 'Invalid Date',
};

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          'Profile',
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
                      colorScheme.primary.withValues(alpha: 0.12),
                      colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.15),
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
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          sampleUserData['name']
                              .toString()
                              .split(' ')
                              .map((e) => e[0])
                              .join()
                              .toUpperCase(),
                          style: context.font
                              .bold(context)
                              .copyWith(
                                fontSize: 28.sp,
                                color: colorScheme.onPrimary,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Name
                    Text(
                      sampleUserData['name'],
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
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14.h,
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            sampleUserData['mobile'],
                            style: context.font
                                .medium(context)
                                .copyWith(
                                  fontSize: 12.sp,
                                  color: colorScheme.primary,
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
              _buildQuickInfoRow(context, colorScheme),
              SizedBox(height: 28.h),

              // Personal Information Section
              _buildSectionHeader(
                context,
                'Personal Information',
                Icons.person,
              ),
              SizedBox(height: 12.h),
              _buildInfoCard(
                context: context,
                label: 'Employee Code',
                value: sampleUserData['employeeCode'],
                icon: Icons.badge_outlined,
                colorScheme: colorScheme,
              ),
              _buildInfoCard(
                context: context,
                label: 'Date of Birth',
                value: sampleUserData['dob'],
                icon: Icons.calendar_today_outlined,
                colorScheme: colorScheme,
              ),
              _buildInfoCard(
                context: context,
                label: 'Date of Join',
                value: sampleUserData['dateOfJoin'],
                icon: Icons.event_outlined,
                colorScheme: colorScheme,
              ),
              SizedBox(height: 28.h),

              // Licence Information Section
              _buildSectionHeader(
                context,
                'Licence Information',
                Icons.description,
              ),
              SizedBox(height: 12.h),
              _buildInfoCard(
                context: context,
                label: 'Licence Number',
                value: sampleUserData['licenceNo'],
                icon: Icons.numbers,
                colorScheme: colorScheme,
              ),
              SizedBox(height: 28.h),

              // Expiry Dates Section
              _buildSectionHeader(context, 'Expiry Dates', Icons.schedule),
              SizedBox(height: 12.h),
              _buildExpiryCard(
                context: context,
                label: 'GDL Expiry Date',
                value: sampleUserData['gdlExpiryDate'],
                icon: Icons.time_to_leave,
                colorScheme: colorScheme,
                isExpired: sampleUserData['gdlExpiryDate'].toString().contains(
                  'Invalid',
                ),
              ),
              _buildExpiryCard(
                context: context,
                label: 'West Port Pass Expiry',
                value: sampleUserData['westPortPassExpiryDate'],
                icon: Icons.location_city_outlined,
                colorScheme: colorScheme,
                isExpired: sampleUserData['westPortPassExpiryDate']
                    .toString()
                    .contains('Invalid'),
              ),
              _buildExpiryCard(
                context: context,
                label: 'North Port Pass Expiry',
                value: sampleUserData['northPortPassExpiryDate'],
                icon: Icons.location_city_outlined,
                colorScheme: colorScheme,
                isExpired: sampleUserData['northPortPassExpiryDate']
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
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 18.h),
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
        color: colorScheme.surface,
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
          colors: isExpired
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
          color: isExpired
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
              color: isExpired
                  ? Colors.red.withValues(alpha: 0.15)
                  : Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExpired ? Icons.error_outline : Icons.check_circle_outline,
              color: isExpired ? Colors.red : Colors.green,
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
                        color: isExpired ? Colors.red : Colors.green,
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

  Widget _buildQuickInfoRow(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickInfoCard(
            context: context,
            label: 'Employee ID',
            value: sampleUserData['employeeCode'],
            icon: Icons.badge_outlined,
            colorScheme: colorScheme,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildQuickInfoCard(
            context: context,
            label: 'License',
            value: sampleUserData['licenceNo'].toString().substring(0, 8),
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
