import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../services/update_service.dart';
import '../../widgets/update_dialog.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final UpdateService _updateService = UpdateService();
  bool _isCheckingUpdates = false;
  String _appVersion = '';
  int _buildNumber = 0;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
    _initializeApp();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
      });
    } catch (e) {
      print('Error loading version info: $e');
      setState(() {
        _appVersion = '1.0.0';
        _buildNumber = 1;
      });
    }
  }

  Future<void> _initializeApp() async {
    // Wait a bit for splash animation
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Check for updates
    await _checkForUpdates();

    // Navigate to login if still mounted
    if (mounted) {
      context.go('/login');
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
      print('Error checking for updates: $e');
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.tertiary,
                          colorScheme.tertiary.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.tertiary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.g_mobiledata,
                      size: 50,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App title
                  Text(
                    'app_title'.tr(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  // Loading indicator section
                  const SizedBox(height: 48),
                  if (_isCheckingUpdates)
                    Column(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                            strokeWidth: 2,
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
                      ],
                    ),
                ],
              ),
            ),
            // Version info at bottom
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Text(
                    'v$_appVersion ($_buildNumber)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© ${DateTime.now().year} Gussmann Integrated Solution',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
