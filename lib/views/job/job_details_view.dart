import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vcore_v5_app/models/job_model.dart';

class JobDetailsView extends StatelessWidget {
  final Job job;

  const JobDetailsView({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.h),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Details',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card with Job Number
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF3B82F6).withValues(alpha: 0.12),
                      const Color(0xFF3B82F6).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.h),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.local_shipping,
                            color: const Color(0xFF3B82F6),
                            size: 18.h,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Job Number',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                job.no,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF3B82F6),
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12.h,
                            color: const Color(0xFF3B82F6),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            job.dateTime,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Location Details Section
              _buildSectionHeader(
                context,
                'Location Details',
                Icons.location_on,
                isDark,
              ),
              SizedBox(height: 8.h),
              _buildLocationCard(
                context: context,
                title: 'Pickup Location',
                shortCode: job.pickOrgShortCode,
                fullAddress: job.pickup,
                orgName: job.pickOrgName,
                contactInfo: job.pickOrgContPerNamePh,
                icon: Icons.location_on_outlined,
                color: Colors.green,
                isDark: isDark,
              ),
              SizedBox(height: 8.h),
              _buildLocationCard(
                context: context,
                title: 'Drop Location',
                shortCode: job.dropOrgShortCode,
                fullAddress: job.drop,
                orgName: job.dropOrgName,
                contactInfo: job.dropOrgContPerNamePh,
                icon: Icons.location_on,
                color: Colors.red,
                isDark: isDark,
              ),
              SizedBox(height: 14.h),

              // Container & Vehicle Details
              _buildSectionHeader(
                context,
                'Container & Vehicle Details',
                Icons.inventory_2,
                isDark,
              ),
              SizedBox(height: 8.h),
              _buildDetailsGrid(context, isDark, [
                {
                  'label': 'Truck Number',
                  'value': job.truckNo,
                  'icon': Icons.local_shipping,
                },
                {
                  'label': 'Container No',
                  'value': job.containerNo,
                  'icon': Icons.inventory_2,
                },
                {
                  'label': 'Seal Number',
                  'value': job.sealNo,
                  'icon': Icons.lock,
                },
                {
                  'label': 'Trailer No',
                  'value': job.trailerNo,
                  'icon': Icons.rv_hookup,
                },
                {
                  'label': 'Container Size',
                  'value': job.containerSize,
                  'icon': Icons.straighten,
                },
                {
                  'label': 'Container Type',
                  'value': job.containerType,
                  'icon': Icons.category,
                },
              ]),
              SizedBox(height: 14.h),

              // Job Information
              _buildSectionHeader(
                context,
                'Job Information',
                Icons.info_outline,
                isDark,
              ),
              SizedBox(height: 8.h),
              _buildInfoCard(
                context: context,
                label: 'Customer',
                value: job.customer,
                icon: Icons.business,
                isDark: isDark,
              ),
              _buildInfoCard(
                context: context,
                label: 'Master Order No',
                value: job.masterOrderNo,
                icon: Icons.receipt_long,
                isDark: isDark,
              ),
              _buildInfoCard(
                context: context,
                label: 'Gate Pass No',
                value: job.gatePassNo,
                icon: Icons.card_membership,
                isDark: isDark,
              ),
              _buildInfoCard(
                context: context,
                label: 'Gate Pass DateTime',
                value: job.gatePassDatetime,
                icon: Icons.schedule,
                isDark: isDark,
              ),
              _buildInfoCard(
                context: context,
                label: 'Container Operator',
                value: job.containerOperator,
                icon: Icons.supervised_user_circle,
                isDark: isDark,
              ),
              _buildInfoCard(
                context: context,
                label: 'Shipping Agent Ref',
                value: job.shippingAgentRefNo,
                icon: Icons.verified_user,
                isDark: isDark,
              ),
              SizedBox(height: 14.h),

              // Additional Details
              _buildSectionHeader(
                context,
                'Additional Details',
                Icons.description,
                isDark,
              ),
              SizedBox(height: 8.h),
              _buildDetailsGrid(context, isDark, [
                {
                  'label': 'Pickup Qty',
                  'value': job.pickQty,
                  'icon': Icons.production_quantity_limits,
                },
                {
                  'label': 'Drop Qty',
                  'value': job.dropQty,
                  'icon': Icons.inventory,
                },
                {
                  'label': 'Job Type',
                  'value': job.jobType,
                  'icon': Icons.type_specimen,
                },
                {
                  'label': 'Job Priority',
                  'value': job.jobPriority,
                  'icon': Icons.priority_high,
                },
                {
                  'label': 'Import/Export',
                  'value': job.jobImportExport,
                  'icon': Icons.import_export,
                },
                {
                  'label': 'B2B',
                  'value': job.jobB2B,
                  'icon': Icons.business_center,
                },
              ]),
              SizedBox(height: 8.h),

              // Remarks
              if (job.remarks.isNotEmpty && job.remarks != '--')
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notes, color: Colors.orange, size: 18.h),
                          SizedBox(width: 8.w),
                          Text(
                            'Remarks',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        job.remarks,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 8.h),

              // Delivery Instructions
              if (job.deliveryInstruction.isNotEmpty &&
                  job.deliveryInstruction != '--')
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assignment,
                            color: Colors.blue,
                            size: 18.h,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Delivery Instructions',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        job.deliveryInstruction,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 14.h),
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
    bool isDark,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.h),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 14.h),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard({
    required BuildContext context,
    required String title,
    required String shortCode,
    required String fullAddress,
    required String orgName,
    required String contactInfo,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20.h),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    if (shortCode.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          shortCode,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (orgName.isNotEmpty && orgName != '--')
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                orgName,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          Text(
            fullAddress,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
          if (contactInfo.isNotEmpty && contactInfo != '--') ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.phone, size: 14.h, color: color),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    contactInfo,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    if (value.isEmpty || value == '--') return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 14.h),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(
    BuildContext context,
    bool isDark,
    List<Map<String, dynamic>> items,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.map((item) {
        final value = item['value'] as String;
        if (value.isEmpty || value == '--') return const SizedBox.shrink();

        return Container(
          width: (MediaQuery.of(context).size.width - 48.w) / 2,
          padding: EdgeInsets.all(8.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item['icon'] as IconData,
                color: colorScheme.primary,
                size: 14.h,
              ),
              SizedBox(height: 6.h),
              Text(
                item['label'] as String,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
