# Update System Setup

This document explains the update system implementation for the vcore_v5_app, which includes both Firebase Remote Config force updates and Shorebird patch updates.

## Overview

The app checks for updates on the splash screen in the following order:
1. **Remote Config Check** (Priority 1) - Checks if a force update is required
2. **Shorebird Patch Check** (Priority 2) - Checks for available over-the-air patches

## Architecture

### Files Created

1. **`lib/services/update_service.dart`**
   - Handles all update checking logic
   - Checks Remote Config first for version mismatches
   - Checks Shorebird for available patches
   - Downloads and applies patches

2. **`lib/widgets/update_dialog.dart`**
   - Contains all dialog UI components
   - Force update dialog (redirects to store)
   - Patch update dialog with user choice
   - Download progress dialog
   - Patch complete dialog with restart instructions

3. **`lib/views/splash/splash_view.dart`** (Modified)
   - Integrated update checking on app launch
   - Shows loading indicator during update check

## Features

### 1. Force Update (Remote Config)

When the version code or version name differs from what's configured in Remote Config:
- Shows a **non-dismissible dialog**
- Displays current version vs new version
- Redirects user to Play Store (Android) or App Store (iOS)
- User must update to continue using the app

#### Remote Config Keys Expected:
```
android_version: "1.0.0"
android_build_number: "1"
ios_version: "1.0.0"
ios_build_number: "1"
```

### 2. Shorebird Patch Update

When a new patch is available:
- Shows a dialog asking if user wants to update now or later
- If "Update Now": Downloads patch in background
- Shows success dialog with restart instructions
- User must **kill and restart** the app for patch to take effect

#### Important Note
Shorebird patches require a full app restart (force stop) to apply. The dialog clearly instructs users to:
1. Completely close the app
2. Reopen the app
3. Latest update will be active

## Configuration

### Update Service Configuration

In [`lib/services/update_service.dart`](lib/services/update_service.dart), update these values:

```dart
// For Android Play Store
final packageName = 'com.example.vcore_v5_app'; // Change to your package name

// For iOS App Store
final appId = 'YOUR_APP_ID'; // Change to your App Store ID
```

### Remote Config Setup

1. Go to Firebase Console > Remote Config
2. Add the following parameters:

| Parameter | Type | Value |
|-----------|------|-------|
| `android_version` | String | Current version (e.g., "1.0.0") |
| `android_build_number` | String | Current build number (e.g., "1") |
| `ios_version` | String | Current version (e.g., "1.0.0") |
| `ios_build_number` | String | Current build number (e.g., "1") |

3. When you want to force an update:
   - Update these values to match your new release
   - Users with older versions will be prompted to update from store

## Dependencies Added

```yaml
shorebird_code_push: ^2.0.5  # For Shorebird patch management
package_info_plus: ^8.1.3    # To get current app version
url_launcher: ^6.3.1         # To open store URLs
```

## Translations

Translation keys added to all language files (en, ms, zh):

- `update_available`, `update_required_message`, `current_version`, `new_version`, `update_now`
- `patch_available`, `patch_download_message`, `patch_restart_instruction`
- `downloading_update`, `update_downloaded`, `patch_restart_required`
- `restart_instructions`, `close_app_instruction`, `reopen_app_instruction`, `update_active_instruction`
- `got_it`, `error`, `update_download_failed`, `ok`, `checking_updates`, `update_later`

## Usage Flow

### Splash Screen Flow

```
App Launch
    ↓
Check Remote Config
    ↓
Version Mismatch? → YES → Show Force Update Dialog → Redirect to Store
    ↓ NO
Check Shorebird Patch
    ↓
Patch Available? → YES → Show Patch Dialog → Download → Show Restart Instructions
    ↓ NO
Continue to Login
```

## Testing

### Testing Remote Config Force Update

1. Set Remote Config version to something different from current app version
2. Launch app
3. Should see force update dialog
4. Click "Update Now" should open store

### Testing Shorebird Patch

1. Create a release: `shorebird release android` or `shorebird release ios`
2. Make code changes
3. Create a patch: `shorebird patch android` or `shorebird patch ios`
4. Launch app
5. Should see patch dialog
6. Download patch and restart app to see changes

## Shorebird Commands

```bash
# Create initial release
shorebird release android
shorebird release ios

# Push a patch (after making code changes)
shorebird patch android
shorebird patch ios

# Preview a release
shorebird preview

# Upgrade Shorebird CLI
shorebird upgrade
```

## Important Notes

1. **Remote Config has priority** - Force updates will always be checked first
2. **Patch requires restart** - Users must fully close and restart the app for patches to apply
3. **No patch during force update** - If a force update is required, patch check is skipped
4. **Error handling** - If update checks fail, app continues to login (graceful degradation)
5. **Store URLs** - Remember to update package name and App Store ID in update_service.dart

## Future Enhancements

Consider adding:
- Silent auto-updates for patches (without dialog)
- Scheduled update checks (not just on splash)
- Update download progress percentage
- Rollback capability for failed patches
- A/B testing with Remote Config
