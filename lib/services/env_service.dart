import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  /// Get platform-specific suffix (ANDROID or IOS)
  static String get _platformSuffix {
    return Platform.isAndroid ? 'ANDROID' : 'IOS';
  }

  /// Get Firebase API Key (platform-specific)
  static String get firebaseApiKey {
    return _getEnvVar('FIREBASE_API_KEY_$_platformSuffix');
  }

  /// Get Firebase App ID (platform-specific)
  static String get firebaseAppId {
    return _getEnvVar('FIREBASE_APP_ID_$_platformSuffix');
  }

  /// Get Firebase Messaging Sender ID (platform-specific)
  static String get firebaseMessagingSenderId {
    return _getEnvVar('FIREBASE_MESSAGING_SENDER_ID_$_platformSuffix');
  }

  /// Get Firebase Project ID (platform-specific)
  static String get firebaseProjectId {
    return _getEnvVar('FIREBASE_PROJECT_ID_$_platformSuffix');
  }

  /// Get Firebase Storage Bucket (platform-specific)
  static String get firebaseStorageBucket {
    return _getEnvVar('FIREBASE_STORAGE_BUCKET_$_platformSuffix');
  }

  /// Get iOS Bundle ID (iOS only)
  static String get firebaseIosBundleId {
    if (Platform.isIOS) {
      return _getEnvVar('FIREBASE_IOS_BUNDLE_ID');
    }
    return ''; // Return empty string for non-iOS platforms
  }

  /// Private helper method to get environment variable
  /// First checks OS environment variables, then falls back to dotenv
  /// Returns empty string if not found (allows app to continue with warning)
  static String _getEnvVar(String key, {String defaultValue = ''}) {
    // First try to get from OS environment variables
    final osValue = Platform.environment[key];
    if (osValue != null && osValue.isNotEmpty) {
      return osValue;
    }

    // Fall back to dotenv (.env file)
    try {
      final dotenvValue = dotenv.env[key];
      if (dotenvValue != null && dotenvValue.isNotEmpty) {
        return dotenvValue;
      }
    } catch (e) {
      // dotenv not initialized yet, continue to default value
    }

    // Use default value if provided
    if (defaultValue.isNotEmpty) {
      return defaultValue;
    }

    // Return empty string (warning will be shown in validation)
    // This allows the app to continue rather than crash
    return '';
  }

  /// Get all Firebase configuration as a map
  static Map<String, String> getFirebaseConfig() {
    final config = {
      'apiKey': firebaseApiKey,
      'appId': firebaseAppId,
      'messagingSenderId': firebaseMessagingSenderId,
      'projectId': firebaseProjectId,
      'storageBucket': firebaseStorageBucket,
    };

    // Add iOS-specific bundle ID if on iOS
    if (Platform.isIOS) {
      config['iosBundleId'] = firebaseIosBundleId;
    }

    return config;
  }

  /// Validate that all required environment variables are set
  static List<String> validateEnvironment() {
    final missingVars = <String>[];
    final platformSuffix = _platformSuffix;

    final requiredVars = [
      'FIREBASE_API_KEY_$platformSuffix',
      'FIREBASE_APP_ID_$platformSuffix',
      'FIREBASE_MESSAGING_SENDER_ID_$platformSuffix',
      'FIREBASE_PROJECT_ID_$platformSuffix',
      'FIREBASE_STORAGE_BUCKET_$platformSuffix',
    ];

    // Add iOS bundle ID to required vars if on iOS
    if (Platform.isIOS) {
      requiredVars.add('FIREBASE_IOS_BUNDLE_ID');
    }

    for (final variable in requiredVars) {
      final osValue = Platform.environment[variable];
      final envValue = dotenv.env[variable];

      if ((osValue == null || osValue.isEmpty) &&
          (envValue == null || envValue.isEmpty)) {
        missingVars.add(variable);
      }
    }

    return missingVars;
  }
}

/// Custom exception for missing environment variables
class EnvVariableNotFoundException implements Exception {
  final String message;

  EnvVariableNotFoundException(this.message);

  @override
  String toString() => 'EnvVariableNotFoundException: $message';
}
