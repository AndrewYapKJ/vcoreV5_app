import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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

    return Scaffold(
      // backgroundColor: colorScheme.inversePrimary,
      body: Column(
        children: [
          // Search Bar - Modern elevated design
          Container(
            margin: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 0),
            decoration: BoxDecoration(
              // color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildSearchBar(context, colorScheme),
          ),
          SizedBox(height: 8.h),
          // Job Type Tabs - Modern segmented design
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                height: 36.h,
                width: 180.w,
                decoration: BoxDecoration(
                  // color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[600]!, width: 0.5),
                ),
                child: TabBar(
                  controller: _jobTypeTabController,
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    color: colorScheme.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),

                  padding: EdgeInsets.all(2.5.w),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping, size: 14.sp),
                          SizedBox(width: 4.w),
                          const Text('HMS'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car, size: 14.sp),
                          SizedBox(width: 4.w),
                          const Text('TMS'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Status Tabs - Modern chip design
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip(
                    label: 'pending'.tr().toUpperCase(),
                    isActive: _statusTabController.index == 0,
                    onTap: () => _statusTabController.animateTo(0),
                    icon: Icons.hourglass_bottom,
                    color: const Color(0xFFFF6B6B),
                  ),
                  SizedBox(width: 10.w),
                  _buildStatusChip(
                    label: 'in_progress'.tr().toUpperCase(),
                    isActive: _statusTabController.index == 1,
                    onTap: () => _statusTabController.animateTo(1),
                    icon: Icons.sync,
                    color: const Color(0xFFFFA94D),
                  ),
                  SizedBox(width: 10.w),
                  _buildStatusChip(
                    label: 'completed'.tr().toUpperCase(),
                    isActive: _statusTabController.index == 2,
                    onTap: () => _statusTabController.animateTo(2),
                    icon: Icons.check_circle,
                    color: const Color(0xFF51CF66),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Job List
          Expanded(child: _buildJobList(context, colorScheme)),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [color, color.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.white, Colors.grey[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12.r),
          border: isActive
              ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
              : Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                icon,
                size: 17.sp,
                color: isActive ? Colors.white : color,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: isActive ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Search Job ID or location...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 8.w, right: 4.w),
            child: Icon(
              Icons.search_rounded,
              color: Colors.grey[400],
              size: 18.sp,
            ),
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          suffixIcon: _searchQuery.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey[500],
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
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        ),
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildJobList(BuildContext context, ColorScheme colorScheme) {
    // Sample data - replace with actual data from provider
    final mockJobs = _getMockJobs(_selectedJobType, _selectedStatus);

    final filteredJobs = mockJobs.where((job) {
      final jobId = job['id'].toString().toLowerCase();
      final location = job['location'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return jobId.contains(query) || location.contains(query);
    }).toList();

    if (filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 56.sp,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No jobs found',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
        return GestureDetector(
          onLongPress: () => _onJobCardLongPress(context, job, colorScheme),
          child: _buildJobCard(context, job, colorScheme),
        );
      },
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    Map<String, dynamic> job,
    ColorScheme colorScheme,
  ) {
    final statusColor = _getStatusColor(job['currentStatus']);
    final isHMS = job['type'] == 'HMS';

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onJobCardTap(context, job),
          borderRadius: BorderRadius.circular(10.r),
          child: Column(
            children: [
              // Top gradient header with status
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withValues(alpha: 0.15),
                      statusColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    topRight: Radius.circular(10.r),
                  ),
                  border: Border(
                    left: BorderSide(color: statusColor, width: 2.5),
                  ),
                ),
                padding: EdgeInsets.all(8.w),
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
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isHMS
                                      ? const Color(0xFFE3F2FD)
                                      : const Color(0xFFFCE4EC),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  job['type'],
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    color: isHMS
                                        ? const Color(0xFF1976D2)
                                        : const Color(0xFFC2185B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _formatTimestamp(job['timestamp']),
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            job['currentStatus'],
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
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
                padding: EdgeInsets.all(8.w),
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
                    SizedBox(height: 6.h),
                    _buildLocationRow(
                      icon: Icons.location_on,
                      label: 'To',
                      value: job['deliveryTo'],
                      color: statusColor,
                    ),
                    SizedBox(height: 8.h),
                    // Job Details Grid - Modern design
                    _buildJobDetailsGrid(job, isHMS),
                    SizedBox(height: 8.h),
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
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: (color ?? Colors.grey).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12.sp, color: color),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 8.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
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
      mainAxisSpacing: 6.h,
      crossAxisSpacing: 6.w,
      childAspectRatio: 0.9,
      children: items.map((item) {
        final color = item['color'] as Color;
        return Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
          ),
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  size: 14.sp,
                  color: color,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item['label']! as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                item['value']! as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
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
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
        ),
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 7.sp,
                fontWeight: FontWeight.w700,
                color: color,
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
