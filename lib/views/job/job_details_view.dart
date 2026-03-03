import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/providers/jobs_provider.dart';

class JobDetailsView extends ConsumerStatefulWidget {
  final Job job;

  const JobDetailsView({super.key, required this.job});

  @override
  ConsumerState<JobDetailsView> createState() => _JobDetailsViewState();
}

class _JobDetailsViewState extends ConsumerState<JobDetailsView> {
  late TextEditingController _containerNoController;
  late TextEditingController _sealNoController;
  late TextEditingController _trailerIdController;
  late TextEditingController _remarksController;
  bool _headRun = false;
  bool _trailerRun = false;
  final ImagePicker _picker = ImagePicker();
  int _uploadedFilesCount = 0;
  late PageController _pageController;
  int _currentPage = 0;

  bool get _hasB2B {
    if (widget.job.b2bData == null) return false;
    final b2bValue = widget.job.jobB2B?.trim() ?? '';
    return b2bValue.isNotEmpty && b2bValue != '0' && b2bValue != widget.job.no;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _containerNoController = TextEditingController(
      text: widget.job.containerNo,
    );
    _sealNoController = TextEditingController(text: widget.job.sealNo);
    _trailerIdController = TextEditingController(text: widget.job.trailerNo);
    _remarksController = TextEditingController(text: widget.job.remarks);
    _headRun = widget.job.headRun ?? false;
    _trailerRun = widget.job.trailerRun ?? false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _containerNoController.dispose();
    _sealNoController.dispose();
    _trailerIdController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _uploadedFilesCount += images.length;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${images.length} files selected for upload'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _saveJobDetails() async {
    // Update job object with new values
    widget.job.containerNo = _containerNoController.text;
    widget.job.sealNo = _sealNoController.text;
    widget.job.trailerNo = _trailerIdController.text;
    widget.job.remarks = _remarksController.text;
    widget.job.headRun = _headRun;
    widget.job.trailerRun = _trailerRun;

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job details saved successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      // Navigate back
      Navigator.pop(context);
    }
  }

  void _showMDTFunctionDialog() {
    final mdtFunctionsAsync = ref.read(enabledMDTFunctionsProvider);
    final currentMdtCode = widget.job.mdtCode;

    mdtFunctionsAsync.when(
      data: (allFunctions) {
        // Filter MDT functions 100-108
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
                                  : () {
                                      setState(() {
                                        widget.job.mdtCode = mdt.mdtCode;
                                        widget.job.mdtCodef = mdt.mdtDesc;
                                      });
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Job status updated to: ${mdt.mdtDesc}',
                                          ),
                                          backgroundColor: color,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
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
                                          Text(
                                            'Code: ${mdt.mdtCode}${isDisabled ? ' (Completed)' : ''}${isCurrentlySelected ? ' (Current)' : ''}',
                                            style: GoogleFonts.inter(
                                              fontSize: 9.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
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
          SnackBar(content: Text('Error loading MDT functions: $error')),
        );
      },
    );
  }

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
          icon: Icon(Icons.arrow_back_ios_new, size: 16.h),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _hasB2B && _currentPage == 1 ? 'B2B Linked Job' : 'Job Details',
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: _hasB2B
            ? [
                Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe,
                        size: 14.h,
                        color: const Color(0xFFFF6B35),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${_currentPage + 1}/2',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveJobDetails,
        backgroundColor: const Color(0xFF4CAF50),
        icon: Icon(Icons.save, size: 16.h, color: Colors.white),
        label: Text(
          'Save',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: _hasB2B
          ? PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildJobDetailsContent(widget.job, colorScheme, isDark),
                _buildJobDetailsContent(
                  widget.job.b2bData!,
                  colorScheme,
                  isDark,
                  isB2B: true,
                ),
              ],
            )
          : _buildJobDetailsContent(widget.job, colorScheme, isDark),
    );
  }

  Widget _buildJobDetailsContent(
    Job job,
    ColorScheme colorScheme,
    bool isDark, {
    bool isB2B = false,
  }) {
    final cardColor = isB2B ? const Color(0xFFFF6B35) : const Color(0xFF3B82F6);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Job Number
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor.withValues(alpha: 0.12),
                    cardColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cardColor.withValues(alpha: 0.15),
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
                          color: cardColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.local_shipping,
                          color: cardColor,
                          size: 16.h,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job Number',
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              job.no!,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                color: cardColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 10.h, color: cardColor),
                        SizedBox(width: 4.w),
                        Text(
                          job.dateTime ?? "",
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: cardColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Container & Vehicle Details
            _buildSectionHeader(
              context,
              'Container & Vehicle Details',
              Icons.inventory_2,
              isDark,
            ),
            SizedBox(height: 6.h),
            _buildDetailsGrid(context, isDark, [
              {
                'label': 'Truck Number',
                'value': widget.job.truckNo,
                'icon': Icons.local_shipping,
              },
              {
                'label': 'Container No',
                'value': widget.job.containerNo,
                'icon': Icons.inventory_2,
              },
              {
                'label': 'Seal Number',
                'value': widget.job.sealNo,
                'icon': Icons.lock,
              },
              {
                'label': 'Trailer No',
                'value': widget.job.trailerNo,
                'icon': Icons.rv_hookup,
              },
              {
                'label': 'Container Size & Type',
                'value':
                    '${widget.job.containerSize ?? ''} ${widget.job.containerType ?? ''}'
                        .trim(),
                'icon': Icons.inventory,
              },
            ]),
            _buildSectionHeader(context, 'Job Information', Icons.edit, isDark),
            Container(
              padding: EdgeInsets.all(8.h),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Container No with QR Scanner
                  _buildEditableField(
                    context,
                    'Container No.',
                    _containerNoController,
                    Icons.inventory_2,
                    colorScheme,
                    isDark,
                    hasQrScanner: true,
                    isRequired: true,
                  ),
                  SizedBox(height: 8.h),
                  // Seal No with QR Scanner
                  _buildEditableField(
                    context,
                    'Seal No.',
                    _sealNoController,
                    Icons.lock,
                    colorScheme,
                    isDark,
                    hasQrScanner: true,
                    isRequired: true,
                  ),
                  SizedBox(height: 8.h),
                  // Trailer ID with QR Scanner
                  _buildEditableField(
                    context,
                    'Trailer ID',
                    _trailerIdController,
                    Icons.rv_hookup,
                    colorScheme,
                    isDark,
                    hasQrScanner: true,
                    isRequired: true,
                  ),
                  SizedBox(height: 8.h),
                  // Current Activity Status
                  _buildActivityStatusField(context, colorScheme, isDark),
                  SizedBox(height: 8.h),
                  // Upload Files
                  _buildUploadField(context, colorScheme, isDark),
                  SizedBox(height: 8.h),
                  // Driver Remarks
                  _buildRemarksField(context, colorScheme, isDark),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Location Details Section
            _buildSectionHeader(
              context,
              'Location Details',
              Icons.location_on,
              isDark,
            ),
            SizedBox(height: 6.h),
            _buildLocationCard(
              context: context,
              title: 'Pickup Location',
              shortCode: widget.job.pickOrgShortCode ?? "",
              fullAddress: widget.job.pickup ?? "",
              orgName: widget.job.pickOrgName ?? "",
              contactInfo: widget.job.pickOrgContPerNamePh ?? "",
              icon: Icons.location_on_outlined,
              color: Colors.green,
              isDark: isDark,
            ),
            SizedBox(height: 6.h),
            _buildLocationCard(
              context: context,
              title: 'Drop Location',
              shortCode: widget.job.dropOrgShortCode ?? "",
              fullAddress: widget.job.drop ?? "",
              orgName: widget.job.dropOrgName ?? "",
              contactInfo: widget.job.dropOrgContPerNamePh ?? "",
              icon: Icons.location_on,
              color: Colors.red,
              isDark: isDark,
            ),
            SizedBox(height: 20.h),

            _buildSectionHeader(
              context,
              'Job Information',
              Icons.info_outline,
              isDark,
            ),
            SizedBox(height: 6.h),
            _buildInfoCard(
              context: context,
              label: 'Customer',
              value: widget.job.customer ?? "",
              icon: Icons.business,
              isDark: isDark,
            ),
            _buildInfoCard(
              context: context,
              label: 'Master Order No',
              value: widget.job.masterOrderNo ?? "",
              icon: Icons.receipt_long,
              isDark: isDark,
            ),
            _buildInfoCard(
              context: context,
              label: 'Gate Pass No',
              value: widget.job.gatePassNo ?? "",
              icon: Icons.card_membership,
              isDark: isDark,
            ),
            _buildInfoCard(
              context: context,
              label: 'Gate Pass DateTime',
              value: widget.job.gatePassDatetime ?? "",
              icon: Icons.schedule,
              isDark: isDark,
            ),
            _buildInfoCard(
              context: context,
              label: 'Container Operator',
              value: widget.job.containerOperator ?? "",
              icon: Icons.supervised_user_circle,
              isDark: isDark,
            ),
            _buildInfoCard(
              context: context,
              label: 'Shipping Agent Ref',
              value: widget.job.shippingAgentRefNo ?? "",
              icon: Icons.verified_user,
              isDark: isDark,
            ),
            SizedBox(height: 10.h),

            // Additional Details
            _buildSectionHeader(
              context,
              'Additional Details',
              Icons.description,
              isDark,
            ),
            SizedBox(height: 6.h),
            _buildDetailsGrid(context, isDark, [
              {
                'label': 'Pickup Qty',
                'value': widget.job.pickQty,
                'icon': Icons.production_quantity_limits,
              },
              {
                'label': 'Drop Qty',
                'value': widget.job.dropQty,
                'icon': Icons.inventory,
              },
              {
                'label': 'Job Type',
                'value': widget.job.jobType,
                'icon': Icons.type_specimen,
              },
              {
                'label': 'Job Priority',
                'value': widget.job.joBpriority,
                'icon': Icons.priority_high,
              },
              {
                'label': 'Import/Export',
                'value': widget.job.jobImportExport,
                'icon': Icons.import_export,
              },
              {
                'label': 'B2B',
                'value': widget.job.jobB2B,
                'icon': Icons.business_center,
              },
            ]),

            // Remarks
            if (widget.job.remarks != null &&
                widget.job.remarks!.isNotEmpty &&
                widget.job.remarks != '--')
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.h),
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
                        Icon(Icons.notes, color: Colors.orange, size: 14.h),
                        SizedBox(width: 6.w),
                        Text(
                          'Remarks',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.job.remarks ?? "",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 6.h),

            // Delivery Instructions
            if (widget.job.deliveryInstruction != null &&
                widget.job.deliveryInstruction!.isNotEmpty &&
                widget.job.deliveryInstruction != '--')
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.h),
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
                        Icon(Icons.assignment, color: Colors.blue, size: 14.h),
                        SizedBox(width: 6.w),
                        Text(
                          'Delivery Instructions',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.job.deliveryInstruction ?? "",
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
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
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    bool isDark,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.08),
            colorScheme.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: colorScheme.primary, size: 13.h),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
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
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.04)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16.h),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    if (shortCode.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          shortCode,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
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
          SizedBox(height: 6.h),
          if (orgName.isNotEmpty && orgName != '--')
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                orgName,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          Text(
            fullAddress,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.4,
            ),
          ),
          if (contactInfo.isNotEmpty && contactInfo != '--') ...[
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.phone, size: 12.h, color: color),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    contactInfo,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
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
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.all(8.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 12.h),
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

    // Filter out empty items first
    final filteredItems = items.where((item) {
      final value = item['value'] as String;
      return value.isNotEmpty && value != '--';
    }).toList();

    if (filteredItems.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 3,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final value = item['value'] as String;

        return Container(
          padding: EdgeInsets.all(8.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.h),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: colorScheme.primary,
                      size: 12.h,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      item['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditableField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
    ColorScheme colorScheme,
    bool isDark, {
    bool hasQrScanner = false,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: GoogleFonts.inter(fontSize: 10.sp, color: Colors.grey),
            prefixIcon: Icon(icon, size: 14.h),
            suffixIcon: hasQrScanner
                ? IconButton(
                    icon: Icon(
                      CupertinoIcons.qrcode_viewfinder,
                      size: 16.h,
                      color: colorScheme.primary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('QR Scanner coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  )
                : null,
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 8.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityStatusField(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // Determine current status
    final mdtCode = widget.job.mdtCode;
    final mdtDesc = widget.job.mdtCodef;

    final Color statusColor;
    final IconData statusIcon;
    final String statusText;

    if (mdtCode == null || mdtCode == 0 || mdtCode < 100) {
      statusColor = Colors.red;
      statusIcon = Icons.circle;
      statusText = 'NOT STARTED';
    } else if (mdtCode == 108) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = mdtDesc != null && mdtDesc.isNotEmpty
          ? mdtDesc
          : 'COMPLETED';
    } else if (mdtCode >= 100 && mdtCode < 108) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = mdtDesc != null && mdtDesc.isNotEmpty
          ? mdtDesc
          : 'IN PROGRESS';
    } else {
      statusColor = Colors.blue;
      statusIcon = Icons.info;
      statusText = mdtDesc != null && mdtDesc.isNotEmpty ? mdtDesc : 'UNKNOWN';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Job Activity',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        InkWell(
          onTap: _showMDTFunctionDialog,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, size: 8.h, color: statusColor),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (mdtCode != null && mdtCode > 0)
                        Text(
                          'Code: $mdtCode',
                          style: GoogleFonts.inter(
                            fontSize: 8.sp,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: 16.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadField(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload to File',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.file_upload_outlined,
                  size: 16.h,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  '$_uploadedFilesCount files uploaded',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.add_circle_outline,
                  size: 16.h,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksField(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Driver Remarks',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        TextField(
          controller: _remarksController,
          maxLines: 3,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Enter remarks...',
            hintStyle: GoogleFonts.inter(fontSize: 10.sp, color: Colors.grey),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 8.h,
            ),
          ),
        ),
      ],
    );
  }
}
