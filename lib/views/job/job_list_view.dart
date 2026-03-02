import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:google_fonts/google_fonts.dart';

class JobListView extends StatefulWidget {
  const JobListView({super.key});

  @override
  State<JobListView> createState() => _JobListViewState();
}

class _JobListViewState extends State<JobListView>
    with TickerProviderStateMixin {
  late TabController _jobTypeTabController;
  late TabController _statusTabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedJobType = 'HMS'; // HMS or TMS
  String _selectedStatus = 'pending'; // pending, in-progress, completed
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _jobTypeTabController = TabController(length: 2, vsync: this);
    _statusTabController = TabController(length: 3, vsync: this);

    _jobTypeTabController.addListener(() {
      setState(() {
        _selectedJobType = _jobTypeTabController.index == 0 ? 'HMS' : 'TMS';
      });
    });

    _statusTabController.addListener(() {
      final statuses = ['pending', 'in-progress', 'completed'];
      setState(() {
        _selectedStatus = statuses[_statusTabController.index];
      });
    });
  }

  @override
  void dispose() {
    _jobTypeTabController.dispose();
    _statusTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine color tone based on selected job type
    final isHMS = _jobTypeTabController.index == 0;
    final accentColor = isHMS
        ? const Color(0xFF3B82F6) // Blue for HMS
        : const Color(0xFFEC4899); // Pink for TMS

    // Dark mode background colors with better contrast
    final bgColor = isDark
        ? const Color(0xFF1A1A2E) // Dark blue-black for better contrast
        : Colors.white;

    return Column(
      children: [
        // Header with Search
        Container(
          color: bgColor,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildSearchBar(context, colorScheme)],
          ),
        ),
        // Status & Job Type Row
        Container(
          color: bgColor,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // Job Type Selector
              _buildJobTypeSelectorBeautiful(accentColor, isHMS, isDark),
              SizedBox(width: 12.w),
              // Status Tabs with gradient background
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              accentColor.withOpacity(0.25),
                              accentColor.withOpacity(0.15),
                            ]
                          : [
                              accentColor.withOpacity(0.1),
                              accentColor.withOpacity(0.05),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark
                          ? accentColor.withOpacity(0.4)
                          : accentColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusTabBeautiful(
                          label: 'PENDING',
                          isActive: _statusTabController.index == 0,
                          onTap: () => _statusTabController.animateTo(0),
                          accentColor: accentColor,
                        ),
                        SizedBox(width: 16.w),
                        _buildStatusTabBeautiful(
                          label: 'IN-PROGRESS',
                          isActive: _statusTabController.index == 1,
                          onTap: () => _statusTabController.animateTo(1),
                          accentColor: accentColor,
                        ),
                        SizedBox(width: 16.w),
                        _buildStatusTabBeautiful(
                          label: 'COMPLETED',
                          isActive: _statusTabController.index == 2,
                          onTap: () => _statusTabController.animateTo(2),
                          accentColor: accentColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Job List
        Expanded(child: _buildJobList(context, colorScheme)),
      ],
    );
  }

  Widget _buildJobTypeSelectorBeautiful(
    Color accentColor,
    bool isHMS,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        final nextIndex = (_jobTypeTabController.index + 1) % 2;
        _jobTypeTabController.animateTo(nextIndex);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [accentColor.withOpacity(0.3), accentColor.withOpacity(0.2)]
                : [
                    accentColor.withOpacity(0.15),
                    accentColor.withOpacity(0.08),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isDark
                ? accentColor.withOpacity(0.5)
                : accentColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(isDark ? 0.2 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: isDark
                    ? accentColor.withOpacity(0.35)
                    : accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                isHMS ? Icons.local_shipping : Icons.directions_car,
                size: 14.sp,
                color: accentColor,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              isHMS ? 'HMS' : 'TMS',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: accentColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTabBeautiful({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : accentColor.withOpacity(0.6),
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[500];
    final bgColor = isDark ? colorScheme.surface : const Color(0xFFF0F0F5);
    final borderColor = isDark ? Colors.grey[700] : Colors.grey[300];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor ?? Colors.grey, width: 1),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Search jobs...',
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 12.w, right: 8.w),
            child: Icon(Icons.search_rounded, color: hintColor, size: 18.sp),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(right: 4.w),
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: hintColor,
                      size: 16.sp,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
        ),
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildJobList(BuildContext context, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : Colors.grey[50];
    // Sample data - replace with actual data from provider
    final mockJobs = _getMockJobs(_selectedJobType, _selectedStatus);

    final filteredJobs = mockJobs.where((job) {
      final jobId = job['id'].toString().toLowerCase();
      final location = job['location'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return jobId.contains(query) || location.contains(query);
    }).toList();

    if (filteredJobs.isEmpty) {
      return Container(
        color: bgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(28.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.08),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 64.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'No Jobs Yet',
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Adjust your search or filters',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: bgColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        itemCount: filteredJobs.length,
        itemBuilder: (context, index) {
          final job = filteredJobs[index];
          return GestureDetector(
            onLongPress: () => _onJobCardLongPress(context, job, colorScheme),
            child: _buildJobCard(context, job, colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    Map<String, dynamic> job,
    ColorScheme colorScheme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(job['currentStatus']);
    final isHMS = job['type'] == 'HMS';
    final cardBgColor = isDark
        ? const Color(0xFF252E48) // Better contrast in dark mode
        : Colors.white;
    final cardTextColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onJobCardTap(context, job),
          borderRadius: BorderRadius.circular(18.r),
          child: Column(
            children: [
              // Premium Header with gradient and status indicator
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.12),
                      statusColor.withOpacity(0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                  ),
                  border: Border(
                    left: BorderSide(color: statusColor, width: 3.5),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                job['id'],
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: cardTextColor,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      isHMS
                                          ? const Color(0xFFE8F4FD)
                                          : const Color(0xFFFEEEF7),
                                      isHMS
                                          ? const Color(0xFFF0F8FF)
                                          : const Color(0xFFFFF5FB),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isHMS
                                        ? const Color(
                                            0xFF1976D2,
                                          ).withOpacity(0.2)
                                        : const Color(
                                            0xFFC2185B,
                                          ).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  job['type'],
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    color: isHMS
                                        ? const Color(0xFF1976D2)
                                        : const Color(0xFFC2185B),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _formatTimestamp(job['timestamp']),
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withOpacity(0.15),
                            statusColor.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 7.w),
                          Text(
                            job['currentStatus'],
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Card Body
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Locations with modern icons
                    _buildLocationRow(
                      icon: Icons.location_on_outlined,
                      label: 'From',
                      value: job['pickupFrom'],
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 10.h),
                    _buildLocationRow(
                      icon: Icons.location_on,
                      label: 'To',
                      value: job['deliveryTo'],
                      color: statusColor,
                    ),
                    SizedBox(height: 12.h),
                    // Job Details Grid - Modern design
                    _buildJobDetailsGrid(job, isHMS),
                    SizedBox(height: 12.h),
                    // Quick Actions Bar
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.image_outlined,
                            label: 'Upload',
                            color: Colors.blue,
                            onTap: () => _showSnackbar(
                              context,
                              'Image upload coming soon',
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            color: Colors.orange,
                            onTap: () =>
                                _onJobCardLongPress(context, job, colorScheme),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.arrow_forward_ios_rounded,
                            label: 'Details',
                            color: statusColor,
                            onTap: () => _onJobCardTap(context, job),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Not Started':
        return const Color(0xFFFF6B6B);
      case 'In Progress':
        return const Color(0xFFFFA94D);
      case 'Completed':
        return const Color(0xFF51CF66);
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(String timestamp) {
    return timestamp; // Format as needed
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String label,
    required String value,
    required Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (color ?? Colors.grey).withOpacity(0.15),
                (color ?? Colors.grey).withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (color ?? Colors.grey).withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, size: 14.sp, color: color),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobDetailsGrid(Map<String, dynamic> job, bool isHMS) {
    final items = isHMS
        ? [
            {
              'label': 'Trailer',
              'value': job['trailer'],
              'icon': Icons.local_shipping,
              'color': const Color(0xFF3B82F6),
            },
            {
              'label': 'Container',
              'value': job['container'],
              'icon': Icons.inventory_2,
              'color': const Color(0xFF8B5CF6),
            },
            {
              'label': 'Seal',
              'value': job['sealNo'],
              'icon': Icons.lock,
              'color': const Color(0xFFEC4899),
            },
            {
              'label': 'Size',
              'value': job['size'],
              'icon': Icons.straighten,
              'color': const Color(0xFF14B8A6),
            },
          ]
        : [
            {
              'label': 'Vehicle',
              'value': job['vehicle'],
              'icon': Icons.directions_car,
              'color': const Color(0xFF3B82F6),
            },
            {
              'label': 'Commodity',
              'value': job['commodity'],
              'icon': Icons.shopping_bag,
              'color': const Color(0xFF8B5CF6),
            },
            {
              'label': 'Weight',
              'value': job['weight'],
              'icon': Icons.scale,
              'color': const Color(0xFFEC4899),
            },
            {
              'label': 'Rate',
              'value': job['rate'],
              'icon': Icons.local_offer,
              'color': const Color(0xFF14B8A6),
            },
          ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8.h,
      crossAxisSpacing: 8.w,
      childAspectRatio: 0.95,
      children: items.map((item) {
        final color = item['color'] as Color;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.25), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.25), color.withOpacity(0.12)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 15.sp,
                  color: color,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                item['label']! as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700],
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                item['value']! as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.12), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onJobCardTap(BuildContext context, Map<String, dynamic> job) {
    _showSnackbar(context, 'Navigate to job details: ${job['id']}');
  }

  void _onJobCardLongPress(
    BuildContext context,
    Map<String, dynamic> job,
    ColorScheme colorScheme,
  ) {
    _showSnackbar(context, 'Long press - Edit mode: ${job['id']}');
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 20.h, left: 16.w, right: 16.w),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockJobs(String jobType, String status) {
    final allJobs = [
      {
        'id': 'TE-2508-0172-1-SIC1',
        'type': 'HMS',
        'pickupFrom': 'MOI FOODS MALAYSIA - LOT 40',
        'deliveryTo': 'TOKOYARD SECTION 2 KL',
        'timestamp': 'Aug 30, 09:53 AM',
        'location': 'MOI FOODS TOKOYARD',
        'trailer': 'MEDU1859499',
        'container': 'CONT-12345',
        'sealNo': 'SEAL-9876',
        'size': '40\'',
        'currentStatus': 'Not Started',
      },
      {
        'id': 'TE-2508-0173-2-TST2',
        'type': 'HMS',
        'pickupFrom': 'PETRON STATION KL',
        'deliveryTo': 'SELANGOR DEPOT',
        'timestamp': 'Aug 30, 10:15 AM',
        'location': 'PETRON SELANGOR',
        'trailer': 'NAVIO37478',
        'container': 'CONT-54321',
        'sealNo': 'SEAL-1111',
        'size': '20\'',
        'currentStatus': 'In Progress',
      },
      {
        'id': 'TE-2508-0174-3-TST3',
        'type': 'TMS',
        'pickupFrom': 'WAREHOUSE A JOHOR',
        'deliveryTo': 'CUSTOMER B PENANG',
        'timestamp': 'Aug 30, 11:30 AM',
        'location': 'WAREHOUSE CUSTOMER B',
        'vehicle': 'WX-2024-100',
        'commodity': 'Electronics',
        'weight': '2500 kg',
        'rate': 'RM 500',
        'currentStatus': 'Completed',
      },
      {
        'id': 'TE-2508-0175-4-HMS4',
        'type': 'HMS',
        'pickupFrom': 'PORT KLANG',
        'deliveryTo': 'BUKIT RAJA FACILITY',
        'timestamp': 'Aug 30, 01:45 PM',
        'location': 'PORT KLANG BUKIT RAJA',
        'trailer': 'MEDU1859500',
        'container': 'CONT-99999',
        'sealNo': 'SEAL-2222',
        'size': '40\'',
        'currentStatus': 'Not Started',
      },
      {
        'id': 'TE-2508-0176-5-TMS5',
        'type': 'TMS',
        'pickupFrom': 'FACTORY C KLANG',
        'deliveryTo': 'RETAIL STORE KL',
        'timestamp': 'Aug 30, 02:20 PM',
        'location': 'FACTORY RETAIL STORE',
        'vehicle': 'WX-2024-101',
        'commodity': 'Furniture',
        'weight': '3000 kg',
        'rate': 'RM 600',
        'currentStatus': 'Not Started',
      },
      {
        'id': 'TE-2508-0177-6-HMS6',
        'type': 'HMS',
        'pickupFrom': 'KUALA LUMPUR PORT',
        'deliveryTo': 'DISTRIBUTION CENTER SHAH ALAM',
        'timestamp': 'Aug 30, 03:00 PM',
        'location': 'KL PORT SHAH ALAM',
        'trailer': 'NAVIO37479',
        'container': 'CONT-77777',
        'sealNo': 'SEAL-3333',
        'size': '20\'',
        'currentStatus': 'In Progress',
      },
    ];

    return allJobs.where((job) {
      if (job['type'] != jobType) return false;
      if (job['currentStatus'] == 'Not Started' && status == 'pending') {
        return true;
      }
      if (job['currentStatus'] == 'In Progress' && status == 'in-progress') {
        return true;
      }
      if (job['currentStatus'] == 'Completed' && status == 'completed') {
        return true;
      }
      return false;
    }).toList();
  }
}
