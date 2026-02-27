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
  Future<void> cacheLoginData({
    required String userEmail,
    required String userId,
    required String token,
    required Map<String, dynamic> userInfo,
  }) async {
    try {
      final now = DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      await _prefs.setString(_loginDateKey, dateString);
      await _prefs.setString(_tokenKey, token);
      await _prefs.setString(_userInfoKey, jsonEncode(userInfo));
      await _prefs.setString(
        _loginDataKey,
        jsonEncode({
          'email': userEmail,
          'userId': userId,
          'token': token,
          'loginTime': dateString,
        }),
      );

      debugPrint('Login data cached - User: $userEmail, Time: $dateString');
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

  /// Check if user session is still valid (within 24 hours)
  bool isSessionValid() {
    try {
      final loginDateStr = _prefs.getString(_loginDateKey);
      if (loginDateStr == null || loginDateStr.isEmpty) {
        debugPrint('No cached login date found');
        return false;
      }

      final loginDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(loginDateStr);
      final now = DateTime.now();
      final difference = now.difference(loginDate);

      final isValid = difference < _sessionDuration;
      debugPrint(
        'Session check - Valid: $isValid, Duration: ${difference.inHours}h ${(difference.inMinutes % 60)}m',
      );
      return isValid;
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
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_loginDateKey);
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userInfoKey);
      await _prefs.remove(_loginDataKey);
      await _prefs.remove(_vehicleSelectionKey);
      await _prefs.remove(_ptiStatusKey);
      debugPrint('All cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Check if user is cached and session is valid
  bool isCachedSessionValid() {
    return getCachedLoginData() != null && isSessionValid();
  }
}
