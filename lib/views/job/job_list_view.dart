import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/providers/jobs_provider.dart';
import 'package:vcore_v5_app/providers/user_provider.dart';
import 'package:vcore_v5_app/services/api/job_api.dart';
import 'package:vcore_v5_app/services/dio/dio_repo.dart';
import 'package:vcore_v5_app/services/job_service.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';

class JobListView extends ConsumerStatefulWidget {
  const JobListView({super.key});

  @override
  ConsumerState<JobListView> createState() => _JobListViewState();
}

class _JobListViewState extends ConsumerState<JobListView>
    with TickerProviderStateMixin {
  late TabController _jobTypeTabController;
  late TabController _statusTabController;
  final TextEditingController _searchController = TextEditingController();
  final JobService _jobService = JobService();
  final ImagePicker _picker = ImagePicker();

  String _selectedJobType = 'HMS'; // HMS or TMS
  String _selectedStatus = 'pending'; // pending, in-progress, completed
  String _searchQuery = '';

  List<Job> _jobs = [];
  bool _isLoading = true;
  bool _isUploadingImages = false;
  bool _isPickingImages = false;
  bool _isUpdatingJobDetails = false;
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

      // Process B2B data
      _processB2BData(jobs);

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

  void _handleStatusSwipe(DragEndDetails details) {
    final velocityX = details.primaryVelocity ?? 0;
    const minSwipeVelocity = 250.0;

    if (velocityX.abs() < minSwipeVelocity) return;

    final currentIndex = _statusTabController.index;
    int? nextIndex;

    // Swipe left -> move forward (Pending -> In-Progress -> Completed)
    if (velocityX < 0 && currentIndex < 2) {
      nextIndex = currentIndex + 1;
    }

    // Swipe right -> move backward (Completed -> In-Progress -> Pending)
    if (velocityX > 0 && currentIndex > 0) {
      nextIndex = currentIndex - 1;
    }

    if (nextIndex != null && nextIndex != currentIndex) {
      _statusTabController.animateTo(nextIndex);
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
        // Job List (swipe left/right to change status)
        Expanded(
          child: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: _handleStatusSwipe,
              child: _buildJobList(context, colorScheme),
            ),
          ),
        ),
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
      final jobId = job.no?.toLowerCase() ?? '';
      final pickup = job.pickup?.toLowerCase() ?? '';
      final drop = job.drop?.toLowerCase() ?? '';
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
          final hasB2B = _hasValidB2B(job) && job.b2bData != null;

          return GestureDetector(
            onLongPress: () => _onJobCardLongPress(context, job, colorScheme),
            child: hasB2B
                ? _buildSwipeableJobCard(context, job, colorScheme)
                : _buildJobCard(context, job, colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildSwipeableJobCard(
    BuildContext context,
    Job job,
    ColorScheme colorScheme,
  ) {
    final b2bColor = const Color(0xFFFF6B35);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      height: 300.h, // Increased height to accommodate action buttons
      child: Stack(
        children: [
          PageView(
            children: [
              _buildSingleJobCard(context, job, colorScheme, isMainCard: true),
              if (job.b2bData != null)
                _buildSingleJobCard(
                  context,
                  job.b2bData!,
                  colorScheme,
                  isMainCard: false,
                ),
            ],
          ),
          // Swipe indicator
          Positioned(
            bottom: 8.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: b2bColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swipe, size: 12.sp, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    'Swipe for B2B',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleJobCard(
    BuildContext context,
    Job job,
    ColorScheme colorScheme, {
    required bool isMainCard,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(_selectedStatus);
    final isHMS = _selectedJobType == 'HMS';
    final hasB2B = !isMainCard || _hasValidB2B(job);
    final b2bColor = const Color(0xFFFF6B35);
    final cardColor = isMainCard ? statusColor : b2bColor;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: cardColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.grey.shade700.withValues(alpha: 0.3)
                : Colors.grey.shade400.withValues(alpha: 0.3),
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
              // Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cardColor.withValues(alpha: 0.12),
                      cardColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                  ),
                  border: Border(
                    left: BorderSide(color: cardColor, width: 3.5),
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
                              if (!isMainCard) ...[
                                Icon(
                                  CupertinoIcons.link,
                                  size: 12.sp,
                                  color: b2bColor,
                                ),
                                SizedBox(width: 4.w),
                              ],
                              Flexible(
                                child: Text(
                                  job.no ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isMainCard && hasB2B) ...[
                                SizedBox(width: 6.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        b2bColor.withValues(alpha: 0.2),
                                        b2bColor.withValues(alpha: 0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: b2bColor.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.link,
                                        size: 10.sp,
                                        color: b2bColor,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        'B2B',
                                        style: GoogleFonts.inter(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w900,
                                          color: b2bColor,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            job.dateTime ?? '',
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
                            cardColor.withValues(alpha: 0.15),
                            cardColor.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: cardColor.withValues(alpha: 0.3),
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
                              color: cardColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: cardColor.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 7.w),
                          Text(
                            isMainCard
                                ? _getStatusLabel(_selectedStatus)
                                : 'B2B',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: cardColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationRow(
                      icon: Icons.location_on_outlined,
                      label: 'From',
                      value: job.pickOrgShortCode?.isNotEmpty == true
                          ? '${job.pickOrgShortCode} - ${job.pickup ?? ''}'
                          : job.pickup ?? '',
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 6.h),
                    _buildLocationRow(
                      icon: Icons.location_on,
                      label: 'To',
                      value: job.dropOrgShortCode?.isNotEmpty == true
                          ? '${job.dropOrgShortCode} - ${job.drop ?? ''}'
                          : job.drop ?? '',
                      color: cardColor,
                    ),
                    SizedBox(height: 8.h),
                    _buildJobDetailsGrid(job, isHMS),
                    SizedBox(height: 6.h),
                    // Quick Actions Bar
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            icon: Icons.image_outlined,
                            label: 'Upload',
                            color: Colors.blue,
                            isLoading: _isUploadingImages || _isPickingImages,
                            onTap: () =>
                                _pickAndUploadImagesForJob(context, job),
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
                            color: cardColor,
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

  Widget _buildJobCard(BuildContext context, Job job, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(_selectedStatus);
    final isHMS = _selectedJobType == 'HMS';
    final hasB2B = _hasValidB2B(job);
    final b2bColor = const Color(0xFFFF6B35); // Orange color for B2B indicator

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: hasB2B ? 0 : 12.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18.r),
            // Add subtle border for B2B jobs
            border: hasB2B
                ? Border.all(color: b2bColor.withValues(alpha: 0.3), width: 1.5)
                : null,
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
                                      job.no?.toString() ?? '',
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // B2B Indicator Badge
                                  if (hasB2B) ...[
                                    SizedBox(width: 6.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            b2bColor.withValues(alpha: 0.2),
                                            b2bColor.withValues(alpha: 0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(
                                          color: b2bColor.withValues(
                                            alpha: 0.4,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.link,
                                            size: 10.sp,
                                            color: b2bColor,
                                          ),
                                          SizedBox(width: 3.w),
                                          Text(
                                            'B2B',
                                            style: GoogleFonts.inter(
                                              fontSize: 9.sp,
                                              fontWeight: FontWeight.w900,
                                              color: b2bColor,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                job.dateTime ?? '',
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
                          value: job.pickOrgShortCode?.isNotEmpty == true
                              ? '${job.pickOrgShortCode} - ${job.pickup ?? ''}'
                              : job.pickup ?? '',
                          color: Colors.grey[700],
                        ),
                        SizedBox(height: 6.h),
                        _buildLocationRow(
                          icon: Icons.location_on,
                          label: 'To',
                          value: job.dropOrgShortCode?.isNotEmpty == true
                              ? '${job.dropOrgShortCode} - ${job.drop ?? ''}'
                              : job.drop ?? '',
                          color: statusColor,
                        ),

                        // B2B Linked Job Section
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
                                isLoading:
                                    _isUploadingImages || _isPickingImages,
                                onTap: () =>
                                    _pickAndUploadImagesForJob(context, job),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _buildQuickActionButton(
                                icon: Icons.edit_outlined,
                                label: 'Edit',
                                color: Colors.orange,
                                onTap: () => _onJobCardLongPress(
                                  context,
                                  job,
                                  colorScheme,
                                ),
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
        ),
        // B2B Linked Job Card
        if (hasB2B)
          _buildB2BLinkedJobCard(
            context,
            job,
            colorScheme,
            statusColor,
            isDark,
            isHMS,
          ),
      ],
    );
  }

  Widget _buildB2BLinkedJobCard(
    BuildContext context,
    Job job,
    ColorScheme colorScheme,
    Color statusColor,
    bool isDark,
    bool isHMS,
  ) {
    final b2bColor = const Color(0xFFFF6B35);
    final b2bJobNo = job.jobB2B;

    return Column(
      children: [
        SizedBox(height: 16.h),
        Stack(
          children: [
            // Main B2B Card (offset down)
            Transform.translate(
              offset: const Offset(0, -6),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 8.h),
                      width: 16.w,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // Navigate to B2B job details
                          // For now, just show a snackbar since we'd need to fetch the full B2B job data
                          _showSnackbar(context, 'Opening B2B Job: $b2bJobNo');
                        },
                        borderRadius: BorderRadius.circular(18.r),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: b2bColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.grey.shade700.withValues(
                                        alpha: 0.3,
                                      )
                                    : Colors.grey.shade400.withValues(
                                        alpha: 0.3,
                                      ),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      b2bColor.withValues(alpha: 0.12),
                                      b2bColor.withValues(alpha: 0.04),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(18.r),
                                    topRight: Radius.circular(18.r),
                                  ),
                                  border: Border(
                                    left: BorderSide(
                                      color: b2bColor,
                                      width: 3.5,
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  10.w,
                                  6.h,
                                  10.w,
                                  6.h,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.link,
                                            size: 14.sp,
                                            color: b2bColor,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'B2B Linked:',
                                            style: GoogleFonts.inter(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w700,
                                              color: b2bColor,
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Flexible(
                                            child: Text(
                                              b2bJobNo ?? '',
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
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            b2bColor.withValues(alpha: 0.2),
                                            b2bColor.withValues(alpha: 0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(
                                          color: b2bColor.withValues(
                                            alpha: 0.4,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _selectedJobType,
                                        style: GoogleFonts.inter(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w900,
                                          color: b2bColor,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Body
                              Padding(
                                padding: EdgeInsets.all(10.w),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 14.sp,
                                          color: b2bColor.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: Text(
                                            'Tap to view linked job details',
                                            style: GoogleFonts.inter(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 12.sp,
                                          color: b2bColor,
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
                    ),
                  ],
                ),
              ),
            ),
            // Chain of link icons
            Transform.translate(
              offset: Offset(8.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  5,
                  (index) => Transform.translate(
                    offset: const Offset(0, -25),
                    child: Transform.rotate(
                      angle: -math.pi / 4,
                      child: Icon(
                        CupertinoIcons.link,
                        size: 18.sp,
                        color: b2bColor.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
              'value': job.truckNo ?? '-',
              'icon': Icons.local_shipping,
              'color': const Color(0xFF3B82F6),
            },
            {
              'label': 'Container',
              'value': job.containerNo ?? '-',
              'icon': Icons.inventory_2,
              'color': const Color(0xFF8B5CF6),
            },
            {
              'label': 'Seal',
              'value': job.sealNo ?? '-',
              'icon': Icons.lock,
              'color': const Color(0xFFEC4899),
            },
            {
              'label': 'Trailer',
              'value': job.trailerNo ?? '-',
              'icon': Icons.local_shipping_outlined,
              'color': const Color(0xFF10B981),
            },
          ]
        : [
            {
              'label': 'Truck',
              'value': job.truckNo ?? '-',
              'icon': Icons.directions_car,
              'color': const Color(0xFF3B82F6),
            },
            {
              'label': 'Trailer',
              'value': job.trailerNo ?? '-',
              'icon': Icons.shopping_bag,
              'color': const Color(0xFF8B5CF6),
            },
            {
              'label': 'Size',
              'value': job.containerSize ?? '-',
              'icon': Icons.scale,
              'color': const Color(0xFFEC4899),
            },
          ];

    return Row(
      children: items.map((item) {
        final color = item['color'] as Color;
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 2.w),
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
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
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
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14.w,
                    height: 14.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  ),
                  SizedBox(width: 8.h),
                  Text(
                    'Loading...',
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              )
            : Row(
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

  void _onJobCardTap(BuildContext context, Job job) async {
    final result = await context.push('/job-details', extra: job);
    // If activity was updated, refresh the job list
    if (result == true && mounted) {
      debugPrint('Activity updated, refreshing job list...');
      await _fetchJobs();
    }
  }

  Future<void> _pickAndUploadImagesForJob(BuildContext context, Job job) async {
    if (_isUploadingImages || _isPickingImages) return;

    final jobNo = job.no?.trim() ?? '';
    if (jobNo.isEmpty || job.id == null) {
      _safeShowSnackBar(
        context,
        'Job number or ID is missing, cannot upload images',
        Colors.red,
      );
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isPickingImages = true;
        });
      }

      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext modalContext) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(modalContext).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10.h),
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ListTile(
                    leading: Icon(
                      Icons.photo_camera,
                      color: Theme.of(modalContext).colorScheme.primary,
                    ),
                    title: Text(
                      'Camera',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () =>
                        Navigator.pop(modalContext, ImageSource.camera),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: Icon(
                      Icons.photo_library,
                      color: Theme.of(modalContext).colorScheme.primary,
                    ),
                    title: Text(
                      'Gallery',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () =>
                        Navigator.pop(modalContext, ImageSource.gallery),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          );
        },
      );

      if (source == null) return;

      List<XFile> images = [];
      if (source == ImageSource.camera) {
        final photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (photo != null) {
          images.add(photo);
        }
      } else {
        images = await _picker.pickMultiImage(imageQuality: 85);
      }

      if (images.isEmpty || !mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(
            'Upload Images',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Upload ${images.length} image(s) for job $jobNo?',
            style: GoogleFonts.inter(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Upload',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      await _uploadImagesForJob(context: context, job: job, images: images);
    } catch (e) {
      debugPrint('❌ Error in image picker flow: $e');
      if (mounted) {
        _safeShowSnackBar(context, 'Error: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImages = false;
        });
      }
    }
  }

  Future<void> _uploadImagesForJob({
    required BuildContext context,
    required Job job,
    required List<XFile> images,
  }) async {
    setState(() {
      _isUploadingImages = true;
    });

    try {
      final dio = DioRepo(baseUrl: 'https://vcore.x1.com.my').mDio;
      final jobNo = job.no?.trim() ?? '';
      final jobId = job.id;

      if (jobNo.isEmpty || jobId == null) {
        throw Exception('Job number or ID is missing');
      }

      int successCount = 0;
      for (var image in images) {
        try {
          final fileName =
              '$jobNo-${DateFormat("yyyyMMddHHmmss").format(DateTime.now())}';

          final formData = FormData.fromMap({
            'files': await MultipartFile.fromFile(
              image.path,
              filename: fileName,
            ),
          });

          final response = await dio.post(
            '/app/ReceiveFile.ashx',
            data: formData,
            queryParameters: {'id': jobId},
          );

          if (response.statusCode == 200 && response.data != null) {
            successCount++;
          }
        } catch (e) {
          debugPrint('❌ Failed to upload image ${image.path}: $e');
        }
      }

      if (!mounted) return;

      if (successCount > 0) {
        _safeShowSnackBar(
          context,
          '$successCount image(s) uploaded successfully',
          Colors.green,
        );
      }

      if (successCount < images.length) {
        _safeShowSnackBar(
          context,
          '${images.length - successCount} image(s) failed to upload',
          Colors.orange,
        );
      }
    } catch (e) {
      debugPrint('❌ Error uploading images: $e');
      if (mounted) {
        _safeShowSnackBar(
          context,
          'Failed to upload images: ${e.toString()}',
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
        });
      }
    }
  }

  bool _hasValidB2B(Job job) {
    final b2bValue = job.jobB2B?.trim() ?? '';
    return b2bValue.isNotEmpty && b2bValue != '0' && b2bValue != job.no;
  }

  bool _hasValidB2BForJob(Job? job) {
    if (job == null) return false;
    final b2bValue = job.jobB2B?.trim() ?? '';
    return b2bValue.isNotEmpty && b2bValue != '0' && b2bValue != job.no;
  }

  void _processB2BData(List<Job> dataList) {
    List<List<String>> linkedJob = [];

    debugPrint('=== B2B Processing Debug ===');
    debugPrint('Processing ${dataList.length} jobs for B2B linking');

    // First, identify all B2B pairs and create the links
    for (var item in dataList) {
      if (_hasValidB2BForJob(item)) {
        debugPrint('Job ${item.no}: JobB2B = "${item.jobB2B}"');

        // Find the B2B partner job
        Job? b2bItem = dataList.cast<Job?>().firstWhere(
          (v) => v?.no == item.jobB2B,
          orElse: () => null,
        );

        if (b2bItem != null) {
          debugPrint('  Found B2B partner: ${b2bItem.no}');

          // Always attach the B2B data to the current job
          item.b2bData = b2bItem;

          // Add to linked jobs list for deduplication
          linkedJob.add([item.no ?? '', item.jobB2B ?? '']);
        } else {
          debugPrint('  B2B partner ${item.jobB2B} not found in job list');
        }
      }
    }

    debugPrint('Linked jobs before deduplication: $linkedJob');

    // Remove duplicate pairs and determine which jobs to keep
    Set<String> jobsToRemove = <String>{};
    Set<String> processedPairs = <String>{};

    for (var link in linkedJob) {
      String job1 = link[0];
      String job2 = link[1];

      // Create a consistent pair identifier (sort to avoid duplicates)
      List<String> sortedPair = [job1, job2]..sort();
      String pairKey = '${sortedPair[0]}-${sortedPair[1]}';

      if (!processedPairs.contains(pairKey)) {
        processedPairs.add(pairKey);

        // Keep the first job (job1) and mark the second job (job2) for removal
        jobsToRemove.add(job2);
        debugPrint('B2B Pair: Keep $job1, Remove $job2');
      }
    }

    debugPrint('Jobs to remove from main list: $jobsToRemove');

    // Remove the secondary jobs from the main list
    int originalCount = dataList.length;
    dataList.removeWhere((v) => jobsToRemove.contains(v.no));

    debugPrint(
      'Removed ${originalCount - dataList.length} jobs from main list',
    );
    debugPrint('Final job count after B2B processing: ${dataList.length}');

    // Debug: Show final B2B structure
    for (var job in dataList) {
      if (job.b2bData != null) {
        debugPrint('✅ Job ${job.no} linked with B2B job: ${job.b2bData?.no}');
      } else {
        debugPrint('   Job ${job.no} - no B2B link');
      }
    }
    debugPrint('=== B2B Processing Complete ===');
  }

  void _onJobCardLongPress(
    BuildContext context,
    Job job,
    ColorScheme colorScheme,
  ) {
    // Show bottom sheet with options
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewPadding.bottom,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 16.h),
                // Edit Details Option
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showEditJobDetailsDialog(context, job);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Details',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  'Update container, seal, trailer, remarks',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14.sp,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Update Activity Option
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showUpdateJobActivityDialog(context, job);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            color: Colors.orange,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Update Activity',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange,
                                  ),
                                ),
                                Text(
                                  'Change job status/activity',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14.sp,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show dialog to edit job details (container, seal, trailer, remarks)
  void _showEditJobDetailsDialog(BuildContext context, Job job) {
    final containerController = TextEditingController(
      text: job.containerNo ?? '',
    );
    final sealController = TextEditingController(text: job.sealNo ?? '');
    final trailerController = TextEditingController(text: job.trailerNo ?? '');
    final remarksController = TextEditingController(text: job.remarks ?? '');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.blue,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Job Details',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Job: ${job.no}',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container Number
                    _buildEditFieldLabel('Container Number'),
                    SizedBox(height: 6.h),
                    _buildEditTextField(
                      controller: containerController,
                      hint: 'Enter container number',
                      icon: Icons.inventory,
                    ),
                    SizedBox(height: 16.h),

                    // Seal Number
                    _buildEditFieldLabel('Seal Number'),
                    SizedBox(height: 6.h),
                    _buildEditTextField(
                      controller: sealController,
                      hint: 'Enter seal number',
                      icon: Icons.lock,
                    ),
                    SizedBox(height: 16.h),

                    // Trailer Number
                    _buildEditFieldLabel('Trailer Number'),
                    SizedBox(height: 6.h),
                    _buildEditTextField(
                      controller: trailerController,
                      hint: 'Enter trailer number',
                      icon: Icons.local_shipping,
                    ),
                    SizedBox(height: 16.h),

                    // Remarks
                    _buildEditFieldLabel('Remarks'),
                    SizedBox(height: 6.h),
                    _buildEditTextField(
                      controller: remarksController,
                      hint: 'Enter remarks',
                      icon: Icons.note_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isUpdatingJobDetails
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isUpdatingJobDetails
                      ? null
                      : () async {
                          await _updateJobDetailsAPI(
                            context: dialogContext,
                            job: job,
                            containerNo: containerController.text.trim(),
                            sealNo: sealController.text.trim(),
                            trailerNo: trailerController.text.trim(),
                            remarks: remarksController.text.trim(),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isUpdatingJobDetails
                      ? SizedBox(
                          width: 20.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildEditTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
        prefixIcon: Icon(icon, color: Colors.blue.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.blue.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w500),
    );
  }

  Future<void> _updateJobDetailsAPI({
    required BuildContext context,
    required Job job,
    required String containerNo,
    required String sealNo,
    required String trailerNo,
    required String remarks,
  }) async {
    setState(() {
      _isUpdatingJobDetails = true;
    });

    try {
      final jobApi = JobApi();
      final tenantId = ref.read(tenantIdProvider) ?? '';

      if (tenantId.isEmpty) {
        throw Exception('Tenant ID not found');
      }

      final response = await jobApi.updateJobDetails(
        jobNo: job.no ?? '',
        trailerID: job.id?.toString() ?? '',
        trailerNo: trailerNo,
        containerNo: containerNo,
        sealNo: sealNo,
        remarks: remarks,
        siteType: _selectedJobType,
        pickQty: job.pickQty ?? '0',
        dropQty: job.dropQty ?? '0',
        tenantId: tenantId,
      );

      if (!mounted) return;

      if (response['result'] == true || response['success'] == true) {
        CustomSnackBar.showSuccess(
          context,
          message: 'Job details updated successfully',
        );
        Navigator.pop(context);
        await _fetchJobs();
      } else {
        CustomSnackBar.showError(
          context,
          message: response['message'] ?? 'Failed to update job details',
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating job details: $e');
      if (mounted) {
        CustomSnackBar.showError(context, message: 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingJobDetails = false;
        });
      }
    }
  }

  /// Show dialog to update job activity (MDT function)
  void _showUpdateJobActivityDialog(BuildContext context, Job job) {
    final mdtFunctionsAsync = ref.read(enabledMDTFunctionsProvider);
    final currentMdtCode = job.mdtCode;

    mdtFunctionsAsync.when(
      data: (allFunctions) {
        // Filter MDT functions 100-108 (job status activities)
        final jobStatusFunctions = allFunctions
            .where((mdt) => mdt.mdtCode >= 100 && mdt.mdtCode <= 108)
            .toList();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Update Job Activity',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: jobStatusFunctions.isEmpty
                  ? Text(
                      'No job status activities available',
                      style: GoogleFonts.inter(fontSize: 11.sp),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: jobStatusFunctions.map((mdt) {
                        final isDisabled = mdt.mdtCode < currentMdtCode!;
                        final isCurrentlySelected =
                            mdt.mdtCode == currentMdtCode;
                        final color = mdt.mdtCode == 108
                            ? Colors.green
                            : (mdt.mdtCode == 100
                                  ? Colors.orange
                                  : Colors.blue);
                        final displayColor = isDisabled ? Colors.grey : color;

                        return Opacity(
                          opacity: isDisabled ? 0.8 : 1.0,
                          child: Container(
                            decoration: isCurrentlySelected
                                ? BoxDecoration(
                                    color: displayColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: displayColor,
                                      width: 1.5,
                                    ),
                                  )
                                : null,
                            child: InkWell(
                              onTap: isDisabled
                                  ? null
                                  : () async {
                                      final success = await _updateJobActivity(
                                        context,
                                        job,
                                        mdt.mdtCode,
                                        mdt.mdtDesc,
                                        color,
                                      );
                                      debugPrint(
                                        'Update Job Activity Success: $success',
                                      );
                                      Future.delayed(
                                        Duration(milliseconds: 300),
                                      );
                                      if (success) {
                                        // Show success snackbar
                                        _safeShowSnackBar(
                                          context,
                                          'Job status updated to: ${mdt.mdtDesc}',
                                          color,
                                        );
                                      } else {
                                        // Show error dialog
                                        _showErrorDialog(
                                          context,
                                          'Failed to update job activity. Please try again.',
                                        );
                                      }
                                    },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10.h,
                                  horizontal: 8.w,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6.h),
                                      decoration: BoxDecoration(
                                        color: displayColor.withValues(
                                          alpha: 0.2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isDisabled ? Icons.lock : Icons.circle,
                                        size: 10.h,
                                        color: displayColor,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mdt.mdtDesc,
                                            style: GoogleFonts.inter(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w600,
                                              color: isDisabled
                                                  ? Colors.grey
                                                  : null,
                                            ),
                                          ),
                                          // Text(
                                          //   'Code: ${mdt.mdtCode}${isDisabled ? ' (Completed)' : ''}${isCurrentlySelected ? ' (Current)' : ''}',
                                          //   style: GoogleFonts.inter(
                                          //     fontSize: 9.sp,
                                          //     color: Colors.grey,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                    if (isCurrentlySelected)
                                      Icon(
                                        Icons.check_circle,
                                        size: 18.h,
                                        color: displayColor,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontSize: 11.sp),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading MDT functions...')),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading MDT functions: \$error')),
        );
      },
    );
  }

  /// Update job activity via API - returns true if successful, false if failed
  Future<bool> _updateJobActivity(
    BuildContext context,
    Job job,
    int mdtCode,
    String mdtDesc,
    Color statusColor,
  ) async {
    // Show loading indicator
    if (!mounted) return false;

    late BuildContext dialogContext;

    try {
      // Don't await showDialog - just show it and continue
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          dialogContext = ctx;
          return const Center(child: CircularProgressIndicator());
        },
      );
      // Give the dialog a moment to appear
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error showing loading dialog: $e');
    }

    try {
      if (!mounted) return false;

      final jobApi = JobApi();
      final driverId = LoginCacheService().getCachedDriverId() ?? '';
      final tenantId = ref.read(tenantIdProvider) ?? '';
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final hasB2B = _hasValidB2B(job);

      // Update main job
      final result = await jobApi.updateJobWithDateTime(
        jobId: job.no ?? '',
        driverId: driverId,
        mdtCode: mdtCode.toString(),
        jobLastStatusDateTime: now,
        tenantId: tenantId,
      );

      if (!mounted) return false;

      // Close loading dialog immediately
      if (Navigator.canPop(dialogContext)) {
        Navigator.pop(dialogContext);
      }

      if (result['result'] == true) {
        // If B2B job exists, update it as well
        if (hasB2B && job.jobB2B != null && job.jobB2B!.isNotEmpty) {
          await jobApi.updateJobWithDateTime(
            jobId: job.jobB2B!,
            driverId: driverId,
            mdtCode: mdtCode.toString(),
            jobLastStatusDateTime: now,
            tenantId: tenantId,
          );
        }

        // Refresh job list after successful update
        await _fetchJobs();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (!mounted) return false;

      // Close loading dialog immediately
      if (Navigator.canPop(dialogContext)) {
        Navigator.pop(dialogContext);
      }

      debugPrint('Error updating job: $e');
      return false;
    }
  }

  /// Show custom error dialog for failed job update
  void _showErrorDialog(BuildContext context, String errorMessage) {
    try {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Update Failed',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unable to update job activity',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      errorMessage,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Please check the required fields and try again.',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'OK',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing error dialog: $e');
    }
  }

  /// Safely show snackbar without triggering deactivated widget errors
  void _safeShowSnackBar(BuildContext context, String message, Color bgColor) {
    try {
      if (mounted) {
        final duration = bgColor == Colors.red
            ? const Duration(seconds: 3)
            : const Duration(seconds: 2);

        if (bgColor == Colors.green) {
          CustomSnackBar.showSuccess(
            context,
            message: message,
            duration: duration,
          );
        } else {
          CustomSnackBar.showError(
            context,
            message: message,
            duration: duration,
          );
        }
      }
    } catch (e) {
      debugPrint('Error showing snackbar: $e');
    }
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
