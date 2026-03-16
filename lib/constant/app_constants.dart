/// Global app information constants
class AppConstants {
  static const String appName = 'Gussmann';
  static const String versionLabel = '1.0.0';

  static const String buildVersion = '2';
  static const String copyrightText = '© Gussmann Integrated Solution';
  // static const String apiBaseUrl = 'https://api.gussmann.com/v1';

  /// Returns formatted version string
  static String getVersionString() {
    return 'v$versionLabel ($buildVersion)';
  }

  /// Returns formatted copyright with current year
  static String getCopyrightText(int year) {
    return '© $year $appName Integrated Solution';
  }
}
