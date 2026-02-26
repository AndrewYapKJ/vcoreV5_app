import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

enum UpdateType {
  none,
  forceUpdate, // Remote config - different version, redirect to store
  patchAvailable, // Shorebird patch available
}

class UpdateCheckResult {
  final UpdateType type;
  final String? currentVersion;
  final String? remoteVersion;
  final String? storeBuildNumber;

  UpdateCheckResult({
    required this.type,
    this.currentVersion,
    this.remoteVersion,
    this.storeBuildNumber,
  });
}

class UpdateService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final ShorebirdUpdater _shorebirdUpdater = ShorebirdUpdater();

  /// Check for updates in the correct order:
  /// 1. Remote Config (force update to store if version mismatch)
  /// 2. Shorebird patch (if no force update needed)
  Future<UpdateCheckResult> checkForUpdates() async {
    // First, check remote config for force updates
    final remoteConfigResult = await _checkRemoteConfig();
    if (remoteConfigResult.type == UpdateType.forceUpdate) {
      return remoteConfigResult;
    }

    // If no force update, check for Shorebird patches
    final patchResult = await _checkShorebirdPatch();
    return patchResult;
  }

  /// Check Firebase Remote Config for version mismatch (force update)
  Future<UpdateCheckResult> _checkRemoteConfig() async {
    try {
      // Fetch and activate remote config
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g., "1.0.0"
      final currentBuildNumber = packageInfo.buildNumber; // e.g., "1"

      // Get remote version from config
      // Expected keys: "android_version", "android_build_number", "ios_version", "ios_build_number"
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final remoteVersion = _remoteConfig.getString('${platform}_version');
      final remoteBuildNumber = _remoteConfig.getString(
        '${platform}_build_number',
      );

      // Check if version or build number is different
      if (remoteVersion.isNotEmpty && remoteBuildNumber.isNotEmpty) {
        if (currentVersion != remoteVersion ||
            currentBuildNumber != remoteBuildNumber) {
          return UpdateCheckResult(
            type: UpdateType.forceUpdate,
            currentVersion: currentVersion,
            remoteVersion: remoteVersion,
            storeBuildNumber: remoteBuildNumber,
          );
        }
      }
    } catch (e) {
      // Remote config check failed, continue to patch check
      print('Remote config check failed: $e');
    }

    return UpdateCheckResult(type: UpdateType.none);
  }

  /// Check for Shorebird patch availability
  Future<UpdateCheckResult> _checkShorebirdPatch() async {
    try {
      // Check if Shorebird is available
      if (!_shorebirdUpdater.isAvailable) {
        return UpdateCheckResult(type: UpdateType.none);
      }

      // Check for available patch
      final status = await _shorebirdUpdater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        return UpdateCheckResult(type: UpdateType.patchAvailable);
      }
    } catch (e) {
      print('Shorebird patch check failed: $e');
    }

    return UpdateCheckResult(type: UpdateType.none);
  }

  /// Download and apply Shorebird patch
  Future<bool> downloadAndApplyPatch() async {
    try {
      // Download the patch
      await _shorebirdUpdater.update();
      return true;
    } catch (e) {
      print('Failed to download patch: $e');
      return false;
    }
  }

  /// Get the appropriate store URL for the current platform
  String getStoreUrl() {
    if (Platform.isAndroid) {
      // TODO: Replace with your actual package name
      final packageName = 'com.gis.vcorev5';
      return 'https://play.google.com/store/apps/details?id=$packageName';
    } else if (Platform.isIOS) {
      // TODO: Replace with your actual App Store ID
      final appId = 'YOUR_APP_ID';
      return 'https://apps.apple.com/app/id$appId';
    }
    return '';
  }
}
