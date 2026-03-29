import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vcore_v5_app/models/job_model.dart';
import 'package:vcore_v5_app/models/trailer_search_model.dart';
import 'package:vcore_v5_app/models/uploaded_file_model.dart';
import 'package:vcore_v5_app/providers/connectivity_provider.dart';
import 'package:vcore_v5_app/providers/jobs_provider.dart';
import 'package:vcore_v5_app/providers/user_provider.dart';
import 'package:vcore_v5_app/providers/trailer_search_provider.dart';
import 'package:vcore_v5_app/services/api/job_api.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';
import 'package:vcore_v5_app/widgets/custom_snack_bar.dart';

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
  bool _isUploadingImages = false;
  late PageController _pageController;
  int _currentPage = 0;

  // Trailer search state
  Timer? _trailerSearchDebounce;
  List<TrailerSearchResult> _trailerSearchResults = [];
  bool _isSearchingTrailers = false;
  bool _isSelectingTrailer = false;
  final FocusNode _trailerFocusNode = FocusNode();
  String _selectedTrailerId = ''; // Store selected trailer ID
  ConnectivityService _connectivityService = ConnectivityService();
  final JobApi _jobApi = JobApi();
  List<UploadedFile> _uploadedImages = [];
  bool _isLoadingImages = false;

  // Cached tenant ID from login cache
  String? _cachedTenantId;

  bool get _hasB2B {
    if (widget.job.b2bData == null) return false;
    final b2bValue = widget.job.jobB2B?.trim() ?? '';
    return b2bValue.isNotEmpty && b2bValue != '0' && b2bValue != widget.job.no;
  }

  Job get _activeImageJob {
    if (_hasB2B && _currentPage == 1 && widget.job.b2bData != null) {
      return widget.job.b2bData!;
    }
    return widget.job;
  }

  String get _activeImageJobNo => _activeImageJob.id?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    // Cache tenant ID from login cache service
    _cachedTenantId = LoginCacheService().getCachedTenantId();

    _pageController = PageController();
    _containerNoController = TextEditingController(
      text: widget.job.containerNo,
    );
    _sealNoController = TextEditingController(text: widget.job.sealNo);
    _trailerIdController = TextEditingController(text: widget.job.trailerNo);
    _remarksController = TextEditingController(text: widget.job.remarks);
    _selectedTrailerId = widget.job.trailerId ?? ''; // Initialize trailer ID
    _headRun = widget.job.headRun ?? false;
    _trailerRun = widget.job.trailerRun ?? false;

    // Add listener for trailer search
    _trailerIdController.addListener(_onTrailerSearchChanged);

    // Fetch uploaded images
    _fetchUploadedImages();

    // Initialize trailer ID from current job
    _initializeTrailerInfo();

    // Pre-cache job-related data for offline availability
    _preloadJobDetailsCache();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _containerNoController.dispose();
    _sealNoController.dispose();
    _trailerIdController.removeListener(_onTrailerSearchChanged);
    _trailerIdController.dispose();
    _remarksController.dispose();
    _trailerSearchDebounce?.cancel();
    _trailerFocusNode.dispose();
    super.dispose();
  }

  /// Update page details (seal, container, trailer) when page changes
  /// This ensures form fields reflect the B2B data for the current page
  Future<void> _updatePageDetails() async {
    try {
      final currentJob = _currentPage == 0 ? widget.job : widget.job.b2bData;
      if (currentJob == null) return;

      // Update text controllers with current page's data
      setState(() {
        _containerNoController.text = currentJob.containerNo ?? '';
        _sealNoController.text = currentJob.sealNo ?? '';
        _trailerIdController.text = currentJob.trailerNo ?? '';
        _selectedTrailerId = currentJob.trailerId ?? '';
        _headRun = currentJob.headRun ?? false;
        _trailerRun = currentJob.trailerRun ?? false;
      });

      print(
        '📄 Updated page details for page $_currentPage: container=${currentJob.containerNo}, seal=${currentJob.sealNo}, trailer=${currentJob.trailerNo}',
      );
    } catch (e) {
      print('❌ Error updating page details: $e');
    }
  }

  /// Initialize trailer ID from current job trailer number
  /// Searches for the trailer and auto-sets _selectedTrailerId
  Future<void> _initializeTrailerInfo() async {
    try {
      final trailerNo = widget.job.trailerNo?.trim() ?? '';
      if (trailerNo.isEmpty) {
        print('⚠️ No trailer number in job, skipping initialization');
        return;
      }

      final tenantId = _cachedTenantId;
      if (tenantId == null) {
        print('⚠️ No tenant ID available, skipping trailer initialization');
        return;
      }

      final containerSize = widget.job.containerSize ?? '40';
      final size = containerSize.replaceAll(RegExp(r'[^0-9]'), '');
      final sizeToUse = size.isEmpty ? '40' : size;

      print(
        '🔍 Initializing trailer info: trailerNo=$trailerNo, size=$sizeToUse',
      );

      // Search for the trailer
      final results = await trailerSearchManager.searchTrailers(
        query: trailerNo,
        trSize: sizeToUse,
        tenantId: (tenantId),
      );

      if (results.isNotEmpty) {
        // Auto-select the first matching trailer
        final selectedTrailer = results.first;
        final trailerId = selectedTrailer.trailerID;
        if (mounted) {
          setState(() {
            _selectedTrailerId = trailerId;
          });
        }
        print('✅ Trailer initialized: $_selectedTrailerId');
        print(
          '✅ Trailer details: ${selectedTrailer.trailerRegNo}, ${selectedTrailer.trailerSize}',
        );
      } else {
        print('⚠️ No trailers found for number: $trailerNo');
      }
    } catch (e) {
      print('❌ Error initializing trailer info: $e');
      // Don't show error snackbar for initialization, just log it
    }
  }

  /// Pre-load job-related data for offline availability
  /// Caches job images in the background without blocking UI
  Future<void> _preloadJobDetailsCache() async {
    try {
      final jobNo = _activeImageJobNo;
      if (jobNo.isEmpty) {
        print('⚠️ No job number available for pre-cache, skipping');
        return;
      }

      print('📷 Pre-caching images for job: $jobNo');

      // Cache images for this job in the background
      // This method already has built-in caching, so if offline or on retry,
      // previously cached images will be returned
      await _jobApi.getJobImages(jobNo: jobNo);

      print('✅ Successfully pre-cached images for job: $jobNo');
    } catch (e) {
      // Log but don't error - pre-cache is non-critical
      print('⚠️ Failed to pre-cache images: $e');
    }
  }

  /// Fetch uploaded images for this job
  Future<void> _fetchUploadedImages() async {
    final jobNo = _activeImageJobNo;
    if (jobNo.isEmpty) {
      if (mounted) {
        setState(() {
          _uploadedImages = [];
          _uploadedFilesCount = 0;
          _isLoadingImages = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingImages = true;
      });
    }

    try {
      print('📷 Fetching images for job: $jobNo (page: ${_currentPage + 1})');
      final images = await _jobApi.getJobImages(jobNo: _activeImageJobNo);
      print('✅ Fetched ${images.length} images');

      if (mounted) {
        setState(() {
          _uploadedImages = images;
          _uploadedFilesCount = images.length;
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching images: $e');
      if (mounted) {
        setState(() {
          _isLoadingImages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// View full-size image
  void _viewImage(UploadedFile image) {
    print('🖼️ Viewing image: ${image.name}');
    try {
      // Decode base64 image data
      final imageBytes = base64Decode(image.data);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                // Image
                InteractiveViewer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(imageBytes, fit: BoxFit.contain),
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 24.r),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                // Image name
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      image.name,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('❌ Error viewing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to display image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImages() async {
    try {
      print('🔵 _pickImages called');
      final activeJobNo = _activeImageJobNo;
      if (activeJobNo.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job number is missing, cannot upload images'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Show action sheet for camera or gallery
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Camera',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      print('📷 Camera selected');
                      Navigator.pop(context, ImageSource.camera);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: Icon(
                      Icons.photo_library,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Gallery',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      print('🖼️ Gallery selected');
                      Navigator.pop(context, ImageSource.gallery);
                    },
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          );
        },
      );

      print('✅ Source selected: $source');
      if (source == null) {
        print('⚠️ No source selected, returning');
        return;
      }

      List<XFile> images = [];
      if (source == ImageSource.camera) {
        print('📸 Opening camera...');
        final photo = await _picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          images.add(photo);
          print('✅ Camera photo captured: ${photo.path}');
        } else {
          print('⚠️ No photo captured');
        }
      } else {
        print('🖼️ Opening gallery...');
        images = await _picker.pickMultiImage();
        print('✅ ${images.length} images selected from gallery');
      }

      if (images.isEmpty) {
        print('⚠️ No images selected, returning');
        return;
      }

      if (!mounted) {
        print('⚠️ Widget not mounted, returning');
        return;
      }

      print('💬 Showing confirmation dialog for ${images.length} images');
      // Show confirmation
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            'Upload Images',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Upload ${images.length} image(s) for job ${widget.job.no}?',
            style: GoogleFonts.inter(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('❌ Upload cancelled');
                Navigator.pop(context, false);
              },
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
              onPressed: () {
                print('✅ Upload confirmed');
                Navigator.pop(context, true);
              },
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

      print('💬 Confirmation result: $confirm');
      if (confirm != true || !mounted) {
        print('⚠️ Upload not confirmed or widget not mounted');
        return;
      }

      print('🚀 Starting upload...');
      // Upload images
      await _uploadImages(images);
    } catch (e, stackTrace) {
      print('❌ Error in _pickImages: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImages(List<XFile> images) async {
    setState(() {
      _isUploadingImages = true;
    });

    try {
      int successCount = 0;
      int queuedCount = 0;
      final activeJobNo = _activeImageJobNo;

      if (activeJobNo.isEmpty) {
        throw Exception('Job number is missing, cannot upload images');
      }

      for (var image in images) {
        try {
          final fileName =
              '$activeJobNo-${DateFormat("yyyyMMddHHmmss").format(DateTime.now())}';

          // Use JobApi method which supports offline queuing
          final uploadResult = await _jobApi.uploadJobImage(
            jobNo: _activeImageJob.id?.toString() ?? '',
            filePath: image.path,
            fileName: fileName,
          );

          if (uploadResult['result'] == true) {
            successCount++;
            if (uploadResult['queued'] == true) {
              queuedCount++;
              print('📋 Image queued for sync: $fileName');
            } else {
              print('✅ Image uploaded: $fileName');
            }
          } else {
            print('❌ Failed to upload image: ${uploadResult['message']}');
          }
        } catch (e) {
          print('❌ Failed to upload image: $e');
        }
      }

      if (mounted) {
        setState(() {
          _uploadedFilesCount +=
              (successCount - queuedCount); // Count only actual uploads
          _isUploadingImages = false;
        });

        // Show different messages based on results
        if (successCount > 0) {
          String message;
          if (queuedCount > 0) {
            message =
                '${successCount - queuedCount} image(s) uploaded, $queuedCount queued for sync';
          } else {
            message = '$successCount image(s) uploaded successfully';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: queuedCount > 0 ? Colors.orange : Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Refresh the image list (for successfully uploaded images)
          if (successCount - queuedCount > 0) {
            _fetchUploadedImages();
          }
        }

        if (successCount < images.length) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${images.length - successCount} image(s) failed to upload',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Upload error: $e');
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Open location in maps app
  Future<void> _openInMaps(String address) async {
    if (address.isEmpty) {
      _safeShowSnackBar(
        context,
        'Location address is not available',
        Colors.orange,
      );
      return;
    }

    try {
      // URL encode the address
      final encodedAddress = Uri.encodeComponent(address);

      // Create a universal map URL that works on both platforms
      // This will open in Google Maps on Android and Apple Maps on iOS
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _safeShowSnackBar(context, 'Could not open maps', Colors.red);
        }
      }
    } catch (e) {
      debugPrint('❌ Error opening maps: $e');
      if (mounted) {
        _safeShowSnackBar(
          context,
          'Error opening maps: ${e.toString()}',
          Colors.red,
        );
      }
    }
  }

  Future<void> _saveJobDetails() async {
    if (!mounted) return;

    // Validate required fields
    final containerNo = _containerNoController.text.trim();
    final sealNo = _sealNoController.text.trim();
    final trailerNo = _trailerIdController.text.trim();

    if (containerNo.isEmpty) {
      CustomSnackBar.showError(
        context,
        message: 'Container No is required',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (sealNo.isEmpty) {
      CustomSnackBar.showError(
        context,
        message: 'Seal No is required',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (trailerNo.isEmpty) {
      CustomSnackBar.showError(
        context,
        message: 'Trailer No is required',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (_selectedTrailerId.isEmpty) {
      CustomSnackBar.showError(
        context,
        message: 'Please select a valid Trailer from the search results',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final jobApi = JobApi();
      final tenantId = ref.read(tenantIdProvider) ?? '';
      final remarks = _remarksController.text.trim();

      // Determine which job to update based on current page
      final activeJob = _currentPage == 0 ? widget.job : widget.job.b2bData;
      if (activeJob == null) {
        throw Exception('Active job not found');
      }

      final jobNo = activeJob.no ?? '';
      final pickQty = activeJob.pickQty ?? '0';
      final dropQty = activeJob.dropQty ?? '0';

      print(
        '💾 Saving job details for page $_currentPage: jobNo=$jobNo (${_currentPage == 0 ? 'Main' : 'B2B'})',
      );

      // Update the appropriate job
      final result = await jobApi.updateJobDetails(
        jobNo: jobNo,
        trailerNo: _selectedTrailerId,
        trailerID: trailerNo,
        containerNo: containerNo,
        sealNo: sealNo,
        remarks: remarks,
        siteType: 'HMS',
        pickQty: pickQty,
        dropQty: dropQty,
        tenantId: tenantId,
      );
      print('✅ Job update result: ${jsonEncode(result)}');
      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Update the appropriate job object (for both online success and queued offline)
      activeJob.containerNo = containerNo;
      activeJob.sealNo = sealNo;
      activeJob.trailerNo = trailerNo;
      activeJob.remarks = remarks;
      activeJob.headRun = _headRun;
      activeJob.trailerRun = _trailerRun;

      if (result['Result'] == true || result['queued'] == true) {
        print(
          '✅ Job updated successfully: ${_currentPage == 0 ? 'Main Job' : 'B2B Job'}',
        );

        if (mounted) {
          // Show different message for queued vs saved
          if (result['queued'] == true) {
            CustomSnackBar.showSuccess(
              context,
              message: 'Job queued - will sync when online',
              duration: const Duration(seconds: 3),
            );
          } else {
            CustomSnackBar.showSuccess(
              context,
              message: 'Job details saved successfully',
              duration: const Duration(seconds: 2),
            );
          }
          // Stay on the job details page - don't pop
          setState(() {});
        }
      } else {
        final errorMessage =
            result['message'] ??
            result['error'] ??
            'Failed to save job details';
        if (mounted) {
          CustomSnackBar.showError(
            context,
            message: errorMessage,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error saving job details: $e');
      if (!mounted) return;

      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        CustomSnackBar.showError(
          context,
          message: 'Error saving job details: $e',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  // Trailer search methods
  void _onTrailerSearchChanged() {
    // Skip if we're programmatically setting the value
    if (_isSelectingTrailer) {
      return;
    }

    final query = _trailerIdController.text.trim();

    // Cancel previous debounce timer
    _trailerSearchDebounce?.cancel();

    if (query.isEmpty) {
      // _hideTrailerOverlay();
      setState(() {
        _trailerSearchResults = [];
        _isSearchingTrailers = false;
      });
      return;
    }

    // Set debounce timer for 500ms
    _trailerSearchDebounce = Timer(const Duration(milliseconds: 500), () {
      _searchTrailers(query);
    });
  }

  Future<void> _searchTrailers(String query) async {
    if (!mounted) return;

    setState(() {
      _isSearchingTrailers = true;
    });

    try {
      final tenantId = _cachedTenantId;
      if (tenantId == null) {
        throw Exception('Tenant ID not found');
      }

      final containerSize = widget.job.containerSize ?? '40';
      final size = containerSize.replaceAll(RegExp(r'[^0-9]'), '');
      final sizeToUse = size.isEmpty ? '40' : size;

      print(
        '🔍 Searching trailers: query=$query, size=$sizeToUse, tenantId=$tenantId',
      );

      final results = await trailerSearchManager.searchTrailers(
        query: query,
        trSize: sizeToUse,
        tenantId: (tenantId),
      );

      print('✅ Got ${results.length} trailer results');

      if (mounted) {
        setState(() {
          _trailerSearchResults = results;
          _isSearchingTrailers = false;
        });
      }
    } catch (e) {
      print('❌ Error searching trailers: $e');
      if (mounted) {
        setState(() {
          _isSearchingTrailers = false;
          _trailerSearchResults = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching trailers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [
        //         colorScheme.primaryContainer.withValues(alpha: 0.3),
        //         colorScheme.secondaryContainer.withValues(alpha: 0.2),
        //       ],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //     ),
        //   ),
        // ),
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.arrow_back_ios_new,
        //     size: 16.h,
        //     color: colorScheme.primary,
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
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
                // Update Job Activity Button
                // Padding(
                //   padding: EdgeInsets.only(right: 8.w),
                //   child: Tooltip(
                //     message: 'Update Job Activity',
                //     child: IconButton(
                //       icon: Icon(Icons.update, size: 20.h, color: Colors.blue),
                //       onPressed: () => _showUpdateJobActivityDialog(
                //         context,
                //         _currentPage == 0 ? widget.job : widget.job.b2bData!,
                //       ),
                //     ),
                //   ),
                // ),
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
            : [
                // Update Job Activity Button (for non-B2B)
                // Padding(
                //   padding: EdgeInsets.only(right: 8.w),
                //   child: Tooltip(
                //     message: 'Update Job Activity',
                //     child: IconButton(
                //       icon: Icon(Icons.update, size: 20.h, color: Colors.blue),
                //       onPressed: () =>
                //           _showUpdateJobActivityDialog(context, widget.job),
                //     ),
                //   ),
                // ),
              ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF4CAF50), Color(0xFF43A047)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _saveJobDetails,
          backgroundColor: Colors.transparent,
          elevation: 0,
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
      ),
      body: SafeArea(
        child: _hasB2B
            ? PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                  _updatePageDetails();
                  _fetchUploadedImages();
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
      ),
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
                    cardColor.withValues(alpha: 0.2),
                    colorScheme.primaryContainer.withValues(alpha: 0.3),
                    cardColor.withValues(alpha: 0.15),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cardColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withValues(alpha: 0.15),
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

            // B2B Linked Job Card (only show on main job page)
            if (_hasB2B && !isB2B && widget.job.b2bData != null) ...[
              SizedBox(height: 6.h),
              Column(
                children: [
                  InkWell(
                    onTap: () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFF6B35).withValues(alpha: 0.15),
                            const Color(0xFFFF6B35).withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF6B35,
                            ).withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.h),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFF6B35,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.link,
                              color: const Color(0xFFFF6B35),
                              size: 16.h,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Linked B2B Job',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(
                                      0xFFFF6B35,
                                    ).withValues(alpha: 0.8),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  widget.job.b2bData!.no ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFFF6B35),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFF6B35,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.swipe_right,
                                  size: 12.h,
                                  color: const Color(0xFFFF6B35),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Swipe To View',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFFF6B35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 12.h),
            // Container & Vehicle Details
            _buildSectionHeader(
              context,
              'Container & Vehicle Details',
              Icons.inventory_2,
              isDark,
            ),

            _buildDetailsGrid(context, isDark, [
              {
                'label': 'Truck Number',
                'value': widget.job.truckNo,
                'icon': Icons.local_shipping,
              },
              // {
              //   'label': 'Container No',
              //   'value': widget.job.containerNo,
              //   'icon': Icons.inventory_2,
              // },
              // {
              //   'label': 'Seal Number',
              //   'value': widget.job.sealNo,
              //   'icon': Icons.lock,
              // },
              // {
              //   'label': 'Trailer No',
              //   'value': widget.job.trailerNo,
              //   'icon': Icons.rv_hookup,
              // },
              {
                'label': 'Container Size & Type',
                'value':
                    '${widget.job.containerSize ?? ''} ${widget.job.containerType ?? ''}'
                        .trim(),
                'icon': Icons.inventory,
              },
            ]),
            SizedBox(height: 16.h),
            _buildSectionHeader(context, 'Job Details', Icons.edit, isDark),

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
                  // Trailer ID with QR Scanner and Search
                  Column(
                    children: [
                      _buildEditableField(
                        context,
                        'Trailer ID',
                        _trailerIdController,
                        Icons.rv_hookup,
                        colorScheme,
                        isDark,
                        hasQrScanner: true,
                        isRequired: true,

                        focusNode: _trailerFocusNode,
                      ),
                      // Direct dropdown below field
                      if (_trailerSearchResults.isNotEmpty ||
                          _isSearchingTrailers)
                        Container(
                          margin: EdgeInsets.only(top: 4.h),
                          constraints: BoxConstraints(maxHeight: 200.h),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isSearchingTrailers
                              ? Padding(
                                  padding: EdgeInsets.all(16.h),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.h,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: _trailerSearchResults.length,
                                  itemBuilder: (context, index) {
                                    final trailer =
                                        _trailerSearchResults[index];
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isSelectingTrailer = true;
                                          _trailerSearchResults = [];
                                          _isSearchingTrailers = false;
                                          // Store both trailer ID and number
                                          _selectedTrailerId = trailer.trailerID
                                              .toString();
                                          _trailerIdController.text =
                                              trailer.trailerRegNo;
                                        });
                                        _trailerFocusNode.unfocus();
                                        // Reset flag after a short delay
                                        Future.delayed(
                                          const Duration(milliseconds: 100),
                                          () {
                                            if (mounted) {
                                              setState(() {
                                                _isSelectingTrailer = false;
                                              });
                                            }
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: colorScheme.outline
                                                  .withValues(alpha: 0.1),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.rv_hookup,
                                              size: 16.h,
                                              color: colorScheme.primary,
                                            ),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    trailer.trailerRegNoDisp,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    'ID: ${trailer.trailerID}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 9.sp,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Current Activity Status
                  _buildActivityStatusField(context, colorScheme, isDark),
                  SizedBox(height: 8.h),
                  // Upload Files
                  _buildUploadField(context, colorScheme, isDark),
                  SizedBox(height: 8.h),
                  // Image Gallery
                  _buildImageGallery(context, colorScheme, isDark),
                  SizedBox(height: 8.h),
                  // Driver Remarks
                  _buildRemarksField(context, colorScheme, isDark),
                ],
              ),
            ),
            SizedBox(height: 15.h),

            // Location Details Section
            _buildSectionHeader(
              context,
              'Location Details',
              Icons.location_on,
              isDark,
            ),

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
              onTap: () => _openInMaps(widget.job.pickup ?? ""),
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
              onTap: () => _openInMaps(widget.job.drop ?? ""),
            ),
            SizedBox(height: 15.h),

            // _buildInfoCard(
            //   context: context,
            //   label: 'Customer',
            //   value: widget.job.customer ?? "",
            //   icon: Icons.business,
            //   isDark: isDark,
            // ),
            // _buildInfoCard(
            //   context: context,
            //   label: 'Master Order No',
            //   value: widget.job.masterOrderNo ?? "",
            //   icon: Icons.receipt_long,
            //   isDark: isDark,
            // ),
            // _buildInfoCard(
            //   context: context,
            //   label: 'Gate Pass No',
            //   value: widget.job.gatePassNo ?? "",
            //   icon: Icons.card_membership,
            //   isDark: isDark,
            // ),
            // _buildInfoCard(
            //   context: context,
            //   label: 'Gate Pass DateTime',
            //   value: widget.job.gatePassDatetime ?? "",
            //   icon: Icons.schedule,
            //   isDark: isDark,
            // ),
            if (widget.job.deliveryInstruction != null &&
                widget.job.deliveryInstruction!.isNotEmpty &&
                widget.job.deliveryInstruction != '--') ...[
              _buildSectionHeader(
                context,
                'Job Information',
                Icons.info_outline,
                isDark,
              ),
              SizedBox(height: 6.h),
              _buildInfoCard(
                context: context,
                label: 'Container Operator',
                value: widget.job.containerOperator ?? "",
                icon: Icons.supervised_user_circle,
                isDark: isDark,
              ),
              // _buildInfoCard(
              //   context: context,
              //   label: 'Shipping Agent Ref',
              //   value: widget.job.shippingAgentRefNo ?? "",
              //   icon: Icons.verified_user,
              //   isDark: isDark,
              // ),
              SizedBox(height: 10.h),
            ],

            // Additional Details
            // _buildSectionHeader(
            //   context,
            //   'Additional Details',
            //   Icons.description,
            //   isDark,
            // ),
            // SizedBox(height: 6.h),
            // _buildDetailsGrid(context, isDark, [
            //   {
            //     'label': 'Pickup Qty',
            //     'value': widget.job.pickQty,
            //     'icon': Icons.production_quantity_limits,
            //   },
            //   {
            //     'label': 'Drop Qty',
            //     'value': widget.job.dropQty,
            //     'icon': Icons.inventory,
            //   },
            //   {
            //     'label': 'Job Type',
            //     'value': widget.job.jobType,
            //     'icon': Icons.type_specimen,
            //   },
            //   {
            //     'label': 'Job Priority',
            //     'value': widget.job.joBpriority,
            //     'icon': Icons.priority_high,
            //   },
            //   {
            //     'label': 'Import/Export',
            //     'value': widget.job.jobImportExport,
            //     'icon': Icons.import_export,
            //   },
            //   {
            //     'label': 'B2B',
            //     'value': widget.job.jobB2B,
            //     'icon': Icons.business_center,
            //   },
            // ]),

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
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [
      //       colorScheme.primaryContainer.withValues(alpha: 0.6),
      //       colorScheme.secondaryContainer.withValues(alpha: 0.4),
      //       colorScheme.primary.withValues(alpha: 0.1),
      //     ],
      //   ),
      //   borderRadius: BorderRadius.circular(8),
      //   border: Border.all(
      //     color: colorScheme.primary.withValues(alpha: 0.4),
      //     width: 1.5,
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: colorScheme.primary.withValues(alpha: 0.15),
      //       blurRadius: 6,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.h),

            child: Icon(icon, color: colorScheme.secondary, size: 13.h),
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.04),
            ],
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

                      if (shortCode.isNotEmpty) ...[
                        Container(
                          margin: EdgeInsets.only(top: 2.h),
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
                      if (fullAddress.isNotEmpty) ...[
                        Container(
                          margin: EdgeInsets.only(top: 2.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
                          ),
                          // decoration: BoxDecoration(
                          //   color: color.withValues(alpha: 0.15),
                          //   borderRadius: BorderRadius.circular(5),
                          // ),
                          child: Text(
                            fullAddress,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
        gradient: LinearGradient(
          colors: [
            colorScheme.surfaceContainerHigh,
            colorScheme.tertiaryContainer.withValues(alpha: 0.2),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(5.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.25),
                  colorScheme.tertiary.withValues(alpha: 0.2),
                ],
              ),
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
        childAspectRatio: 2.7,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final value = item['value'] as String;

        return Container(
          padding: EdgeInsets.all(8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.surfaceContainerHigh,
                colorScheme.primaryContainer.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 6,
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
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer.withValues(alpha: 0.5),
                          colorScheme.secondaryContainer.withValues(alpha: 0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
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
    FocusNode? focusNode,
    bool? isEnabled,
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
          focusNode: focusNode,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
          enabled: isEnabled ?? true,
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
              vertical: 0.h,
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
    final mdtFunctionsAsync = ref.read(availableMDTFunctionsProvider);

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
      statusText = mdtFunctionsAsync.value!
          .firstWhere((f) => f.mdtCode == mdtCode)
          .mdtDesc;
    } else if (mdtCode >= 100 && mdtCode < 108) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = statusText = mdtFunctionsAsync.value!
          .firstWhere((f) => f.mdtCode == mdtCode)
          .mdtDesc;
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
          onTap: () => _showUpdateJobActivityDialog(context, widget.job),
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
                      // if (mdtCode != null && mdtCode > 0)
                      //   Text(
                      //     'Code: $mdtCode',
                      //     style: GoogleFonts.inter(
                      //       fontSize: 8.sp,
                      //       color: isDark ? Colors.white60 : Colors.black54,
                      //     ),
                      //   ),
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
          onTap: _isUploadingImages ? null : _pickImages,
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
                _isUploadingImages
                    ? SizedBox(
                        width: 16.h,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.file_upload_outlined,
                        size: 16.h,
                        color: colorScheme.primary,
                      ),
                SizedBox(width: 8.w),
                Text(
                  _isUploadingImages
                      ? 'Uploading...'
                      : '$_uploadedFilesCount files uploaded',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (!_isUploadingImages)
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

  Widget _buildImageGallery(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (_isLoadingImages) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (_uploadedImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Images (${_uploadedImages.length})',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 120.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _uploadedImages.length,
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final image = _uploadedImages[index];
              final imageBytes = base64Decode(image.data);

              return InkWell(
                onTap: () => _viewImage(image),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surfaceContainerHigh,
                        colorScheme.primaryContainer.withValues(alpha: 0.15),
                      ],
                    ),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          imageBytes,
                          width: 100.w,
                          height: 120.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Overlay with magnifying glass icon
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 24.r,
                          ),
                        ),
                      ),
                      // Image name at bottom
                      Positioned(
                        bottom: 4.h,
                        left: 4.w,
                        right: 4.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            image.name.split('-').last,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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

  /// Show dialog to select and update job activity
  void _showUpdateJobActivityDialog(BuildContext context, Job job) {
    final mdtFunctionsAsync = ref.read(availableMDTFunctionsProvider);
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
                                      // Update main job
                                      final mainSuccess =
                                          await _updateJobActivity(
                                            context,
                                            widget.job,
                                            mdt.mdtCode,
                                            mdt.mdtDesc,
                                            color,
                                          );

                                      // If B2B job exists, update it too
                                      bool b2bSuccess = true;
                                      if (_hasB2B &&
                                          widget.job.b2bData != null) {
                                        b2bSuccess = await _updateJobActivity(
                                          context,
                                          widget.job.b2bData!,
                                          mdt.mdtCode,
                                          mdt.mdtDesc,
                                          color,
                                        );
                                      }

                                      if (mounted) {
                                        if (mainSuccess && b2bSuccess) {
                                          _safeShowSnackBar(
                                            context,
                                            _hasB2B
                                                ? 'Both jobs updated to: ${mdt.mdtDesc}'
                                                : 'Job status updated to: ${mdt.mdtDesc}',
                                            color,
                                          );
                                          // Close dialog and pop to job list with result=true to trigger refresh
                                          Navigator.pop(
                                            context,
                                          ); // Close activity dialog
                                          Future.delayed(
                                            const Duration(milliseconds: 300),
                                            () {
                                              if (mounted) {
                                                Navigator.pop(
                                                  context,
                                                  true, // Signal that activity was updated
                                                ); // Pop to job list
                                              }
                                            },
                                          );
                                        } else {
                                          _showErrorDialog(
                                            context,
                                            'Failed to update job activity. Please try again.',
                                          );
                                        }
                                      }
                                    },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 10.h,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12.w,
                                      height: 12.h,
                                      decoration: BoxDecoration(
                                        color: displayColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mdt.mdtDesc,
                                            style: GoogleFonts.inter(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: displayColor,
                                            ),
                                          ),
                                          // Text(
                                          //   'Code: ${mdt.mdtCode}',
                                          //   style: GoogleFonts.inter(
                                          //     fontSize: 10.sp,
                                          //     color: Colors.grey,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                    if (isCurrentlySelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: displayColor,
                                        size: 20.sp,
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
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => const AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          ),
        );
      },
      error: (error, _) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(
              'Error',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Failed to load job activities: $error',
              style: GoogleFonts.inter(fontSize: 11.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: GoogleFonts.inter(fontSize: 12.sp)),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Update job activity with B2B support
  Future<bool> _updateJobActivity(
    BuildContext context,
    Job job,
    int mdtCode,
    String mdtDesc,
    Color statusColor,
  ) async {
    if (!mounted) return false;

    BuildContext? dialogContext;

    try {
      // Show loading dialog
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

      // Update job via API
      final result = await jobApi.updateJobWithDateTime(
        jobId: job.no ?? '',
        driverId: driverId,
        mdtCode: mdtCode.toString(),
        jobLastStatusDateTime: now,
        tenantId: tenantId,
      );

      if (!mounted) return false;

      // Close loading dialog immediately
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }

      if (result['result'] == true || result['queued'] == true) {
        // Update the local job object
        if (mounted) {
          setState(() {
            job.mdtCode = mdtCode;
            job.mdtCodef = mdtDesc;
          });
        }

        // Refresh job details after successful update or queuing
        return true;
      } else {
        debugPrint('API returned false result: $result');
        return false;
      }
    } catch (e) {
      if (!mounted) return false;

      // Close loading dialog immediately
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
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
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            'Update Failed',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          content: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Text(
              errorMessage,
              style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.red),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Dismiss',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error showing error dialog: $e');
    }
  }

  /// Safe snackbar display with error handling
  void _safeShowSnackBar(BuildContext context, String message, Color color) {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('Error showing snackbar: $e');
    }
  }
}
