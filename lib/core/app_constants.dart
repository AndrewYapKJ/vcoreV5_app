/// Global app information constants
class AppConstants {
  static const String appName = 'Gussmann';
  static const String versionLabel = 'v1';
  static const String defaultVersion = '1.0.0';
  static const String copyrightText = '© Gussmann Integrated Solution';

  /// Returns formatted version string
  static String getVersionString(String version) {
    return '$versionLabel ($version)';
  }

  /// Returns formatted copyright with current year
  static String getCopyrightText(int year) {
    return '© $year $appName Integrated Solution';
  }
}
