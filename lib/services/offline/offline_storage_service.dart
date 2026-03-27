// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:vcore_v5_app/models/login_response_model.dart';
import 'package:vcore_v5_app/models/vehicle_model.dart';

class OfflineStorageService {
  static const String _vehiclePtiBoxName = 'vehicle_pti_box';
  static Box<String>? _vehiclePtiBox;
  static const String _cacheBoxName = 'api_cache';
  static const String _offlineQueueBoxName = 'offline_queue';
  static const String _userDataBoxName = 'user_data';
  static const String _appDataBoxName = 'app_data';

  static Box<String>? _cacheBox;
  static Box<Map>? _offlineQueueBox;
  static Box<String>? _userDataBox;
  static Box<String>? _appDataBox;

  static const String ACCESS_TOKEN_KEY = "access_token";
  static const String LANGUAGE_CODE_KEY = "language_code";
  static const String LOGIN_DATA_KEY = "login_data";
  static const String SAVED_LOGIN_KEY = "saved_login";
  static const String SAVED_PASSWORD_KEY = "saved_password";
  static const String VEHICLE_DATA_KEY = "vehicle_data";
  static const String LOGIN_DATE_KEY = "login_date";
  static const String APP_CONFIG_BACKUP_KEY = "app_config_backup";
  static const String USER_IC_KEY = "user_ic";
  static const String CURRENT_VEHICLE_PTI_KEY = "current_vehicle_pti";
  static const String REMEMBER_ME_KEY = "remember_me";
  static String? appStoreUrl;
  static String? playStoreUrl;
  static String othersUrl =
      'https://play.google.com/store/apps/details?id=com.your.app';
  static String? language;
  static String? usrRef;
  static Vehicle? selectedPM;
  static PackageInfo? info;
  static LoginResponse? userInfo;
  static bool isHms = true;

  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      _cacheBox = await Hive.openBox<String>(_cacheBoxName);
      _offlineQueueBox = await Hive.openBox<Map>(_offlineQueueBoxName);
      _userDataBox = await Hive.openBox<String>(_userDataBoxName);
      _appDataBox = await Hive.openBox<String>(_appDataBoxName);
      _vehiclePtiBox = await Hive.openBox<String>(_vehiclePtiBoxName);

      debugPrint('OfflineStorageService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing OfflineStorageService: $e');
      rethrow;
    }
  }

  static Future<void> cacheApiResponse(
    String key,
    Map<String, dynamic> data, {
    Duration? ttl,
  }) async {
    try {
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'ttl': ttl?.inMilliseconds,
      };

      await _cacheBox?.put(key, jsonEncode(cacheData));
      debugPrint('Cached API response for key: $key');
    } catch (e) {
      debugPrint('Error caching API response: $e');
    }
  }

  static Map<String, dynamic>? getCachedApiResponse(String key) {
    try {
      final cachedString = _cacheBox?.get(key);
      if (cachedString == null) return null;

      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final ttl = cacheData['ttl'] as int?;

      if (ttl != null) {
        final expiryTime = timestamp + ttl;
        if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
          _cacheBox?.delete(key);
          debugPrint('Cache expired for key: $key');
          return null;
        }
      }

      debugPrint('Retrieved cached data for key: $key');
      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error retrieving cached data: $e');
      return null;
    }
  }

  static Future<void> queueOfflineRequest({
    required String method,
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? optimisticData,
    String? cacheKey,
  }) async {
    try {
      if (_offlineQueueBox == null) {
        debugPrint('❌ Error: Offline queue box not initialized!');
        return;
      }

      final request = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'method': method,
        'url': url,
        'data': data,
        'headers': headers,
        'queryParameters': queryParameters,
        'optimisticData': optimisticData,
        'cacheKey': cacheKey,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'retryCount': 0,
      };

      await _offlineQueueBox?.add(request);
      final queueSize = _offlineQueueBox?.length ?? 0;
      debugPrint(
        '✅ Queued offline request: $method $url (Queue size: $queueSize)',
      );
    } catch (e) {
      debugPrint('❌ Error queuing offline request: $e');
    }
  }

  static List<Map<dynamic, dynamic>> getQueuedRequests() {
    try {
      final requests = _offlineQueueBox?.values.toList() ?? [];
      debugPrint(
        '📋 Retrieved ${requests.length} queued requests from storage',
      );
      return requests;
    } catch (e) {
      debugPrint('❌ Error getting queued requests: $e');
      return [];
    }
  }

  static Future<void> removeQueuedRequest(String requestId) async {
    try {
      final requests = _offlineQueueBox?.values.toList() ?? [];
      for (int i = 0; i < requests.length; i++) {
        if (requests[i]['id'] == requestId) {
          await _offlineQueueBox?.deleteAt(i);
          debugPrint('Removed queued request: $requestId');
          break;
        }
      }
    } catch (e) {
      debugPrint('Error removing queued request: $e');
    }
  }

  static Future<void> updateQueuedRequestRetry(
    String requestId, {
    required int newRetryCount,
  }) async {
    try {
      final requests = _offlineQueueBox?.values.toList() ?? [];
      for (int i = 0; i < requests.length; i++) {
        if (requests[i]['id'] == requestId) {
          requests[i]['retryCount'] = newRetryCount;
          requests[i]['lastRetryTime'] = DateTime.now().millisecondsSinceEpoch;
          await _offlineQueueBox?.putAt(i, requests[i]);
          debugPrint(
            'Updated retry count for request $requestId to $newRetryCount',
          );
          break;
        }
      }
    } catch (e) {
      debugPrint('Error updating retry count: $e');
    }
  }

  static Future<void> clearQueue() async {
    try {
      await _offlineQueueBox?.clear();
      debugPrint('Cleared offline request queue');
    } catch (e) {
      debugPrint('Error clearing queue: $e');
    }
  }

  static Future<void> storeUserData(
    String key,
    Map<String, dynamic> data,
  ) async {
    try {
      await _userDataBox?.put(key, jsonEncode(data));
      debugPrint('Stored user data for key: $key');
    } catch (e) {
      debugPrint('Error storing user data: $e');
    }
  }

  static Map<String, dynamic>? getUserData(String key) {
    try {
      final dataString = _userDataBox?.get(key);
      if (dataString == null) return null;

      return jsonDecode(dataString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  static Future<void> removeUserData(String key) async {
    try {
      await _userDataBox?.delete(key);
      debugPrint('Removed user data for key: $key');
    } catch (e) {
      debugPrint('Error removing user data: $e');
    }
  }

  static List<String> getAllStoredKeys() {
    try {
      return _userDataBox?.keys.cast<String>().toList() ?? [];
    } catch (e) {
      debugPrint('Error getting stored keys: $e');
      return [];
    }
  }

  static Future<void> setUserIC(String userIC) async {
    await setAppString(USER_IC_KEY, userIC);
  }

  static String getUserIC() {
    return getAppString(USER_IC_KEY);
  }

  static Future<void> setAppConfigBackup(String config) async {
    await setAppString(APP_CONFIG_BACKUP_KEY, config);
  }

  static String getAppConfigBackup() {
    return getAppString(APP_CONFIG_BACKUP_KEY);
  }

  static LoginResponse? getLoginResponseModel() {
    final data = getLoginData();
    if (data == null) return null;
    try {
      return LoginResponse.fromJson(data);
    } catch (e) {
      debugPrint('Error parsing login response model: $e');
      return null;
    }
  }

  static Future<void> setLoginResponseModel(LoginResponse model) async {
    await setLoginData(model);
  }

  static Vehicle? getVehicleResponseModel() {
    final data = getVehicleData();
    if (data == null) return null;
    try {
      return Vehicle.fromJson(data);
    } catch (e) {
      debugPrint('Error parsing vehicle response model: $e');
      return null;
    }
  }

  static Future<void> setVehicleResponseModel(Vehicle model) async {
    await setVehicleData(model.toJson());
  }

  static Future<void> setAppString(String key, String value) async {
    try {
      if (key == CURRENT_VEHICLE_PTI_KEY) {
        await _vehiclePtiBox?.put(key, value);
        debugPrint('Stored vehicle PTI string for key: $key');
      } else {
        await _appDataBox?.put(key, value);
        debugPrint('Stored app string for key: $key');
      }
    } catch (e) {
      debugPrint('Error storing app string: $e');
    }
  }

  static String getAppString(String key, {String defaultValue = ""}) {
    try {
      if (key == CURRENT_VEHICLE_PTI_KEY) {
        return _vehiclePtiBox?.get(key) ?? defaultValue;
      } else {
        return _appDataBox?.get(key) ?? defaultValue;
      }
    } catch (e) {
      debugPrint('Error getting app string: $e');
      return defaultValue;
    }
  }

  static Future<void> removeAppValue(String key) async {
    try {
      if (key == CURRENT_VEHICLE_PTI_KEY) {
        await _vehiclePtiBox?.delete(key);
        debugPrint('Removed vehicle PTI data for key: $key');
      } else {
        await _appDataBox?.delete(key);
        debugPrint('Removed app data for key: $key');
      }
    } catch (e) {
      debugPrint('Error removing app data: $e');
    }
  }

  static Future<Locale> setLocale(String languageCode) async {
    await setAppString(LANGUAGE_CODE_KEY, languageCode);
    return Locale(languageCode);
  }

  static Locale getLocale() {
    String languageCode = getAppString(LANGUAGE_CODE_KEY, defaultValue: "en");
    return Locale(languageCode);
  }

  static Future<void> setAuthToken(String accessToken) async {
    await setAppString(ACCESS_TOKEN_KEY, accessToken);
  }

  static String getAuthToken() {
    return getAppString(ACCESS_TOKEN_KEY);
  }

  static Future<void> removeAuthToken() async {
    await removeAppValue(ACCESS_TOKEN_KEY);
  }

  static Future<void> setLoginData(LoginResponse loginData) async {
    try {
      await _appDataBox?.put(LOGIN_DATA_KEY, jsonEncode(loginData));
      debugPrint('Stored login data');
    } catch (e) {
      debugPrint('Error storing login data: $e');
    }
  }

  static Map<String, dynamic>? getLoginData() {
    try {
      final dataString = _appDataBox?.get(LOGIN_DATA_KEY);
      if (dataString == null) return null;
      return jsonDecode(dataString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting login data: $e');
      return null;
    }
  }

  static Future<void> setVehicleData(Map<String, dynamic> vehicleData) async {
    try {
      await _appDataBox?.put(VEHICLE_DATA_KEY, jsonEncode(vehicleData));
      debugPrint('Stored vehicle data');
    } catch (e) {
      debugPrint('Error storing vehicle data: $e');
    }
  }

  static Map<String, dynamic>? getVehicleData() {
    try {
      final dataString = _appDataBox?.get(VEHICLE_DATA_KEY);
      if (dataString == null) return null;
      return jsonDecode(dataString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting vehicle data: $e');
      return null;
    }
  }

  static Future<void> setLoginDate(String date) async {
    await setAppString(LOGIN_DATE_KEY, date);
  }

  static String getLoginDate() {
    String date = getAppString(LOGIN_DATE_KEY);
    return date.isEmpty
        ? DateFormat('yyyy-MM-dd').format(DateTime.now())
        : date;
  }

  /// Clean up offline queue box and free resources
  static Future<void> cleanupOfflineQueue() async {
    try {
      // Get queue size before clearing
      final queueSize = _offlineQueueBox?.length ?? 0;

      if (queueSize > 0) {
        debugPrint(
          '🧹 Cleaning up offline queue with $queueSize pending requests',
        );
      } else {
        debugPrint('✅ Offline queue is already empty');
      }

      // Clear all items from the queue
      await _offlineQueueBox?.clear();

      // Verify queue is empty
      final remainingItems = _offlineQueueBox?.length ?? 0;
      if (remainingItems == 0) {
        debugPrint('✅ Offline queue cleaned successfully (0 items remaining)');
      } else {
        debugPrint('⚠️ Warning: Offline queue still has $remainingItems items');
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up offline queue: $e');
    }
  }

  static Future<void> clearAllDataOnLogout() async {
    try {
      // Determine whether the user chose to be remembered. If so, preserve
      // specific keys (login data, auth token, login date and the remember
      // flag itself). Otherwise clear everything as before.
      final rememberMeValue = _appDataBox?.get(REMEMBER_ME_KEY) ?? 'false';
      final shouldRemember = rememberMeValue.toString().toLowerCase() == 'true';

      // Snapshot values to preserve when rememberMe is enabled

      String? preservedAccessToken;

      String? preservedSavedLogin;
      String? preservedSavedPassword;

      if (shouldRemember) {
        preservedAccessToken = _appDataBox?.get(ACCESS_TOKEN_KEY);

        preservedSavedLogin = _appDataBox?.get(SAVED_LOGIN_KEY);
        preservedSavedPassword = _appDataBox?.get(SAVED_PASSWORD_KEY);
      }

      await _cacheBox?.clear();
      debugPrint('✅ Cleared API response cache');

      // Clean offline queue properly
      await cleanupOfflineQueue();

      await _userDataBox?.clear();
      debugPrint('✅ Cleared user data');

      // Clear all app data, then restore preserved keys if required.
      await _appDataBox?.clear();
      debugPrint('✅ Cleared app data');

      if (shouldRemember) {
        if (preservedAccessToken != null) {
          await _appDataBox?.put(ACCESS_TOKEN_KEY, preservedAccessToken);
        }

        if (preservedSavedLogin != null) {
          await _appDataBox?.put(SAVED_LOGIN_KEY, preservedSavedLogin);
        }
        if (preservedSavedPassword != null) {
          await _appDataBox?.put(SAVED_PASSWORD_KEY, preservedSavedPassword);
        }
        // Re-store the remember flag itself
        await _appDataBox?.put(REMEMBER_ME_KEY, 'true');
      }

      debugPrint(
        '✅ Successfully cleared all cached data on logout' +
            (shouldRemember
                ? ' (preserved credentials due to remember-me)'
                : ''),
      );
    } catch (e) {
      debugPrint('❌ Error clearing all data on logout: $e');
    }
  }

  static Future<void> clearApiCache() async {
    try {
      await _cacheBox?.clear();
      debugPrint('Cleared API cache only');
    } catch (e) {
      debugPrint('Error clearing API cache: $e');
    }
  }

  static Map<String, int> getCacheStats() {
    try {
      return {
        'apiCache': _cacheBox?.length ?? 0,
        'offlineQueue': _offlineQueueBox?.length ?? 0,
        'userData': _userDataBox?.length ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
      return {'apiCache': 0, 'offlineQueue': 0, 'userData': 0};
    }
  }

  static Future<void> clearCache() async {
    try {
      await _cacheBox?.clear();
      debugPrint('Cleared all cached data');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Get current vehicle PTI info from storage
  static Map<String, dynamic>? getCurrentVehiclePtiInfo() {
    try {
      final dataString = _vehiclePtiBox?.get(CURRENT_VEHICLE_PTI_KEY);
      if (dataString == null) return null;
      return jsonDecode(dataString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting current vehicle PTI info: $e');
      return null;
    }
  }

  /// Check if PTI should be redone for the given vehicle ID
  static bool shouldRedoPti(String currentVehicleId) {
    final ptiInfo = getCurrentVehiclePtiInfo();
    if (ptiInfo == null) return true; // No PTI record, needs to be done

    final storedVehicleId = ptiInfo['vehicleId'] as String?;
    return storedVehicleId != currentVehicleId; // True if vehicle changed
  }

  static Future<void> dispose() async {
    try {
      await _cacheBox?.close();
      await _offlineQueueBox?.close();
      await _userDataBox?.close();
      await _vehiclePtiBox?.close();
      debugPrint('OfflineStorageService disposed');
    } catch (e) {
      debugPrint('Error disposing OfflineStorageService: $e');
    }
  }
}
