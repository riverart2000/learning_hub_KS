# Quick Start - Learning Kashmir Shaivism

This is a **standalone app** dedicated to Kashmir Shaivism, separate from the general Learning Hub.

## 🚀 Quick Build & Install

The project is already configured with the Kashmir Shaivism package name (`com.plainos.kashmirshaivism`) and Firebase integration. Use the steps below whenever you need a fresh build.

### Android Release APK (recommended)

```bash
# Make sure the helper is executable once per machine
chmod +x build_universal_apk.sh

# Produce a release APK with Firebase enabled
./build_universal_apk.sh

# Install on a connected device
adb install -r ~/Desktop/LearningHubKS-v0.1.0.apk
```

The script runs `flutter clean`, fetches dependencies, builds a universal release APK, and copies it to your Desktop for quick sideloading. Update `google-services.json` first if you regenerated the Firebase project.

### Android App Bundle (Play Store upload)

```bash
flutter build appbundle --release
```

The resulting bundle is at `build/app/outputs/bundle/release/app-release.aab`.

### iOS and macOS Builds

- Run `./build_ios.sh` for an interactive iOS build flow (simulator, Ad Hoc, or App Store IPA).
- Run `./build_macos.sh` to produce a signed macOS `.app` bundle and copy it to your Desktop.

### Firebase Setup Checklist

1. Visit https://console.firebase.google.com and create the **Learning Kashmir Shaivism** project.
2. Register the Android app with package `com.plainos.kashmirshaivism` and download `google-services.json` to `android/app/`.
3. (Optional) Register the iOS/macOS apps and place the `GoogleService-Info.plist` in the corresponding `ios/Runner/` or `macos/Runner/` directories.
4. Enable Authentication (Email/Password) and Firestore, then apply these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /userProgress/{progressId} {
      allow read, write: if request.auth != null;
    }
    match /quizAttempts/{attemptId} {
      allow read, write: if request.auth != null;
    }
    match /leaderboard/{entry} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null;
    }
  }
}
```

That’s everything you need for a full-featured build; there’s no longer a Firebase-disabled variant.

## 📦 Complete Package Details

### This is a NEW Standalone App

| Property | Value |
|----------|-------|
| **App Name** | Learning Kashmir Shaivism |
| **Package (Android)** | com.plainos.kashmirshaivism |
| **Bundle (iOS)** | com.plainos.kashmirshaivism |
| **Version** | 0.1.0 |
| **Firebase Project** | NEW (separate from Learning Hub) |

### Separate from Learning Hub

| Aspect | Learning Hub | Kashmir Shaivism |
|--------|--------------|------------------|
| Package | com.biohackerjoe.learninghub | com.plainos.kashmirshaivism |
| Firebase | learning-hub-9602f | NEW PROJECT |
| Content | Multi-topic | Kashmir Shaivism only |
| Users | Separate | Separate |
| Data | Separate | Separate |

## 🎯 Commands Summary

```bash
# Android release APK
chmod +x build_universal_apk.sh
./build_universal_apk.sh
adb install -r ~/Desktop/LearningHubKS-v0.1.0.apk

# Android app bundle for Play Store
flutter build appbundle --release

# iOS build helper
./build_ios.sh

# macOS build helper
./build_macos.sh
```

You're ready to ship or sideload builds with Firebase features intact.

