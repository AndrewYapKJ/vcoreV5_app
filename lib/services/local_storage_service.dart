import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _rememberMeKey = "remember_me";
  static const String _userIdKey = "user_id";
  static const String _driverIdKey = "driver_id";
  static const String _tenantIdKey = "tenant_id";
  static const String _userNameKey = "user_name";
  static const String _userMobileKey = "user_mobile";
  static const String _mdtFunctionsKey = "mdt_functions";
  static const String _mdtFunctionsTimestampKey = "mdt_functions_timestamp";

  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  /// Save driver ID
  Future<void> saveDriverId(String driverId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverIdKey, driverId);
  }

  /// Save tenant ID
  Future<void> saveTenantId(String tenantId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tenantIdKey, tenantId);
  }

  /// Save user name
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  /// Save user mobile
  Future<void> saveUserMobile(String mobile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userMobileKey, mobile);
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get saved driver ID
  Future<String?> getSavedDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_driverIdKey);
  }

  /// Get saved tenant ID
  Future<String?> getSavedTenantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tenantIdKey);
  }

  /// Get saved user name
  Future<String?> getSavedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Get saved user mobile
  Future<String?> getSavedUserMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userMobileKey);
  }

  /// Clear all user data
  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_driverIdKey);
    await prefs.remove(_tenantIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userMobileKey);
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_mdtFunctionsKey);
    await prefs.remove(_mdtFunctionsTimestampKey);
  }

  /// Save MDT Functions as JSON
  Future<void> saveMDTFunctions(String mdtFunctionsJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mdtFunctionsKey, mdtFunctionsJson);
    await prefs.setInt(
      _mdtFunctionsTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get saved MDT Functions JSON
  Future<String?> getSavedMDTFunctions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mdtFunctionsKey);
  }

  /// Get MDT Functions last updated timestamp
  Future<int?> getMDTFunctionsTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_mdtFunctionsTimestampKey);
    return timestamp;
  }

  /// Check if user has an active session
  Future<bool> hasActiveSession() async {
    final driverId = await getSavedDriverId();
    final tenantId = await getSavedTenantId();
    return driverId != null && tenantId != null;
  }
}
