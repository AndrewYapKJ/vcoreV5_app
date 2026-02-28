import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Custom Gussmann color scheme
class GussmannColorScheme {
  static const String name = 'Default (Gussmann)';

  // Brand colors
  static const Color primaryColor = Color(0xFF231262); // Dark purple
  static const Color secondaryColor = Color(0xFFA4CB50); // Lime green

  // Derived colors
  static const Color tertiaryColor = Color(0xFF7B4397); // Purple complement
  static const Color errorColor = Color(0xFFE74C3C); // Vibrant red

  // Surface colors
  static const Color surfaceColor = Color(0xFFFAFAFA); // Light background
  static const Color surfaceDimColor = Color(
    0xFFF0F0F0,
  ); // Slightly darker surface

  // Additional colors
  static const Color outlineColor = Color(0xFFE0E0E0); // Light border
  static const Color onPrimaryColor = Color(
    0xFFFFFFFF,
  ); // White text on primary

  /// Creates a ColorScheme for light theme
  static ColorScheme get lightColorScheme {
    return ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      error: errorColor,
      surface: surfaceColor,
      outline: outlineColor,
      onPrimary: onPrimaryColor,
      onSecondary: Color(0xFF2D2D2D), // Dark text on lime
      onError: Colors.white,
      onSurface: Color(0xFF1A1A1A), // Dark text on surface
      onTertiary: Colors.white,
    );
  }

  /// Creates a ColorScheme for dark theme
  static ColorScheme get darkColorScheme {
    return ColorScheme.dark(
      primary: Color(0xFF8B68D1), // Lighter purple for dark mode
      secondary: Color(0xFFC8E6A0), // Lighter lime for dark mode
      tertiary: Color(0xFFB39FDB), // Lighter purple complement
      error: Color(0xFFEF5350), // Lighter red for dark mode
      surface: Color(0xFF1A1A1A), // Dark background
      outline: Color(0xFF424242), // Dark border
      onPrimary: Color(0xFF1A1A1A),
      onSecondary: Color(0xFF1A1A1A),
      onError: Color(0xFF1A1A1A),
      onSurface: Color(0xFFFFFFFF), // White text on dark
      onTertiary: Color(0xFF1A1A1A),
    );
  }

  /// Creates a FlexSchemeData for use with FlexColorScheme
  static FlexSchemeData get flexSchemeData {
    return FlexSchemeData(
      name: name,
      description: 'Gussmann Logistics Brand Colors',
      light: FlexSchemeColor(
        primary: primaryColor,
        primaryContainer: Color(0xFFF3E5FF),
        secondary: secondaryColor,
        secondaryContainer: Color(0xFFEFF7CC),
        tertiary: tertiaryColor,
        tertiaryContainer: Color(0xFFF3E5FF),
        appBarColor: primaryColor,
        error: errorColor,
      ),
      dark: FlexSchemeColor(
        primary: Color(0xFF8B68D1),
        primaryContainer: Color(0xFF3E1F5C),
        secondary: Color(0xFFC8E6A0),
        secondaryContainer: Color(0xFF556B2F),
        tertiary: Color(0xFFB39FDB),
        tertiaryContainer: Color(0xFF3E1F5C),
        appBarColor: Color(0xFF1A1A1A),
        error: Color(0xFFEF5350),
      ),
    );
  }
}
