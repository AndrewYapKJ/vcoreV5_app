# AGConnect Remote Config Setup

This document explains how AGConnect Remote Config is configured as a fallback when Google Play Services are unavailable.

## Overview

The app now has automatic fallback logic for remote configuration:
1. **Primary**: Firebase Remote Config (when Google Play Services available)
2. **Fallback**: Huawei AGConnect Remote Config (when Google Play Services unavailable)

## Architecture

### RemoteConfigService
- **File**: [lib/services/remote_config_service.dart](../lib/services/remote_config_service.dart)
- Singleton pattern for global access
- Automatically detects available services at initialization
- Provides unified API for both providers
- Logs which provider is active

### How It Works

1. **Initialization** (in `main.dart`):
   ```dart
   await RemoteConfigService().initialize();
   ```

2. **Detection Logic**:
   - Checks if Google Play Services are available using platform channel
   - If available → initializes Firebase Remote Config
   - If unavailable → initializes Huawei AGConnect Remote Config
   - Graceful fallback to Huawei if Firebase fails

3. **Unified API**:
   - `getString(key, defaultValue)` - Get string values
   - `getBool(key, defaultValue)` - Get boolean values
   - `getInt(key, defaultValue)` - Get integer values
   - `getDouble(key, defaultValue)` - Get double values
   - `fetchAndActivate()` - Refresh config
   - `getKeys()` - Get all available keys
   - `setDefaults(Map)` - Set default values

## Usage

### Basic Usage

```dart
import 'package:vcore_v5_app/services/remote_config_service.dart';

final service = RemoteConfigService();

// Get values
String value = service.getString('my_key', defaultValue: 'default');
bool featureEnabled = service.getBool('feature_flag', defaultValue: false);

// Refresh config
await service.fetchAndActivate();

// Check active provider
print(service.activeProvider); // firebase or huawei
```

### Using with Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcore_v5_app/providers/remote_config_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProvider = ref.watch(remoteConfigProviderProvider);
    final service = ref.watch(remoteConfigServiceProvider);
    
    return Text('Active: $activeProvider');
  }
}
```

## Configuration

### Firebase Remote Config
- Configured in [lib/services/firebase_service.dart](../lib/services/firebase_service.dart)
- Use Firebase Console to manage values
- Fetch timeout: 1 minute
- Minimum fetch interval: 1 hour

### Huawei AGConnect Remote Config
- Configured in [android/app/agconnect-services.json](../android/app/agconnect-services.json)
- Use Huawei AppGallery Connect to manage values
- Fallback when Google Play Services unavailable

## Platform-Specific Setup

### Android

1. **Google Play Services Check**: Uses native method channel
2. **Firebase**: Configured in `google-services.json`
3. **Huawei**: Configured in `agconnect-services.json`

### iOS

1. **Google Play Services Check**: Returns `false` (iOS doesn't have GMS)
2. **Firebase**: Primary provider (configured in `GoogleService-Info.plist`)
3. **Huawei**: Available as fallback but requires Huawei SDK integration

## Debugging

Enable verbose logging:
```dart
// The service logs all operations with [RemoteConfig] prefix
// Check console/Logcat for messages like:
// [RemoteConfig] Google Play Services available, using Firebase
// [RemoteConfig] Error fetching and activating: ...
```

## Dependencies Added

- `agconnect_remote_config: ^1.9.0` - Huawei AGConnect
- No additional external packages needed for Google Play Services detection

## Example Widget

See [lib/widgets/remote_config_example.dart](../lib/widgets/remote_config_example.dart) for a complete example showing:
- How to display active provider
- How to fetch string values
- How to fetch boolean feature flags
- How to refresh configuration
