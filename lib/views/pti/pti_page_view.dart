import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:vcore_v5_app/constant/font_styling.dart';
import 'package:vcore_v5_app/services/storage/login_cache_service.dart';
import 'package:vcore_v5_app/services/pti_service.dart';
import 'package:vcore_v5_app/models/pti_check_item_model.dart';

class PTIPageView extends StatefulWidget {
  final Map<String, dynamic>? vehicleData;

  const PTIPageView({super.key, this.vehicleData});

  @override
  State<PTIPageView> createState() => _PTIPageViewState();
}

class _PTIPageViewState extends State<PTIPageView> {
  late PageController _pageController;
  int _currentPage = 0;
  Map<String, dynamic>? _currentVehicle;
  late Future<PTICheckResponse> _ptiItemsFuture;
  final PTIService _ptiService = PTIService();
  late List<String> _categories;
  late Map<String, String>
  _selectedValues; // Maps "Category|SubCategory" to selected value
  bool _hasShownSkipDialog = false;
  bool _userChoseToRedoPTI = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentVehicle =
        widget.vehicleData ?? LoginCacheService().getCachedVehicleSelection();
    _ptiItemsFuture = _initializePTIItems();
    _categories = [];
    _selectedValues = {};
  }

  String _resolveVehicleId() {
    final extraVehicleId = _currentVehicle?['vehicleId']?.toString();
    if (extraVehicleId != null && extraVehicleId.isNotEmpty) {
      return extraVehicleId;
    }

    final cachedVehicleId = LoginCacheService().getCachedVehicleId();
    if (cachedVehicleId != null && cachedVehicleId.isNotEmpty) {
      return cachedVehicleId;
    }

    return '';
  }

  Future<PTICheckResponse> _initializePTIItems() async {
    final vehicleId = _resolveVehicleId();
    final driverId = LoginCacheService().getCachedDriverId() ?? '';

    if (vehicleId.isEmpty) {
      throw Exception('Vehicle ID not found. Please select a vehicle again.');
    }

    return _ptiService.getPTICheckItemsByCategoryWithStatus(
      vehicleId: vehicleId,
      driverId: driverId,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() async {
    if (_currentPage < _categories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Submit PTI data
      await _submitPTIData();
    }
  }

  Future<void> _submitPTIData() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text('Submitting PTI data...'),
                ],
              ),
            ),
          ),
        ),
      );

      final vehicleId = _resolveVehicleId();
      final driverId = LoginCacheService().getCachedDriverId() ?? '';

      if (vehicleId.isEmpty) {
        throw Exception('Vehicle ID not found. Please select a vehicle again.');
      }

      final ptiResponse = await _ptiItemsFuture;

      final success = await _ptiService.savePTIData(
        vehicleId: vehicleId,
        driverId: driverId,
        selectedValues: _selectedValues,
        categoryItems: ptiResponse.items,
      );

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        if (success) {
          // Show completion dialog
          _showCompletionDialog();
        } else {
          // Show error dialog
          _showErrorDialog('Failed to submit PTI data');
        }
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);
        // Show error dialog
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8.w),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success checkmark
                  Container(
                    width: 80.h,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.withValues(alpha: 0.2),
                          Colors.green.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 40.h,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    'PTI Completed!',
                    style: context.font
                        .bold(context)
                        .copyWith(
                          fontSize: 20.sp,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 8.h),

                  // Description
                  Text(
                    'All checks have been verified.\nYou are ready to start your day.',
                    textAlign: TextAlign.center,
                    style: context.font
                        .regular(context)
                        .copyWith(
                          fontSize: 14.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),
                  SizedBox(height: 32.h),

                  // Skip button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Cache the current vehicle and mark PTI as completed
                        if (_currentVehicle != null) {
                          await LoginCacheService().cacheVehicleSelection(
                            vehicleId: _currentVehicle!['vehicleId'],
                            vehicleName: _currentVehicle!['vehicleName'],
                            plateNumber: _currentVehicle!['plateNumber'],
                          );
                        }

                        // Mark PTI as completed
                        await LoginCacheService().cachePTIStatus(
                          isCompleted: true,
                        );

                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          // ignore: use_build_context_synchronously
                          context.go('/jobs');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: context.font
                            .semibold(context)
                            .copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Redo button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _currentPage = 0;
                        _pageController.jumpToPage(0);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Re-do PTI',
                        style: context.font
                            .semibold(context)
                            .copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.primary,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSkipOrRedoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Info icon
                  Container(
                    width: 80.h,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.withValues(alpha: 0.2),
                          Colors.blue.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 40.h,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    'PTI Already Completed',
                    style: context.font
                        .bold(context)
                        .copyWith(
                          fontSize: 20.sp,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  SizedBox(height: 8.h),

                  // Description
                  Text(
                    'You have already completed PTI for today.\nWould you like to skip or redo it?',
                    textAlign: TextAlign.center,
                    style: context.font
                        .regular(context)
                        .copyWith(
                          fontSize: 14.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),
                  SizedBox(height: 32.h),

                  // Skip button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (mounted) {
                          Navigator.pop(context);
                          // ignore: use_build_context_synchronously
                          context.go('/jobs');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: context.font
                            .semibold(context)
                            .copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Redo button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _userChoseToRedoPTI = true;
                        });
                        Navigator.pop(context);
                        // Close the dialog and allow user to redo PTI
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Redo PTI',
                        style: context.font
                            .semibold(context)
                            .copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.primary,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'pti_checklist'.tr(),
          style: context.font
              .semibold(context)
              .copyWith(fontSize: 18.sp, color: colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<PTICheckResponse>(
          future: _ptiItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading PTI items...',
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

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(28.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withValues(alpha: 0.1),
                            Colors.red.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Failed to load PTI items',
                      style: context.font
                          .semibold(context)
                          .copyWith(
                            fontSize: 14.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: context.font
                          .regular(context)
                          .copyWith(
                            fontSize: 12.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _ptiItemsFuture = _initializePTIItems();
                        });
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Get the response data
            final ptiResponse = snapshot.data;
            final isDoneForDay = ptiResponse?.isDoneForDay ?? false;
            final categoryItems = ptiResponse?.items ?? {};
            _categories = categoryItems.keys.toList();

            // If PTI is already done for the day, show skip dialog
            if (isDoneForDay && !_hasShownSkipDialog && !_userChoseToRedoPTI) {
              _hasShownSkipDialog = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _showSkipOrRedoDialog();
                }
              });
            }

            // Initialize selected values if not already done
            if (_selectedValues.isEmpty && categoryItems.isNotEmpty) {
              for (final category in _categories) {
                for (final item in categoryItems[category] ?? []) {
                  _selectedValues['${item.category}|${item.subCategory}'] =
                      'Poor';
                }
              }
            }

            return Column(
              children: [
                // Progress indicator
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step ${_currentPage + 1} of ${_categories.length}',
                            style: context.font
                                .regular(context)
                                .copyWith(
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                          ),
                          Text(
                            '${((_currentPage + 1) / _categories.length * 100).toStringAsFixed(0)}%',
                            style: context.font
                                .bold(context)
                                .copyWith(
                                  fontSize: 13.sp,
                                  color: colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (_currentPage + 1) / _categories.length,
                          minHeight: 6.h,
                          backgroundColor: colorScheme.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final items = categoryItems[category] ?? [];
                      return _buildCategoryPage(
                        context,
                        colorScheme,
                        category,
                        items,
                      );
                    },
                  ),
                ),

                // Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 42.h,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _categories.length - 1
                            ? 'Complete'
                            : 'Next',
                        style: context.font
                            .bold(context)
                            .copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.onPrimary,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryPage(
    BuildContext context,
    ColorScheme colorScheme,
    String category,
    List<PTICheckItem> items,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          Text(
            category,
            style: context.font
                .bold(context)
                .copyWith(fontSize: 16.sp, color: colorScheme.onSurface),
          ),

          Text(
            'Select condition for each item',
            style: context.font
                .regular(context)
                .copyWith(
                  fontSize: 10.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          SizedBox(height: 12.h),

          // Items list
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final key = '${item.category}|${item.subCategory}';
            final selectedValue = _selectedValues[key] ?? 'Poor';
            final options = item.type == 1
                ? ['Poor', 'Average', 'Good']
                : ['Poor', 'Good'];

            IconData getOptionIcon(String option) {
              switch (option) {
                case 'Good':
                  return Icons.check_circle;
                case 'Average':
                  return Icons.radio_button_checked;
                case 'Poor':
                  return Icons.cancel;
                default:
                  return Icons.help_outline;
              }
            }

            Color getOptionColor(String option) {
              switch (option) {
                case 'Good':
                  return Colors.green;
                case 'Average':
                  return Colors.orange;
                case 'Poor':
                  return Colors.red;
                default:
                  return colorScheme.outline;
              }
            }

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.surface,
                              colorScheme.surfaceContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.12,
                                ),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 8.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Item header with index
                                  Row(
                                    children: [
                                      Container(
                                        width: 28.w,
                                        height: 28.w,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              colorScheme.primary,
                                              colorScheme.primary.withValues(
                                                alpha: 0.8,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: context.font
                                                .bold(context)
                                                .copyWith(
                                                  fontSize: 11.sp,
                                                  color: colorScheme.onPrimary,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.subCategory,
                                              style: context.font
                                                  .bold(context)
                                                  .copyWith(
                                                    fontSize: 12.sp,
                                                    color:
                                                        colorScheme.onSurface,
                                                    height: 1.2,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.checklist_rounded,
                                                  size: 12.sp,
                                                  color: colorScheme.primary
                                                      .withValues(alpha: 0.6),
                                                ),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  'Type ${item.type}',
                                                  style: context.font
                                                      .bold(context)
                                                      .copyWith(
                                                        fontSize: 9.sp,
                                                        color:
                                                            colorScheme.primary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),

                                  // Selection buttons
                                  Container(
                                    padding: EdgeInsets.all(6.h),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: options.asMap().entries.map((
                                        entry,
                                      ) {
                                        final option = entry.value;
                                        final isSelected =
                                            selectedValue == option;
                                        final buttonColor = getOptionColor(
                                          option,
                                        );
                                        final buttonIcon = getOptionIcon(
                                          option,
                                        );

                                        return Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 3.w,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedValues[key] = option;
                                                });
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                curve: Curves.easeInOut,
                                                decoration: BoxDecoration(
                                                  gradient: isSelected
                                                      ? LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            buttonColor,
                                                            buttonColor
                                                                .withValues(
                                                                  alpha: 0.85,
                                                                ),
                                                          ],
                                                        )
                                                      : LinearGradient(
                                                          colors: [
                                                            colorScheme.surface,
                                                            colorScheme.surface,
                                                          ],
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.transparent
                                                        : colorScheme.outline
                                                              .withValues(
                                                                alpha: 0.15,
                                                              ),
                                                    width: 1,
                                                  ),
                                                  boxShadow: isSelected
                                                      ? [
                                                          BoxShadow(
                                                            color: buttonColor
                                                                .withValues(
                                                                  alpha: 0.4,
                                                                ),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  2,
                                                                ),
                                                          ),
                                                        ]
                                                      : [],
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 6.h,
                                                    horizontal: 4.w,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        buttonIcon,
                                                        size: 13.sp,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : colorScheme
                                                                  .onSurface
                                                                  .withValues(
                                                                    alpha: 0.3,
                                                                  ),
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Text(
                                                        option,
                                                        style: context.font
                                                            .bold(context)
                                                            .copyWith(
                                                              fontSize: 10.sp,
                                                              color: isSelected
                                                                  ? Colors.white
                                                                  : colorScheme
                                                                        .onSurface
                                                                        .withValues(
                                                                          alpha:
                                                                              0.5,
                                                                        ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
