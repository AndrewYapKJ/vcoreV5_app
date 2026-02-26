# AGConnect Remote Config Integration Guide

## Setup Complete ✅

AGConnect Remote Config has been successfully integrated into your Flutter app with automatic fallback logic.

## What Was Added

### 1. **Dart Layer**
- `lib/services/remote_config_service.dart` - Core service with fallback logic
- `lib/providers/remote_config_provider.dart` - Riverpod providers
- `lib/widgets/remote_config_example.dart` - Example usage widget
- Updated `lib/main.dart` - Service initialization

### 2. **Android Native Layer**
- `android/app/src/main/kotlin/gis/vcorev5/RemoteConfigMethodChannel.kt` - Google Play Services checker
- Updated `android/app/src/main/kotlin/gis/vcorev5/MainActivity.kt` - Channel setup

### 3. **Dependencies**
- Added `agconnect_remote_config: ^1.9.0`

## How It Works

### Initialization Flow (main.dart)
```
1. Firebase initialized
2. RemoteConfigService().initialize() called
3. Service checks if Google Play Services available
   ├─ YES → Use Firebase Remote Config
   └─ NO → Fall back to Huawei AGConnect Remote Config
4. App ready to use remote config
```

### Runtime Flow
```dart
// Get any value - service handles provider internally
String apiUrl = RemoteConfigService().getString('api_url', defaultValue: 'https://api.default.com');
bool feature = RemoteConfigService().getBool('new_feature', defaultValue: false);
```

## Usage Examples

### Simple Usage
```dart
import 'package:vcore_v5_app/services/remote_config_service.dart';

final service = RemoteConfigService();

// Get values
String apiUrl = service.getString('api_url');
bool isDarkMode = service.getBool('dark_mode');
int maxRetries = service.getInt('max_retries');

// Refresh config
await service.fetchAndActivate();
```

### With Riverpod (Recommended)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vcore_v5_app/providers/remote_config_provider.dart';

class SettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(remoteConfigServiceProvider);
    final provider = ref.watch(remoteConfigProviderProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        children: [
          ListTile(title: Text('Active Provider: $provider')),
          SwitchListTile(
            title: Text('Dark Mode'),
            value: service.getBool('dark_mode'),
            onChanged: (_) => service.fetchAndActivate(),
          ),
        ],
      ),
    );
  }
}
```

### Handling Feature Flags
```dart
if (RemoteConfigService().getBool('enable_new_checkout', defaultValue: false)) {
  // Show new checkout UI
  return NewCheckoutPage();
} else {
  // Show legacy checkout
  return LegacyCheckoutPage();
}
```

### Dynamic API Configuration
```dart
final apiConfig = {
  'baseUrl': RemoteConfigService().getString('api_base_url'),
  'timeout': RemoteConfigService().getInt('api_timeout_ms'),
  'retries': RemoteConfigService().getInt('api_max_retries'),
};
```

## Configuration Files

### Firebase Remote Config
- **Console**: https://console.firebase.google.com/project/vcorev5/config
- **Values**: Manage in Firebase Console
- **Default Config**: Defined in `_initializeFirebase()`

### Huawei AGConnect Remote Config
- **Console**: https://appgallery.cloud.huawei.com/
- **Config File**: `android/app/agconnect-services.json`
- **Values**: Manage in AppGallery Connect console

## Debugging

### Check Active Provider
```dart
final service = RemoteConfigService();
print('Using: ${service.activeProvider}'); // firebase or huawei
```

### Enable Debug Logging
All operations log with `[RemoteConfig]` prefix. Check Logcat/Console:
```
[RemoteConfig] Google Play Services available, using Firebase
[RemoteConfig] Firebase Remote Config initialized
[RemoteConfig] Getting string value for 'api_url': https://api.prod.com
```

### Test Platform Channel
```dart
// If you want to test the platform channel directly
const platform = MethodChannel('com.gis.vcorev5/remoteconfig');
try {
  final result = await platform.invokeMethod<bool>('isPlayServicesAvailable');
  print('Play Services Available: $result');
} catch (e) {
  print('Error: $e');
}
```

## Key Features

✅ **Automatic Fallback** - No manual switching required
✅ **Unified API** - Same methods work for both providers
✅ **Error Handling** - Graceful degradation if both fail
✅ **Logging** - Full visibility into what's happening
✅ **Type Safety** - Separate methods for each data type
✅ **Default Values** - Always fallback to defaults
✅ **Hot Reload** - Can refresh config on demand

## Testing on Different Devices

### Device with Google Play Services
- Uses Firebase Remote Config automatically
- Faster, more reliable
- Better Firebase integration

### Device without Google Play Services
- Falls back to Huawei AGConnect
- Ensures app works in restricted environments
- No disruption to user experience

### Emulator
- Android Emulator with Google Play: Uses Firebase
- Android Emulator without Google Play: Uses Huawei
- iOS Simulator: Uses Firebase (iOS doesn't have GMS)

## Best Practices

1. **Always use default values**
   ```dart
   service.getString('key', defaultValue: 'safe_default')
   ```

2. **Cache values when possible**
   ```dart
   final theme = service.getString('theme_mode');
   sharedPrefs.setString('cached_theme', theme);
   ```

3. **Refresh on app launch**
   ```dart
   void main() async {
     await RemoteConfigService().initialize();
     await RemoteConfigService().fetchAndActivate(); // Refresh
   }
   ```

4. **Handle both providers in logic**
   - Don't assume which provider is active
   - Values might differ between Firebase and Huawei
   - Test thoroughly on both platforms

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Values not updating | Call `fetchAndActivate()` after initialization |
| Always using Huawei | Check if Google Play Services installed/working |
| Platform channel error | Verify MainActivity calls `RemoteConfigMethodChannel.setupChannel()` |
| Compilation error | Ensure kotlin directory structure: `gis/vcorev5/` |
| Huawei connection fails | Check `agconnect-services.json` is valid and in `android/app/` |

## Next Steps

1. **Set up Firebase values**
   - Go to Firebase Console
   - Add your remote config parameters
   - Activate them

2. **Set up Huawei values**
   - Log into AppGallery Connect
   - Configure remote config values
   - Match Firebase keys for consistency

3. **Test both scenarios**
   ```
   Test Device A (with Google Play): Should use Firebase
   Test Device B (without Google Play): Should use Huawei
   ```

4. **Monitor in production**
   - Check logs for provider usage
   - Monitor fetch success rates
   - Set up analytics for feature flags

## Need Help?

Check these files for more details:
- [Remote Config Service](lib/services/remote_config_service.dart) - Implementation details
- [Example Widget](lib/widgets/remote_config_example.dart) - Complete usage example
- [AGCONNECT_SETUP.md](AGCONNECT_SETUP.md) - Technical details
