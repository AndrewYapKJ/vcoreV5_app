import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/services/job_service.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';

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
  final JobService _jobService = JobService();

  String _selectedJobType = 'HMS'; // HMS or TMS
  String _selectedStatus = 'pending'; // pending, in-progress, completed
  String _searchQuery = '';

  List<Job> _jobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _jobTypeTabController = TabController(length: 2, vsync: this);
    _statusTabController = TabController(length: 3, vsync: this);

    _jobTypeTabController.addListener(() {
      if (!_jobTypeTabController.indexIsChanging) {
        setState(() {
          _selectedJobType = _jobTypeTabController.index == 0 ? 'HMS' : 'TMS';
        });
        _fetchJobs();
      }
    });

    _statusTabController.addListener(() {
      if (!_statusTabController.indexIsChanging) {
        final statuses = ['pending', 'in-progress', 'completed'];
        setState(() {
          _selectedStatus = statuses[_statusTabController.index];
        });
        _fetchJobs();
      }
    });

    // Initial fetch
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final driverId = LoginCacheService().getCachedDriverId() ?? '';
      final tenantId = LoginCacheService().getCachedTenantId() ?? '';
      final pm = LoginCacheService().getCachedVehicleId() ?? '';

      final jobs = await _jobService.getJobs(
        driverId: driverId,
        status: _selectedStatus,
        pm: pm,
        siteType: _selectedJobType,
        tenantId: tenantId,
      );

      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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

    return Column(
      children: [
        // Header with Search
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildSearchBar(context, colorScheme)],
          ),
        ),
        // Status & Job Type Row
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              // Job Type Selector
              _buildJobTypeSelector(accentColor, isHMS, isDark),
              SizedBox(width: 6.w),
              // Status Tabs with gradient background
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              accentColor.withValues(alpha: 0.25),
                              accentColor.withValues(alpha: 0.15),
                            ]
                          : [
                              accentColor.withValues(alpha: 0.1),
                              accentColor.withValues(alpha: 0.05),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark
                          ? accentColor.withValues(alpha: 0.4)
                          : accentColor.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
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
        Expanded(child: SafeArea(child: _buildJobList(context, colorScheme))),
      ],
    );
  }

  Widget _buildJobTypeSelector(Color accentColor, bool isHMS, bool isDark) {
    return GestureDetector(
      onTap: () {
        final nextIndex = (_jobTypeTabController.index + 1) % 2;
        _jobTypeTabController.animateTo(nextIndex);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    accentColor.withValues(alpha: 0.3),
                    accentColor.withValues(alpha: 0.2),
                  ]
                : [
                    accentColor.withValues(alpha: 0.15),
                    accentColor.withValues(alpha: 0.08),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isDark
                ? accentColor.withValues(alpha: 0.5)
                : accentColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
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
                    ? accentColor.withValues(alpha: 0.35)
                    : accentColor.withValues(alpha: 0.2),
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
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
            color: isActive ? Colors.white : accentColor.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[500];

    return Container(
      decoration: BoxDecoration(
        // color: bgColor,
        // borderRadius: BorderRadius.circular(12.r),
        // border: Border.all(color: borderColor ?? Colors.grey, width: 1),
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
          filled: true,
          fillColor: colorScheme.surfaceContainerHigh,

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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
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

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            SizedBox(height: 16.h),
            Text(
              'Loading jobs...',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Error loading jobs',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(onPressed: _fetchJobs, child: Text('Retry')),
          ],
        ),
      );
    }

    final filteredJobs = _jobs.where((job) {
      final jobId = job.no.toLowerCase();
      final pickup = job.pickup.toLowerCase();
      final drop = job.drop.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return jobId.contains(query) ||
          pickup.contains(query) ||
          drop.contains(query);
    }).toList();

    if (filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.1),
                    colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.08),
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
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchJobs,
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

  Widget _buildJobCard(BuildContext context, Job job, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(_selectedStatus);
    final isHMS = _selectedJobType == 'HMS';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.grey.shade700.withValues(alpha: 01)
                : Colors.grey.shade400.withValues(alpha: 1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(1, 2),
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
                      statusColor.withValues(alpha: 0.12),
                      statusColor.withValues(alpha: 0.04),
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
                padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  job.no,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            job.dateTime,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
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
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withValues(alpha: 0.15),
                            statusColor.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
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
                                  color: statusColor.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 7.w),
                          Text(
                            _getStatusLabel(_selectedStatus),
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
                padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Locations with modern icons
                    _buildLocationRow(
                      icon: Icons.location_on_outlined,
                      label: 'From',
                      value: job.pickOrgShortCode.isNotEmpty
                          ? '${job.pickOrgShortCode} - ${job.pickup}'
                          : job.pickup,
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 6.h),
                    _buildLocationRow(
                      icon: Icons.location_on,
                      label: 'To',
                      value: job.dropOrgShortCode.isNotEmpty
                          ? '${job.dropOrgShortCode} - ${job.drop}'
                          : job.drop,
                      color: statusColor,
                    ),
                    SizedBox(height: 8.h),
                    // Job Details Grid - Modern design
                    _buildJobDetailsGrid(job, isHMS),
                    // Quick Actions Bar
                    SizedBox(height: 6.h),
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
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            color: Colors.orange,
                            onTap: () =>
                                _onJobCardLongPress(context, job, colorScheme),
                          ),
                        ),
                        SizedBox(width: 3.w),
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
      case 'pending':
        return const Color(0xFFFF6B6B);
      case 'in-progress':
        return const Color(0xFFFFA94D);
      case 'completed':
        return const Color(0xFF51CF66);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Not Started';
      case 'in-progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
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
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (color ?? Colors.grey).withValues(alpha: 0.15),
                (color ?? Colors.grey).withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (color ?? Colors.grey).withValues(alpha: 0.1),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Icon(icon, size: 13.sp, color: color),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  // color: Colors.black87,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobDetailsGrid(Job job, bool isHMS) {
    final items = isHMS
        ? [
            {
              'label': 'Truck',
              'value': job.truckNo,
              'icon': Icons.local_shipping,
              'color': const Color(0xFF3B82F6),
            },
            {
              'label': 'Container',
              'value': job.containerNo,
              'icon': Icons.inventory_2,
              'color': const Color(0xFF8B5CF6),
            },
            {
              'label': 'Seal',
              'value': job.sealNo,
              'icon': Icons.lock,
              'color': const Color(0xFFEC4899),
            },
          ]
        : [
            {
              'label': 'Truck',
              'value': job.truckNo,
              'icon': Icons.directions_car,
              'color': const Color(0xFF3B82F6),
            },
            {
              'label': 'Trailer',
              'value': job.trailerNo,
              'icon': Icons.shopping_bag,
              'color': const Color(0xFF8B5CF6),
            },
            {
              'label': 'Size',
              'value': job.containerSize,
              'icon': Icons.scale,
              'color': const Color(0xFFEC4899),
            },
          ];

    return Wrap(
      spacing: 4.w,
      runSpacing: 5.h,
      alignment: WrapAlignment.start,
      children: items.map((item) {
        final color = item['color'] as Color;
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 52.w) / 3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: color.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
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
                      colors: [
                        color.withValues(alpha: 0.25),
                        color.withValues(alpha: 0.12),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
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
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 6.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 8.h),
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

  void _onJobCardTap(BuildContext context, Job job) {
    context.push('/job-details', extra: job);
  }

  void _onJobCardLongPress(
    BuildContext context,
    Job job,
    ColorScheme colorScheme,
  ) {
    _showSnackbar(context, 'Long press - Edit mode: ${job.no}');
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
}
