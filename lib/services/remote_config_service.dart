import 'package:flutter/foundation.dart';

/// Remote Config Service - Currently disabled
/// Firebase Remote Config and AGConnect Remote Config have been removed
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() {
    return _instance;
  }

  RemoteConfigService._internal();

  /// Initialize - No-op since remote config is disabled
  Future<void> initialize() async {
    debugPrint('[RemoteConfig] Remote config service disabled');
  }

  /// Fetch and activate - No-op
  Future<bool> fetchAndActivate() async {
    return true;
  }

  /// Get string value - Returns default value
  String getString(String key, {String defaultValue = ''}) {
    return defaultValue;
  }
}
