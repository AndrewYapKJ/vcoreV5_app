import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class LoginCacheService {
  static const String _loginDataKey = 'cached_login_data';
  static const String _loginDateKey = 'login_date';
  static const String _userInfoKey = 'user_info';
  static const String _tokenKey = 'auth_token';
  static const String _vehicleSelectionKey = 'selected_vehicle';
  static const String _ptiStatusKey = 'pti_status';
  static const String _rememberedUsernameKey = 'remembered_username';
  static const String _rememberedPasswordKey = 'remembered_password';
  static const String _rememberMeKey = 'remember_me_enabled';
  static const Duration _sessionDuration = Duration(hours: 24);

  static final LoginCacheService _instance = LoginCacheService._internal();

  factory LoginCacheService() => _instance;

  LoginCacheService._internal();

  late SharedPreferences _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('LoginCacheService initialized');
  }

  /// Cache login data
  /// Can accept either new API format or legacy format
  Future<void> cacheLoginData({
    String? userEmail,
    String? userId,
    String? token,
    Map<String, dynamic>? userInfo,
    // New API response fields
    String? driverId,
    String? mobile,
    String? name,
    String? email,
    String? imei,
  }) async {
    try {
      final now = DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      await _prefs.setString(_loginDateKey, dateString);

      // Use provided token or generate default
      final finalToken = token ?? 'auth_token_${mobile ?? userId}';
      await _prefs.setString(_tokenKey, finalToken);

      // Build user info from available data
      final finalUserInfo =
          userInfo ??
          {
            'email': email ?? userEmail,
            'userId': userId ?? mobile,
            'mobile': mobile,
            'driverId': driverId,
            'name': name,
            'imei': imei,
          };

      debugPrint(
        '💾 Caching userInfo with keys: ${finalUserInfo.keys.toList()}',
      );
      if (finalUserInfo.containsKey('TenantId')) {
        debugPrint(
          '✅ TenantId found in cache data: ${finalUserInfo['TenantId']}',
        );
      } else {
        debugPrint('⚠️ TenantId NOT found in cache data!');
      }

      await _prefs.setString(_userInfoKey, jsonEncode(finalUserInfo));
      await _prefs.setString(
        _loginDataKey,
        jsonEncode({
          'email': email ?? userEmail,
          'userId': userId ?? mobile,
          'mobile': mobile,
          'driverId': driverId,
          'token': finalToken,
          'loginTime': dateString,
        }),
      );

      debugPrint(
        'Login data cached - User: ${email ?? userEmail}, Time: $dateString',
      );
    } catch (e) {
      debugPrint('Error caching login data: $e');
    }
  }

  /// Cache selected vehicle data
  Future<void> cacheVehicleSelection({
    required String vehicleId,
    required String vehicleName,
    required String plateNumber,
  }) async {
    try {
      if (!isSessionValid()) {
        debugPrint('Session expired, cannot cache vehicle');
        return;
      }

      await _prefs.setString(
        _vehicleSelectionKey,
        jsonEncode({
          'vehicleId': vehicleId,
          'vehicleName': vehicleName,
          'plateNumber': plateNumber,
          'selectedAt': DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(DateTime.now()),
        }),
      );

      debugPrint(
        'Vehicle selection cached - ID: $vehicleId, Name: $vehicleName',
      );
    } catch (e) {
      debugPrint('Error caching vehicle selection: $e');
    }
  }

  /// Get cached vehicle selection
  Map<String, dynamic>? getCachedVehicleSelection() {
    try {
      if (!isSessionValid()) {
        return null;
      }

      final vehicleStr = _prefs.getString(_vehicleSelectionKey);
      if (vehicleStr != null && vehicleStr.isNotEmpty) {
        return jsonDecode(vehicleStr) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving cached vehicle: $e');
      return null;
    }
  }

  /// Cache PTI completion status
  Future<void> cachePTIStatus({required bool isCompleted}) async {
    try {
      if (!isSessionValid()) {
        debugPrint('Session expired, cannot cache PTI status');
        return;
      }

      await _prefs.setString(
        _ptiStatusKey,
        jsonEncode({
          'isCompleted': isCompleted,
          'completedAt': DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(DateTime.now()),
        }),
      );

      debugPrint('PTI status cached - Completed: $isCompleted');
    } catch (e) {
      debugPrint('Error caching PTI status: $e');
    }
  }

  /// Get cached PTI status
  Map<String, dynamic>? getCachedPTIStatus() {
    try {
      if (!isSessionValid()) {
        return null;
      }

      final ptiStr = _prefs.getString(_ptiStatusKey);
      if (ptiStr != null && ptiStr.isNotEmpty) {
        final data = jsonDecode(ptiStr) as Map<String, dynamic>;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving cached PTI status: $e');
      return null;
    }
  }

  /// Check if user session is still valid (same day only)
  /// Session expires when date changes to next day
  bool isSessionValid() {
    try {
      final loginDateStr = _prefs.getString(_loginDateKey);
      if (loginDateStr == null || loginDateStr.isEmpty) {
        debugPrint('No cached login date found');
        return false;
      }

      final loginDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(loginDateStr);
      final now = DateTime.now();

      // Check if it's the same day (year-month-day)
      final isSameDay =
          loginDate.year == now.year &&
          loginDate.month == now.month &&
          loginDate.day == now.day;

      debugPrint(
        'Session check - Valid: $isSameDay, Login: ${DateFormat('yyyy-MM-dd').format(loginDate)}, Now: ${DateFormat('yyyy-MM-dd').format(now)}',
      );
      return isSameDay;
    } catch (e) {
      debugPrint('Error checking session validity: $e');
      return false;
    }
  }

  /// Get cached login data
  Map<String, dynamic>? getCachedLoginData() {
    try {
      if (!isSessionValid()) {
        debugPrint('Session expired, clearing cache');
        clearCache();
        return null;
      }

      final loginDataStr = _prefs.getString(_loginDataKey);
      if (loginDataStr != null && loginDataStr.isNotEmpty) {
        return jsonDecode(loginDataStr) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving cached login data: $e');
      return null;
    }
  }

  /// Get cached user info
  Map<String, dynamic>? getCachedUserInfo() {
    try {
      if (!isSessionValid()) {
        return null;
      }

      final userInfoStr = _prefs.getString(_userInfoKey);
      if (userInfoStr != null && userInfoStr.isNotEmpty) {
        return jsonDecode(userInfoStr) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving cached user info: $e');
      return null;
    }
  }

  /// Get cached auth token
  String? getCachedToken() {
    try {
      if (!isSessionValid()) {
        return null;
      }
      return _prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error retrieving cached token: $e');
      return null;
    }
  }

  /// Get last login time
  DateTime? getLastLoginTime() {
    try {
      final loginDateStr = _prefs.getString(_loginDateKey);
      if (loginDateStr != null && loginDateStr.isNotEmpty) {
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(loginDateStr);
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving last login time: $e');
      return null;
    }
  }

  /// Check if session expired (for auto logout)
  bool shouldAutoLogout() {
    if (!isSessionValid()) {
      debugPrint('Auto logout triggered - Session expired');
      return true;
    }
    return false;
  }

  /// Clear all cached login data
  /// Preserves remembered username and password if remember me was enabled
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_loginDateKey);
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userInfoKey);
      await _prefs.remove(_loginDataKey);
      await _prefs.remove(_vehicleSelectionKey);
      await _prefs.remove(_ptiStatusKey);

      // Also clear PTI completion caches (resets when logging out)
      await clearPTICaches();

      // NOTE: _rememberedUsernameKey, _rememberedPasswordKey, and _rememberMeKey are NOT removed
      // They persist across logout to support "Remember Me" functionality
      debugPrint('Cache cleared (remembered credentials preserved)');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Check if user is cached and session is valid
  bool isCachedSessionValid() {
    return getCachedLoginData() != null && isSessionValid();
  }

  /// Get cached driver ID
  String? getCachedDriverId() {
    try {
      if (!isSessionValid()) {
        return null;
      }

      final userInfo = getCachedUserInfo();
      if (userInfo != null) {
        // Check both uppercase and lowercase keys for compatibility
        if (userInfo.containsKey('DriverID')) {
          return userInfo['DriverID'] as String?;
        }
        if (userInfo.containsKey('driverId')) {
          return userInfo['driverId'] as String?;
        }
      }

      final loginData = getCachedLoginData();
      if (loginData != null) {
        if (loginData.containsKey('DriverID')) {
          return loginData['DriverID'] as String?;
        }
        if (loginData.containsKey('driverId')) {
          return loginData['driverId'] as String?;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error retrieving cached driver ID: $e');
      return null;
    }
  }

  /// Get cached tenant ID
  String? getCachedTenantId() {
    try {
      if (!isSessionValid()) {
        debugPrint('⚠️ Session invalid, returning null for tenant ID');
        return null;
      }

      final userInfo = getCachedUserInfo();
      if (userInfo != null) {
        debugPrint('📦 UserInfo keys: ${userInfo.keys.toList()}');
        // Check both uppercase and lowercase keys for compatibility
        if (userInfo.containsKey('TenantId')) {
          final tenantId = userInfo['TenantId'] as String?;
          debugPrint('✅ Found TenantId in userInfo: $tenantId');
          return tenantId;
        }
        if (userInfo.containsKey('tenantId')) {
          final tenantId = userInfo['tenantId'] as String?;
          debugPrint('✅ Found tenantId in userInfo: $tenantId');
          return tenantId;
        }
      }

      final loginData = getCachedLoginData();
      if (loginData != null) {
        debugPrint('📦 LoginData keys: ${loginData.keys.toList()}');
        if (loginData.containsKey('TenantId')) {
          final tenantId = loginData['TenantId'] as String?;
          debugPrint('✅ Found TenantId in loginData: $tenantId');
          return tenantId;
        }
        if (loginData.containsKey('tenantId')) {
          final tenantId = loginData['tenantId'] as String?;
          debugPrint('✅ Found tenantId in loginData: $tenantId');
          return tenantId;
        }
      }

      // Default tenant ID if not found
      debugPrint('⚠️ TenantId not found in cache, defaulting to "1"');
      return '1';
    } catch (e) {
      debugPrint('❌ Error retrieving cached tenant ID: $e');
      return '1';
    }
  }

  /// Get cached vehicle ID (from selected vehicle)
  String? getCachedVehicleId() {
    try {
      if (!isSessionValid()) {
        return null;
      }

      final vehicleData = getCachedVehicleSelection();
      if (vehicleData != null && vehicleData.containsKey('vehicleId')) {
        return vehicleData['vehicleId']?.toString();
      }

      return null;
    } catch (e) {
      debugPrint('Error retrieving cached vehicle ID: $e');
      return null;
    }
  }

  // ========== Remember Me Functionality ==========

  /// Save username and password when "Remember Me" is checked
  Future<void> saveRememberedCredentials({
    required String username,
    required String password,
  }) async {
    try {
      await _prefs.setString(_rememberedUsernameKey, username);
      await _prefs.setString(_rememberedPasswordKey, password);
      await _prefs.setBool(_rememberMeKey, true);
      debugPrint('Remembered credentials saved for: $username');
    } catch (e) {
      debugPrint('Error saving remembered credentials: $e');
    }
  }

  /// Get remembered username
  String? getRememberedUsername() {
    try {
      if (isRememberMeEnabled()) {
        return _prefs.getString(_rememberedUsernameKey);
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving remembered username: $e');
      return null;
    }
  }

  /// Get remembered password
  String? getRememberedPassword() {
    try {
      if (isRememberMeEnabled()) {
        return _prefs.getString(_rememberedPasswordKey);
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving remembered password: $e');
      return null;
    }
  }

  /// Check if remember me is enabled
  bool isRememberMeEnabled() {
    try {
      return _prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      debugPrint('Error checking remember me status: $e');
      return false;
    }
  }

  /// Clear remembered credentials (when user unchecks "Remember Me")
  Future<void> clearRememberedCredentials() async {
    try {
      await _prefs.remove(_rememberedUsernameKey);
      await _prefs.remove(_rememberedPasswordKey);
      await _prefs.remove(_rememberMeKey);
      debugPrint('Remembered credentials cleared');
    } catch (e) {
      debugPrint('Error clearing remembered credentials: $e');
    }
  }

  // ============================================================================
  // VEHICLE CACHING - DATE-BASED FOR "ASSIGNED VEHICLE OF THE DAY"
  // ============================================================================

  static const String _assignedVehicleKey = 'assigned_vehicle_today_';

  /// Cache assigned vehicle for today (with date validation)
  /// Can be used for "assigned vehicle of the day" feature
  Future<void> cacheAssignedVehicleForToday({
    required String vehicleId,
    required String vehicleName,
    required String plateNumber,
  }) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final key = '$_assignedVehicleKey$today';

      await _prefs.setString(
        key,
        jsonEncode({
          'vehicleId': vehicleId,
          'vehicleName': vehicleName,
          'plateNumber': plateNumber,
          'cachedDate': today,
          'cachedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        }),
      );

      debugPrint(
        '✅ Cached assigned vehicle for today: $vehicleName ($plateNumber)',
      );
    } catch (e) {
      debugPrint('Error caching assigned vehicle for today: $e');
    }
  }

  /// Get assigned vehicle for today (returns null if no vehicle or cache expired)
  /// Automatically validates that cached vehicle is from today
  Future<Map<String, dynamic>?> getTodayAssignedVehicle() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final key = '$_assignedVehicleKey$today';

      final vehicleStr = _prefs.getString(key);
      if (vehicleStr != null && vehicleStr.isNotEmpty) {
        final vehicleData = jsonDecode(vehicleStr) as Map<String, dynamic>;

        // Verify the cached vehicle is from today
        final cachedDate = vehicleData['cachedDate'] as String?;
        if (cachedDate == today) {
          debugPrint(
            '✅ Using cached assigned vehicle for today: ${vehicleData['vehicleName']}',
          );
          return vehicleData;
        } else {
          // Cache is from a different day, expired
          debugPrint(
            '⏰ Assigned vehicle cache expired (cached on $cachedDate, need $today)',
          );
          await _prefs.remove(key);
          return null;
        }
      }

      debugPrint('No assigned vehicle cached for today');
      return null;
    } catch (e) {
      debugPrint('Error retrieving today\'s assigned vehicle: $e');
      return null;
    }
  }

  /// Get last used vehicle (without date restriction)
  /// Useful fallback when no assigned vehicle for today
  Map<String, dynamic>? getLastUsedVehicle() {
    try {
      // Return normal vehicle selection (not date-restricted)
      return getCachedVehicleSelection();
    } catch (e) {
      debugPrint('Error retrieving last used vehicle: $e');
      return null;
    }
  }

  /// Get vehicle for offline mode - prefers assigned vehicle, falls back to last used
  /// This is the main method to call during offline mode
  Future<Map<String, dynamic>?> getVehicleForOfflineMode() async {
    try {
      // First, try to get today's assigned vehicle
      final assignedVehicle = await getTodayAssignedVehicle();
      if (assignedVehicle != null) {
        debugPrint('📱 Using assigned vehicle for offline mode');
        return assignedVehicle;
      }

      // Fallback: get last used vehicle
      final lastUsed = getLastUsedVehicle();
      if (lastUsed != null) {
        debugPrint('📱 Using last used vehicle for offline mode');
        return lastUsed;
      }

      debugPrint('⚠️ No vehicle available for offline mode');
      return null;
    } catch (e) {
      debugPrint('Error getting vehicle for offline mode: $e');
      return null;
    }
  }

  /// Clear expired vehicle caches (call during cleanup/logout)
  Future<void> clearExpiredVehicleCaches() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Get all SharedPreferences keys
      final allKeys = _prefs.getKeys();
      int cleared = 0;

      for (final key in allKeys) {
        if (key.startsWith(_assignedVehicleKey) &&
            key != '$_assignedVehicleKey$today') {
          await _prefs.remove(key);
          cleared++;
        }
      }

      if (cleared > 0) {
        debugPrint('🧹 Cleared $cleared expired vehicle caches');
      }
    } catch (e) {
      debugPrint('Error clearing expired vehicle caches: $e');
    }
  }

  // ============================================================================
  // PTI STATUS CACHING - DATE-BASED FOR "COMPLETED TODAY"
  // ============================================================================

  static const String _ptiCompletedKey = 'pti_completed_today_';

  /// Cache PTI completion status for today
  /// Call this after user completes PTI inspection
  Future<void> cachePTICompletedForToday({
    required String vehicleId,
    required String inspectionData,
  }) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final key = '$_ptiCompletedKey$today';

      await _prefs.setString(
        key,
        jsonEncode({
          'vehicleId': vehicleId,
          'inspectionData': inspectionData,
          'completedDate': today,
          'completedAt': DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(DateTime.now()),
        }),
      );

      debugPrint('✅ Cached PTI completion for today (Vehicle: $vehicleId)');
    } catch (e) {
      debugPrint('Error caching PTI completion: $e');
    }
  }

  /// Check if PTI is already completed for today
  /// Returns true only if PTI was completed today, false if expired or not done
  /// Use this before loading PTI items when offline
  Future<bool> isPTICompletedForToday({required String vehicleId}) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final key = '$_ptiCompletedKey$today';

      final ptiDataStr = _prefs.getString(key);
      if (ptiDataStr != null && ptiDataStr.isNotEmpty) {
        final ptiData = jsonDecode(ptiDataStr) as Map<String, dynamic>;

        // Verify the cached PTI is from today and for this vehicle
        final completedDate = ptiData['completedDate'] as String?;
        final cachedVehicleId = ptiData['vehicleId'] as String?;

        if (completedDate == today && cachedVehicleId == vehicleId) {
          debugPrint('✅ PTI already completed for today (Vehicle: $vehicleId)');
          return true;
        } else if (completedDate != today) {
          // Expired from previous day
          debugPrint(
            '⏰ PTI completion expired (completed on $completedDate, need $today)',
          );
          await _prefs.remove(key);
          return false;
        } else {
          // Different vehicle
          debugPrint(
            '⚠️ PTI cached for different vehicle (cached: $cachedVehicleId, current: $vehicleId)',
          );
          return false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking PTI completion: $e');
      return false;
    }
  }

  /// Get cached PTI completion data for today
  /// Returns null if not completed or cache expired
  Map<String, dynamic>? getPTICompletedData({required String vehicleId}) {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final key = '$_ptiCompletedKey$today';

      final ptiDataStr = _prefs.getString(key);
      if (ptiDataStr != null && ptiDataStr.isNotEmpty) {
        final ptiData = jsonDecode(ptiDataStr) as Map<String, dynamic>;
        final completedDate = ptiData['completedDate'] as String?;
        final cachedVehicleId = ptiData['vehicleId'] as String?;

        if (completedDate == today && cachedVehicleId == vehicleId) {
          debugPrint('✅ Retrieved cached PTI data for today');
          return ptiData;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error retrieving PTI data: $e');
      return null;
    }
  }

  /// Clear all PTI caches (called on logout)
  /// This is important to reset when user logs out and logs back in next day
  Future<void> clearPTICaches() async {
    try {
      final allKeys = _prefs.getKeys();

      for (final key in allKeys) {
        if (key.startsWith(_ptiCompletedKey)) {
          await _prefs.remove(key);
        }
      }

      debugPrint('🧹 Cleared all PTI completion caches');
    } catch (e) {
      debugPrint('Error clearing PTI caches: $e');
    }
  }
}
