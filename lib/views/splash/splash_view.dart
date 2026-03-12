import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vcore_v5_app/core/font_styling.dart';
import 'package:vcore_v5_app/models/login_response_model.dart';
import '../../services/update_service.dart';
import '../../services/storage/login_cache_service.dart';
import '../../providers/user_provider.dart';
import '../../providers/jobs_provider.dart';
import '../../widgets/update_dialog.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView>
    with SingleTickerProviderStateMixin {
  final UpdateService _updateService = UpdateService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isCheckingUpdates = false;
  String _appVersion = '';
  int _buildNumber = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadVersionInfo();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
      });
    } catch (e) {
      debugPrint('Error loading version info: $e');
      setState(() {
        _appVersion = '1.0.0';
        _buildNumber = 1;
      });
    }
  }

  Future<void> _initializeApp() async {
    // Initialize LoginCacheService
    final loginCacheService = LoginCacheService();
    await loginCacheService.initialize();

    // Wait a bit for splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check for updates
    await _checkForUpdates();

    // Check if user has valid cached session
    if (mounted) {
      if (loginCacheService.isCachedSessionValid()) {
        // Get tenant ID from cache first
        final tenantId = loginCacheService.getCachedTenantId();

        if (tenantId == null) {
          debugPrint('⚠️ Tenant ID not found in cache, going to login');
          context.go('/login');
          return;
        }
        ref
            .read(userDataProvider.notifier)
            .state = loginCacheService.getCachedUserInfo() != null
            ? LoginResponse.fromJson(loginCacheService.getCachedUserInfo()!)
            : null;
        // Initialize user provider so it's ready for the app
        //    ref.read(userDataProvider);

        // Validate session with MDT Functions API
        final isValidSession = await _validateSessionWithMDTApi(tenantId);

        if (mounted) {
          if (isValidSession) {
            debugPrint('✅ Session valid, proceeding to safety question');
            context.go('/safety-question');
          } else {
            // Session invalid on server, clear cache and go to login
            await loginCacheService.clearCache();
            context.go('/login');
          }
        }
      } else {
        // No valid session, go to login
        context.go('/login');
      }
    }
  }

  /// Validate session by using MDT Functions provider
  /// This ensures the data is cached in Riverpod and can be reused
  Future<bool> _validateSessionWithMDTApi(String tenantId) async {
    try {
      // Invalidate to force a fresh fetch
      ref.invalidate(mdtFunctionsProvider);

      // Use the Riverpod provider to fetch MDT functions
      // This will cache the data for use throughout the app
      final mdtResponse = await ref.read(mdtFunctionsProvider.future);

      // If API call succeeds and returns functions, session is valid
      if (mdtResponse.isSuccess && mdtResponse.functions.isNotEmpty) {
        debugPrint(
          '✅ Session validated, ${mdtResponse.functions.length} MDT functions available',
        );
        return true;
      }

      debugPrint('⚠️ MDT Functions API returned no data');
      return false;
    } catch (e) {
      debugPrint('❌ Session validation failed: $e');
      return false;
    }
  }

  Future<void> _checkForUpdates() async {
    if (_isCheckingUpdates) return;

    setState(() {
      _isCheckingUpdates = true;
    });

    try {
      final result = await _updateService.checkForUpdates();

      if (!mounted) return;

      switch (result.type) {
        case UpdateType.forceUpdate:
          // Force update required - redirect to store
          await UpdateDialogs.showForceUpdateDialog(
            context,
            currentVersion: result.currentVersion ?? 'Unknown',
            newVersion: result.remoteVersion ?? 'Unknown',
            storeUrl: _updateService.getStoreUrl(),
          );
          break;

        case UpdateType.patchAvailable:
          // Shorebird patch available
          await _handlePatchUpdate();
          break;

        case UpdateType.none:
          // No updates needed
          break;
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      // Continue to app even if update check fails
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdates = false;
        });
      }
    }
  }

  Future<void> _handlePatchUpdate() async {
    // Show patch update dialog
    final shouldUpdate = await UpdateDialogs.showPatchUpdateDialog(context);

    if (!shouldUpdate || !mounted) return;

    // Show downloading dialog
    UpdateDialogs.showDownloadingDialog(context);

    try {
      // Download and apply patch
      final success = await _updateService.downloadAndApplyPatch();

      if (!mounted) return;

      // Close downloading dialog
      Navigator.of(context).pop();

      if (success) {
        // Show restart instructions
        await UpdateDialogs.showPatchCompleteDialog(context);
      } else {
        // Show error
        await UpdateDialogs.showErrorDialog(
          context,
          'update_download_failed'.tr(),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Close downloading dialog
      Navigator.of(context).pop();

      // Show error
      await UpdateDialogs.showErrorDialog(
        context,
        'update_download_failed'.tr(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Icon with glow effect
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow background
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  colorScheme.primary.withValues(alpha: 0.15),
                                  colorScheme.primary.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                          // Logo
                          Image.asset(
                            'assets/images/ic_launcher_w_Bg.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                      // App title
                      Text(
                        'app_title'.tr(),
                        style: context.font
                            .bold(context)
                            .copyWith(
                              fontSize: 32.sp,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      // Subtitle
                      Text(
                        'Welcome',
                        style: context.font
                            .regular(context)
                            .copyWith(
                              fontSize: 14.sp,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              letterSpacing: 0.5,
                            ),
                      ),
                      // Loading indicator section
                      SizedBox(height: 48.h),
                      if (_isCheckingUpdates)
                        Column(
                          children: [
                            // Custom loading indicator
                            SizedBox(
                              width: 50.h,
                              height: 50.h,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer rotating ring
                                  Transform.rotate(
                                    angle: _animationController.value * 4,
                                    child: Container(
                                      width: 50.h,
                                      height: 50.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Inner rotating dot
                                  Transform.rotate(
                                    angle: -_animationController.value * 6,
                                    child: CustomPaint(
                                      size: Size(50.h, 50.h),
                                      painter: _RotatingDotPainter(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  // Center indicator
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                    strokeWidth: 2.5,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Checking for updates...',
                              style: context.font
                                  .regular(context)
                                  .copyWith(
                                    fontSize: 12.sp,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                            ),
                          ],
                        )
                      else
                        // Version info at bottom
                        Padding(
                          padding: EdgeInsets.only(top: 24.h),
                          child: Text(
                            'v$_appVersion (Build $_buildNumber)',
                            style: context.font
                                .regular(context)
                                .copyWith(
                                  fontSize: 11.sp,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'checking_updates'.tr(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).viewPadding.bottom,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  // Text(
                  //   '© ${DateTime.now().year} Gussmann Integrated Solution',
                  //   style: TextStyle(
                  //     fontSize: 11,
                  //     fontWeight: FontWeight.w400,
                  //     color: colorScheme.onSurface.withValues(alpha: 0.3),
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Powered By",
                        style: context.font
                            .medium(context)
                            .copyWith(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                      ),
                      Image.asset(
                        "assets/images/ic_launcher_w_Bg.png",
                        width: 25,
                        height: 25,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        "Gussmann Integrated Solution",
                        style: context.font
                            .medium(context)
                            .copyWith(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
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
    );

    // Version info at bottom
  }
}

class _RotatingDotPainter extends CustomPainter {
  final Color color;

  _RotatingDotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final radius = size.width / 2;
    const dotRadius = 4.0;

    // Draw dot at top
    canvas.drawCircle(Offset(radius, dotRadius), dotRadius, paint);
  }

  @override
  bool shouldRepaint(_RotatingDotPainter oldDelegate) => true;
}
