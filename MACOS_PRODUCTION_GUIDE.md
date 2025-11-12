# macOS Production Build Guide - Learning Hub

## 🖥️ Preparing for macOS App Store and Direct Distribution

### 1. **Current Status** ✅
- ✅ macOS platform enabled in Flutter
- ✅ macOS project files generated
- ✅ App bundle identifier configured
- ✅ Ready for macOS-specific configuration

### 2. **macOS Development Requirements** 🔧

#### Install Xcode (if not already installed):
```bash
# Install Xcode from App Store or Apple Developer Portal
# Then configure command line tools:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

#### Install CocoaPods:
```bash
# Option 1: Using Homebrew (recommended)
brew install cocoapods

# Option 2: Using RubyGems (if Homebrew not available)
sudo gem install cocoapods

# Verify installation
pod --version
```

#### Verify Setup:
```bash
flutter doctor -v
```

### 3. **macOS App Configuration** ⚙️

#### Update App Information:
```bash
# The following files are already configured:
# - macos/Runner/Configs/AppInfo.xcconfig
# - macos/Runner/Info.plist
```

#### Configure App Icons:
```bash
# Copy your logo to macOS app icons
# Replace icons in: macos/Runner/Assets.xcassets/AppIcon.appiconset/
# Required sizes: 16, 32, 64, 128, 256, 512, 1024
```

#### Set Minimum macOS Version:
```bash
# Edit macos/Runner/Configs/AppInfo.xcconfig
MACOSX_DEPLOYMENT_TARGET = 10.14  # macOS Mojave or later
```

### 4. **macOS App Store Distribution** 🏪

#### Apple Developer Account Setup:
1. **Enroll in Apple Developer Program** ($99/year)
2. **Create App ID** in Apple Developer Console
3. **Configure App Store Connect** for app listing

#### App Store Requirements:
- **App Name**: Learning Hub - Biohacker Joe
- **Bundle ID**: com.biohackerjoe.learninghub
- **Category**: Education
- **Content Rating**: 4+ (Everyone)
- **Screenshots**: Required for different screen sizes

#### Code Signing:
```bash
# Create Developer ID Application certificate
# 1. Open Keychain Access
# 2. Request certificate from Apple
# 3. Download and install certificate
# 4. Configure in Xcode project
```

### 5. **Direct Distribution (Outside App Store)** 📦

#### Create Developer ID Application:
```bash
# 1. Create Developer ID Application certificate
# 2. Create installer package
# 3. Notarize with Apple
# 4. Distribute via website or direct download
```

#### Build for Direct Distribution:
```bash
# Build macOS app
flutter build macos --release

# Output: build/macos/Build/Products/Release/Learning Hub.app
```

### 6. **Build Release Version** 🚀

#### Update Version:
```bash
# Update version in pubspec.yaml
version: 1.0.0+1  # Format: version_name+version_code
```

#### Build Release App:
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build release app
flutter build macos --release

# Output: build/macos/Build/Products/Release/Learning Hub.app
```

#### Create DMG Installer:
```bash
# Install create-dmg (optional)
brew install create-dmg

# Create DMG installer
create-dmg \
  --volname "Learning Hub" \
  --volicon "assets/data/LearninghubLogo.png" \
  --window-pos 200 120 \
  --window-size 600 300 \
  --icon-size 100 \
  --icon "Learning Hub.app" 175 120 \
  --hide-extension "Learning Hub.app" \
  --app-drop-link 425 120 \
  "Learning Hub-1.0.0.dmg" \
  "build/macos/Build/Products/Release/"
```

### 7. **macOS-Specific Features** 🍎

#### Menu Bar Integration:
```dart
// Add to main.dart for macOS-specific features
import 'dart:io';

void main() {
  if (Platform.isMacOS) {
    // macOS-specific initialization
  }
  runApp(MyApp());
}
```

#### Window Management:
```swift
// Customize in macos/Runner/MainFlutterWindow.swift
class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    // Set minimum window size
    self.minSize = NSSize(width: 800, height: 600)
    
    // Set initial window size
    self.setContentSize(NSSize(width: 1200, height: 800))
    
    // Center window
    self.center()
  }
}
```

### 8. **Pre-Release Checklist** ✅

#### App Store Listing:
- [ ] App name and description
- [ ] Screenshots (various screen sizes)
- [ ] App icon (1024x1024px)
- [ ] Privacy policy URL
- [ ] Content rating questionnaire
- [ ] App Store review information

#### Technical Requirements:
- [ ] App signed with Developer ID
- [ ] Minimum macOS version 10.14
- [ ] 64-bit architecture support
- [ ] No debug information
- [ ] Firebase configuration for production
- [ ] App notarized (for direct distribution)

#### Testing:
- [ ] Test on multiple macOS versions
- [ ] Test on Intel and Apple Silicon Macs
- [ ] Test offline functionality
- [ ] Test Firebase features
- [ ] Test quiz/flashcard functionality
- [ ] Test leaderboard and confetti
- [ ] Test window resizing and fullscreen

### 9. **Distribution Options** 📤

#### Option A: Mac App Store
1. **Create App Store Connect** listing
2. **Upload app** using Xcode or Application Loader
3. **Submit for review** (takes 1-7 days)
4. **Publish** when approved

#### Option B: Direct Distribution
1. **Build and sign** app with Developer ID
2. **Notarize** with Apple
3. **Create DMG** installer
4. **Distribute** via website or direct download

### 10. **Post-Launch** 🎉

#### Monitor:
- Crash reports in App Store Connect
- User reviews and ratings
- Download statistics
- Firebase Analytics

#### Updates:
- Use `flutter build macos --release` for updates
- Increment version number in pubspec.yaml
- Upload new build to App Store Connect

---

## 🔧 Quick Commands Reference

```bash
# Check setup
flutter doctor -v

# Clean and build
flutter clean && flutter pub get

# Build release
flutter build macos --release

# Run on macOS
flutter run -d macos

# Install CocoaPods dependencies
cd macos && pod install && cd ..
```

---

## 📞 Support

If you encounter issues:
1. Check Flutter macOS documentation
2. Review Apple Developer documentation
3. Test on physical Mac devices
4. Monitor Firebase console for errors

**Good luck with your macOS app launch! 🚀**
