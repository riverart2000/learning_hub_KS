# App Configuration System

This document explains how to use the centralized app configuration system in Learning Hub KS.

## 📄 Configuration File

All app metadata is centralized in: **`assets/data/app_config.json`**

## 🎯 What's Configurable

### App Information
- `name`: Full app name (e.g., "Learning Hub KS")
- `displayName`: Display name shown in UI
- `packageName`: Bundle/package identifier
- `version`: Semantic version (e.g., "0.1.0")
- `versionCode`: Numeric version code
- `buildNumber`: Build number
- `tagline`: App tagline/slogan
- `subtitle`: App subtitle (e.g., "PlainOS")
- `shortDescription`: Brief description
- `description`: Full app description
- `category`: App Store category
- `contentRating`: Content rating

### Developer Information
- `name`: Developer/company name
- `author`: Author name
- `email`: Developer email
- `supportEmail`: Support contact email
- `organization`: Organization name
- `website`: Developer website
- `bio`: Developer biography

### Legal Information
- `copyright`: Copyright notice
- `privacyNote`: Privacy policy summary

### Platform Configuration
- `minSdkVersion`: Minimum Android SDK
- `targetSdkVersion`: Target Android SDK
- `compileSdkVersion`: Compile Android SDK
- `minMacOSVersion`: Minimum macOS version
- `minIOSVersion`: Minimum iOS version

## 🔧 How to Use

### 1. Update Configuration

Edit `assets/data/app_config.json`:

```json
{
  "app": {
    "name": "Learning Hub KS",
    "version": "0.1.0",
    "versionCode": "1",
    ...
  }
}
```

### 2. Sync to Platform Files

Run the sync script to update all platform-specific files:

```bash
chmod +x sync_app_config.sh
./sync_app_config.sh
```

This automatically updates:
- ✅ `pubspec.yaml`
- ✅ `android/app/src/main/AndroidManifest.xml`
- ✅ `ios/Runner/Info.plist`
- ✅ `macos/Runner/Configs/AppInfo.xcconfig`
- ✅ `web/manifest.json`
- ✅ `web/index.html`

### 3. Access in Dart Code

Use the `AppConfigService` to access config values:

```dart
import 'package:learning_hub/services/app_config_service.dart';

// Initialize in main()
await AppConfigService.loadConfig();

// Access anywhere in your app
String appName = AppConfigService.appName;
String version = AppConfigService.appVersion;
String author = AppConfigService.author;
String copyright = AppConfigService.copyright;

// Full app info
String info = AppConfigService.fullAppInfo; // "Learning Hub KS v0.1.0 (1)"
```

## 📚 Available Getters

### App Info
```dart
AppConfigService.appName              // "Learning Hub KS"
AppConfigService.appDisplayName       // Display name
AppConfigService.packageName          // "com.biohackerjoe.learninghub"
AppConfigService.appVersion           // "0.1.0"
AppConfigService.versionCode          // "1"
AppConfigService.buildNumber          // "1"
AppConfigService.appTagline           // App tagline
AppConfigService.appSubtitle          // "PlainOS"
AppConfigService.appShortDescription  // Short description
AppConfigService.appDescription       // Full description
AppConfigService.category             // "Education"
AppConfigService.contentRating        // "Everyone"
AppConfigService.fullAppInfo          // "Learning Hub KS v0.1.0 (1)"
```

### Developer Info
```dart
AppConfigService.developerName    // "PlainOS by Joe Bains"
AppConfigService.author           // "Joe Bains"
AppConfigService.developerEmail   // Email address
AppConfigService.supportEmail     // Support email
AppConfigService.organization     // "PlainOS"
AppConfigService.website          // "https://plainos.io"
AppConfigService.developerBio     // Biography
AppConfigService.fullDeveloperInfo // Full developer details
```

### Legal Info
```dart
AppConfigService.copyright        // Copyright notice
AppConfigService.privacyNote      // Privacy summary
```

### Platform Info
```dart
AppConfigService.minSdkVersion       // 21
AppConfigService.targetSdkVersion    // 35
AppConfigService.compileSdkVersion   // 36
AppConfigService.minMacOSVersion     // "10.14"
AppConfigService.minIOSVersion       // "12.0"
```

### UI Text
```dart
AppConfigService.welcomeTitle         // Welcome screen title
AppConfigService.welcomeSubtitle      // Welcome subtitle
AppConfigService.signInPrompt         // Sign in text
AppConfigService.termsText            // Terms text
AppConfigService.homeWelcomePrefix    // "Welcome, "
AppConfigService.homeCategoriesTitle  // "Categories"
```

## 🎨 Example Usage in UI

```dart
// In your settings screen
Text(
  AppConfigService.fullAppInfo,
  style: TextStyle(fontSize: 16),
);

// Show developer info
Text(AppConfigService.developerName);
Text(AppConfigService.supportEmail);
Text(AppConfigService.website);

// Copyright footer
Text(
  AppConfigService.copyright,
  style: TextStyle(fontSize: 12, color: Colors.grey),
);

// Welcome screen
Text(
  AppConfigService.welcomeTitle,
  style: Theme.of(context).textTheme.headlineMedium,
);
Text(
  AppConfigService.welcomeSubtitle,
  style: Theme.of(context).textTheme.bodyLarge,
);
```

## 🔄 Version Updates

To update the app version:

1. **Edit config file**:
```json
{
  "app": {
    "version": "0.2.0",
    "versionCode": "2",
    "buildNumber": "2"
  }
}
```

2. **Run sync script**:
```bash
./sync_app_config.sh
```

3. **Rebuild app**:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## 🛠️ Benefits

✅ **Single Source of Truth**: Update one file, sync everywhere
✅ **Type Safety**: Access via Dart getters with fallbacks
✅ **Easy Maintenance**: No need to edit platform-specific files manually
✅ **Version Control**: Track all metadata in JSON
✅ **Consistency**: Same info across all platforms
✅ **Automated**: Sync script updates everything

## 📝 Notes

- The sync script requires `jq` for JSON parsing (auto-installs on macOS)
- Always run sync script after editing `app_config.json`
- `AppConfigService.loadConfig()` must be called in `main()` before `runApp()`
- The service uses `package_info_plus` for runtime version info from `pubspec.yaml`
- Config file is loaded from assets at runtime

## 🚀 Workflow

```bash
# 1. Edit config
vi assets/data/app_config.json

# 2. Sync to platforms
./sync_app_config.sh

# 3. Build
flutter clean
flutter pub get
flutter build apk --release
```

---

**Last Updated**: 2025
**Maintained By**: PlainOS by Joe Bains

