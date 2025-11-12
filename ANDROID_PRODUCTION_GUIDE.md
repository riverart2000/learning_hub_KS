# Android Production Build Guide - Learning Hub

## 📱 Preparing for Google Play Store Release

### 1. **Current Status** ✅
- ✅ Git snapshot created (commit: 4dc6497)
- ✅ App icons generated for all platforms
- ✅ Firebase configured with proper security rules
- ✅ All features implemented and tested

### 2. **Android Build Requirements** 🔧

#### Install Android Command Line Tools:
```bash
# Download Android Command Line Tools
# Go to: https://developer.android.com/studio#command-line-tools-only
# Extract to: ~/Library/Android/sdk/cmdline-tools/latest/

# Set environment variables (add to ~/.zshrc or ~/.bash_profile):
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Reload shell
source ~/.zshrc

# Accept licenses
flutter doctor --android-licenses
```

#### Verify Setup:
```bash
flutter doctor -v
```

### 3. **App Signing Configuration** 🔐

#### Generate Keystore:
```bash
# Navigate to android/app directory
cd android/app

# Generate release keystore
keytool -genkey -v -keystore learning-hub-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias learning-hub-key

# Follow prompts:
# - Enter keystore password: [YOUR_PASSWORD]
# - Re-enter password: [YOUR_PASSWORD]
# - What is your first and last name? [YOUR_NAME]
# - What is the name of your organizational unit? [YOUR_ORG]
# - What is the name of your organization? [YOUR_COMPANY]
# - What is the name of your City or Locality? [YOUR_CITY]
# - What is the name of your State or Province? [YOUR_STATE]
# - What is the two-letter country code for this unit? [US]
# - Is CN=[YOUR_NAME], OU=[YOUR_ORG], O=[YOUR_COMPANY], L=[YOUR_CITY], ST=[YOUR_STATE], C=[US] correct? [yes]
# - Enter key password for <learning-hub-key>: [YOUR_KEY_PASSWORD]
```

#### Create key.properties:
```bash
# Create android/key.properties
cat > android/key.properties << EOF
storePassword=[YOUR_KEYSTORE_PASSWORD]
keyPassword=[YOUR_KEY_PASSWORD]
keyAlias=learning-hub-key
storeFile=../app/learning-hub-release-key.keystore
EOF
```

#### Update build.gradle.kts:
```kotlin
// Add to android/app/build.gradle.kts (after line 1)
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing code ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 4. **Google Play Console Setup** 🏪

#### Create Google Play Developer Account:
1. Go to [Google Play Console](https://play.google.com/console)
2. Pay $25 one-time registration fee
3. Complete developer profile

#### App Information:
- **App Name**: Learning Hub - Biohacker Joe
- **Package Name**: com.example.learning_hub (or your custom package)
- **Category**: Education
- **Content Rating**: Everyone
- **Target Audience**: General audience

### 5. **Build Release Version** 🚀

#### Update Version:
```bash
# Update version in pubspec.yaml
version: 1.0.0+1  # Format: version_name+version_code
```

#### Build Release APK:
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

#### Output Files:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### 6. **Pre-Release Checklist** ✅

#### App Store Listing:
- [ ] App name and description
- [ ] Screenshots (phone, tablet)
- [ ] Feature graphic (1024x500px)
- [ ] App icon (512x512px)
- [ ] Privacy policy URL
- [ ] Content rating questionnaire

#### Technical Requirements:
- [ ] App signed with release keystore
- [ ] Target API level 34 (Android 14)
- [ ] 64-bit architecture support
- [ ] No debug information
- [ ] Firebase configuration for production

#### Testing:
- [ ] Test on multiple Android devices
- [ ] Test offline functionality
- [ ] Test Firebase features
- [ ] Test quiz/flashcard functionality
- [ ] Test leaderboard and confetti

### 7. **Upload to Play Store** 📤

1. **Create New App** in Google Play Console
2. **Upload AAB file** (app-release.aab)
3. **Complete store listing** with screenshots and description
4. **Submit for review** (takes 1-3 days)

### 8. **Post-Launch** 🎉

#### Monitor:
- Crash reports in Play Console
- User reviews and ratings
- Download statistics
- Firebase Analytics

#### Updates:
- Use `flutter build appbundle --release` for updates
- Increment version number in pubspec.yaml
- Upload new AAB to Play Console

---

## 🔧 Quick Commands Reference

```bash
# Check setup
flutter doctor -v

# Clean and build
flutter clean && flutter pub get

# Build release
flutter build appbundle --release

# Test release build
flutter install --release
```

---

## 📞 Support

If you encounter issues:
1. Check Flutter documentation
2. Review Google Play Console help
3. Test on physical devices
4. Monitor Firebase console for errors

**Good luck with your app launch! 🚀**
