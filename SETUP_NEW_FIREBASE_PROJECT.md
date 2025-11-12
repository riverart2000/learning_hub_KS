# Setup New Firebase Project for Learning Kashmir Shaivism

Since this is a **completely separate app** from Learning Hub, you need a new Firebase project.

## 🔥 Create New Firebase Project

### Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **"Add project"** or **"Create a project"**
3. Project name: **"Learning Kashmir Shaivism"**
4. Project ID: Will be auto-generated (e.g., `learning-kashmir-shaivism-xxxxx`)
5. Enable Google Analytics: **Yes** (recommended)
6. Click **"Create project"**

### Step 2: Add Android App

1. In your new Firebase project, click **"Add app"** → Android icon
2. Enter details:
   - **Package name:** `com.plainos.kashmirshaivism`
   - **App nickname:** Learning Kashmir Shaivism (Android)
   - **SHA-1:** (Optional for now, can add later)
3. Click **"Register app"**
4. **Download `google-services.json`**
5. **Replace** the file at:
   ```
   /Users/riverart/flutter/learning_hub_KS/android/app/google-services.json
   ```
6. Click **"Next"** through the remaining steps

### Step 3: Add iOS App

1. In Firebase Console, click **"Add app"** → iOS icon
2. Enter details:
   - **Bundle ID:** `com.plainos.kashmirshaivism`
   - **App nickname:** Learning Kashmir Shaivism (iOS)
3. Click **"Register app"**
4. **Download `GoogleService-Info.plist`**
5. **Add to Xcode project:**
   ```bash
   # Copy to iOS project
   cp ~/Downloads/GoogleService-Info.plist ios/Runner/
   
   # Then open in Xcode and add to target
   open ios/Runner.xcworkspace
   # File → Add Files to "Runner"
   # Select GoogleService-Info.plist
   # ✓ Copy items if needed
   # ✓ Add to targets: Runner
   ```

### Step 4: Setup Firestore Database

1. In Firebase Console → **Build** → **Firestore Database**
2. Click **"Create database"**
3. Choose location: **us-central** (or your region)
4. Start in **test mode** (allows read/write for 30 days)
5. Click **"Enable"**

### Step 5: Configure Firestore Rules

Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents - users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User progress - users can manage their own progress
    match /userProgress/{progressId} {
      allow read, write: if request.auth != null;
    }
    
    // Quiz attempts - users can manage their attempts
    match /quizAttempts/{attemptId} {
      allow read, write: if request.auth != null;
    }
    
    // Leaderboard - read for authenticated users
    match /leaderboard/{entry} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null;
    }
  }
}
```

### Step 6: Enable Authentication

1. Firebase Console → **Build** → **Authentication**
2. Click **"Get started"**
3. Enable providers:
   - ✅ **Email/Password** (click Enable)
   - ✅ **Google** (optional)
4. Click **"Save"**

### Step 7: Enable Analytics (Optional)

1. Firebase Console → **Analytics** → **Events**
2. Analytics is automatically enabled if you opted in during project creation

## 🔑 Update Bundle/Package IDs

Since this is a separate app, update the bundle IDs:

### iOS Bundle ID
Edit `ios/Runner.xcodeproj` in Xcode:
1. Open: `open ios/Runner.xcworkspace`
2. Select **Runner** in left sidebar
3. Select **Runner** target
4. **General** tab → **Bundle Identifier**
5. Change to: `com.plainos.kashmirshaivism`

### macOS Bundle ID
Edit `macos/Runner/Configs/AppInfo.xcconfig`:
```
PRODUCT_BUNDLE_IDENTIFIER = com.plainos.kashmirshaivism
```

## 📊 Project Comparison

| Aspect | Learning Hub (Original) | Learning Kashmir Shaivism (New) |
|--------|------------------------|----------------------------------|
| **Firebase Project** | learning-hub-9602f | NEW PROJECT NEEDED |
| **Android Package** | com.biohackerjoe.learninghub | com.plainos.kashmirshaivism ✅ |
| **iOS Bundle** | com.biohackerjoe.learninghub | com.plainos.kashmirshaivism |
| **Content** | General learning | Kashmir Shaivism only |
| **Purpose** | Multi-topic learning | Dedicated spiritual study |

## ⚠️ Firebase Is Required

The production build assumes Firebase is configured. Skipping the Firebase setup steps above will compile the app, but authentication, sync, and analytics will all fail. Configure Firebase first, then use the build commands below.

## ✅ Quick Setup Checklist

- [ ] Created new Firebase project
- [ ] Added Android app with package: `com.plainos.kashmirshaivism`
- [ ] Downloaded and replaced `google-services.json`
- [ ] Added iOS app with bundle: `com.plainos.kashmirshaivism`
- [ ] Downloaded and added `GoogleService-Info.plist`
- [ ] Enabled Firestore Database
- [ ] Configured Firestore security rules
- [ ] Enabled Email/Password authentication
- [ ] Updated iOS Bundle ID in Xcode
- [ ] Updated macOS Bundle ID in AppInfo.xcconfig

## 🚀 After Firebase Setup

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Build for Android
./build_universal_apk.sh

# Build for iOS
./build_ios.sh

# Build for macOS
flutter build macos --release
```

---

**This is a brand new app!** Treat it as a fresh Firebase project separate from Learning Hub.

