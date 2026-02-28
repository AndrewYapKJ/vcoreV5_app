import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'gussmann_color_scheme.dart';

/// Wrapper class to handle both FlexScheme values and custom schemes
class AppColorScheme {
  /// List that includes the custom Gussmann scheme at index 0, followed by all FlexScheme values
  static final List<FlexSchemeData> schemeList = [
    GussmannColorScheme.flexSchemeData,
    ...FlexScheme.values.map((scheme) => scheme.data),
  ];

  /// Get the scheme name by index
  static String getSchemeNameByIndex(int index) {
    if (index < 0 || index >= schemeList.length) {
      return 'Unknown';
    }
    return schemeList[index].name;
  }

  /// Get the FlexSchemeData by index
  static FlexSchemeData getSchemeByIndex(int index) {
    if (index < 0 || index >= schemeList.length) {
      return GussmannColorScheme.flexSchemeData; // Default to Gussmann
    }
    return schemeList[index];
  }

  /// Get all scheme names as a list
  static List<String> getAllSchemeNames() {
    return schemeList.map((scheme) => scheme.name).toList();
  }

  /// Total number of available schemes
  static int get schemeCount => schemeList.length;

  /// Index of the custom Gussmann scheme (always 0)
  static int get gussmannSchemeIndex => 0;
}
