# iOS Build Guide - Learning Kashmir Shaivism

Complete guide for building and distributing your Flutter app on iOS.

## 📱 Prerequisites

### 1. Hardware & Software
- ✅ Mac computer (required for iOS builds)
- ✅ Xcode installed (latest version recommended)
- ✅ CocoaPods installed
- ✅ Flutter SDK installed

### 2. Apple Developer Account
- 💰 **$99/year** Apple Developer Program membership
- 📧 Sign up at: https://developer.apple.com/programs/

### 3. Install Required Tools

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods

# Verify installation
pod --version
flutter doctor
```

## 🔧 Setup

### 1. Configure Xcode

```bash
# Open project in Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Runner in project navigator
# 2. Select "Signing & Capabilities" tab
# 3. Select your Team from dropdown
# 4. Xcode will automatically create provisioning profiles
```

### 2. Update Bundle Identifier

Your current bundle ID: `com.biohackerjoe.learninghubks`

To change it:
1. Open `ios/Runner.xcodeproj` in Xcode
2. Select Runner target
3. Update Bundle Identifier in General tab
4. Make sure it matches your Apple Developer account

### 3. Update App Display Name

Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Learning Kashmir Shaivism</string>
```

## 🚀 Build Options

### Option 1: Quick Build Script (Recommended)

```bash
# Make executable
chmod +x build_ios.sh

# Run interactive build
./build_ios.sh

# Select from menu:
# 1. Build for testing (no codesign)
# 2. Build IPA for App Store
# 3. Build IPA for Ad Hoc distribution
# 4. Open in Xcode
```

### Option 2: Manual Flutter Commands

#### A. Build for Testing (No Signing Required)

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Build without code signing
flutter build ios --release --no-codesign

# Output: build/ios/iphoneos/Runner.app
```

#### B. Build IPA for App Store

```bash
# Build App Store IPA
flutter build ipa --release --export-method app-store

# Output: build/ios/ipa/learning_hub.ipa
```

#### C. Build IPA for Ad Hoc Testing

```bash
# Build Ad Hoc IPA
flutter build ipa --release --export-method ad-hoc

# Output: build/ios/ipa/learning_hub.ipa
```

#### D. Build for Development

```bash
# Build development version
flutter build ios --debug

# Or run directly on device
flutter run -d "Your iPhone Name"
```

## 📦 Distribution Methods

### 1. App Store Distribution

**Steps:**

1. **Build IPA:**
```bash
flutter build ipa --release --export-method app-store
```

2. **Create App Store Connect Listing:**
   - Go to https://appstoreconnect.apple.com
   - Click "My Apps" → "+" → "New App"
   - Fill in app information:
     - Name: Learning Kashmir Shaivism
     - Bundle ID: com.biohackerjoe.learninghubks
     - Category: Education
     - Version: 0.1.0

3. **Upload IPA:**

```bash
# Method 1: Using altool
xcrun altool --upload-app \
  --file build/ios/ipa/learning_hub.ipa \
  --type ios \
  --username your@email.com \
  --password your-app-specific-password

# Method 2: Using Xcode Organizer
open ios/Runner.xcworkspace
# Product → Archive
# Window → Organizer
# Upload to App Store

# Method 3: Using Transporter app
# Download from Mac App Store
# Drag IPA file to Transporter
```

4. **Submit for Review:**
   - Add screenshots (required sizes: 6.5", 5.5")
   - Write app description
   - Add keywords
   - Submit for review (1-3 days)

### 2. TestFlight (Beta Testing)

**Benefits:**
- ✅ Easy distribution to testers
- ✅ Up to 10,000 external testers
- ✅ Automatic updates
- ✅ Crash reports

**Steps:**

1. Upload to App Store Connect (same as above)
2. Go to TestFlight tab
3. Add testers by email
4. Testers receive invite via TestFlight app

### 3. Ad Hoc Distribution

For direct installation on specific devices (up to 100).

**Steps:**

1. **Register Device UDIDs:**
   - Get device UDID: Connect iPhone → Finder → Click on device name
   - Add to Apple Developer: Certificates → Devices → "+"

2. **Build Ad Hoc IPA:**
```bash
flutter build ipa --release --export-method ad-hoc
```

3. **Distribute:**
   - Share IPA file with testers
   - Install via Apple Configurator 2
   - Or use diawi.com for easier distribution

### 4. Enterprise Distribution

For internal company distribution (requires Apple Developer Enterprise Program - $299/year).

## 🔐 Code Signing

### Certificates Needed

1. **Development Certificate**
   - For testing on physical devices
   - Create: Xcode → Preferences → Accounts → Manage Certificates

2. **Distribution Certificate**
   - For App Store and Ad Hoc
   - Create: developer.apple.com → Certificates → "+"

### Provisioning Profiles

Xcode can automatically manage these, or create manually:

1. Go to developer.apple.com
2. Certificates → Profiles → "+"
3. Select type:
   - iOS App Development
   - App Store Distribution
   - Ad Hoc Distribution
4. Download and double-click to install

### Troubleshooting Signing Issues

```bash
# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean Flutter build
flutter clean

# Reinstall pods
cd ios
pod deintegrate
pod install
cd ..

# Open in Xcode and verify signing
open ios/Runner.xcworkspace
```

## 📸 App Store Requirements

### Screenshots
Required sizes:
- **6.5" Display** (iPhone 14 Pro Max, etc): 1290 x 2796 px
- **5.5" Display** (iPhone 8 Plus, etc): 1242 x 2208 px

Take screenshots:
```bash
# Run on simulator
flutter run -d "iPhone 14 Pro Max"

# Press: Cmd + S to save screenshot
# Or: xcrun simctl io booted screenshot screenshot.png
```

### App Store Assets
- App Icon: 1024x1024 (already in assets/data/LearninghubLogo.png)
- App Preview Video (optional): 15-30 seconds
- Description: Max 4000 characters
- Keywords: Max 100 characters
- Support URL: Required
- Privacy Policy URL: Required

## 🧪 Testing

### Test on Simulator

```bash
# List available simulators
flutter devices

# Run on specific simulator
flutter run -d "iPhone 14 Pro"
flutter run -d "iPad Air"
```

### Test on Physical Device

```bash
# Connect iPhone via USB
# Enable Developer Mode: Settings → Privacy & Security → Developer Mode

# List devices
flutter devices

# Run on device
flutter run -d "Your iPhone Name"

# Install release build
flutter install --release
```

## 🔄 Update Process

### For New Versions:

1. **Update version in config:**
```bash
# Edit assets/data/app_config.json
{
  "app": {
    "version": "0.2.0",
    "versionCode": "2",
    "buildNumber": "2"
  }
}

# Sync config
./sync_app_config.sh
```

2. **Build new IPA:**
```bash
flutter build ipa --release
```

3. **Upload to App Store Connect**

4. **Submit for review**

## 📋 Checklist

### Pre-Build
- [ ] Update version in app_config.json
- [ ] Update screenshots if UI changed
- [ ] Test on multiple devices/simulators
- [ ] Verify all features work offline
- [ ] Check Firebase configuration

### App Store Submission
- [ ] Build number incremented
- [ ] App Store Connect listing complete
- [ ] Screenshots uploaded (all required sizes)
- [ ] App icon 1024x1024
- [ ] Privacy policy URL added
- [ ] Support URL added
- [ ] Keywords optimized
- [ ] Description compelling
- [ ] Age rating appropriate
- [ ] Pricing set

### Post-Submission
- [ ] Monitor review status
- [ ] Respond to review feedback
- [ ] Test TestFlight builds
- [ ] Prepare marketing materials
- [ ] Plan for user feedback

## 🐛 Common Issues

### 1. "No valid code signing identity"
**Fix:** Open Xcode → Signing & Capabilities → Select Team

### 2. "Provisioning profile doesn't include signing certificate"
**Fix:** Xcode → Preferences → Accounts → Download Manual Profiles

### 3. "Unable to install pod"
**Fix:**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### 4. "App crashes on launch"
**Fix:** Check Firebase configuration in `ios/Runner/GoogleService-Info.plist`

### 5. "Archive build fails"
**Fix:**
```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter build ios --release
```

## 📞 Resources

- **Apple Developer:** https://developer.apple.com
- **App Store Connect:** https://appstoreconnect.apple.com
- **Flutter iOS Docs:** https://docs.flutter.dev/deployment/ios
- **TestFlight:** https://developer.apple.com/testflight/
- **Human Interface Guidelines:** https://developer.apple.com/design/

## 🎯 Quick Reference

```bash
# Full build cycle
chmod +x build_ios.sh
./build_ios.sh

# Or manual commands:
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release --export-method app-store

# Output location:
# build/ios/ipa/learning_hub.ipa

# Upload to App Store:
# Use Xcode Organizer or Transporter app
```

---

**Good luck with your iOS app launch! 🚀**

*Last Updated: 2025*
*For Learning Kashmir Shaivism v0.1.0*

