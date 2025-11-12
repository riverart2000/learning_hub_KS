# Firebase Setup Guide

This app now integrates Firebase for:
- **User Authentication** - Secure user sign-in
- **Cloud Storage** - Store user scores and progress
- **Leaderboard** - Top 10 high scores
- **Feedback Storage** - User feedback with metadata

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. Firebase CLI (optional but recommended)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `learning-hub` (or your preferred name)
4. **Disable** Google Analytics (optional - you can enable it later)
5. Click "Create Project"

## Step 2: Configure Firebase for Your Platforms

### Web Configuration

1. In Firebase Console, click the **Web icon** (</>)
2. Register app with nickname: "Learning Hub Web"
3. Copy the Firebase configuration object
4. Create `web/firebase-config.js`:

```javascript
// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
```

5. Update `web/index.html` to include Firebase SDK (add before closing `</body>` tag):

```html
<!-- Firebase SDKs -->
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore-compat.js"></script>
<script src="firebase-config.js"></script>
```

### Android Configuration

1. In Firebase Console, click the **Android icon**
2. Register app:
   - Android package name: `com.example.learning_hub` (or your package name from `android/app/build.gradle.kts`)
   - App nickname: "Learning Hub Android"
   - Debug signing certificate (optional for now)
3. Download `google-services.json`
4. Place it in `android/app/` directory
5. Update `android/build.gradle.kts` (project level):

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

6. Update `android/app/build.gradle.kts`:

```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services")
}
```

### iOS Configuration

1. In Firebase Console, click the **iOS icon**
2. Register app:
   - iOS bundle ID: `com.example.learningHub` (from `ios/Runner/Info.plist`)
   - App nickname: "Learning Hub iOS"
3. Download `GoogleService-Info.plist`
4. **Using Xcode**:
   - Open `ios/Runner.xcworkspace`
   - Right-click on `Runner` folder
   - Select "Add Files to Runner"
   - Select downloaded `GoogleService-Info.plist`
   - Make sure "Copy items if needed" is checked
   - Click "Add"

### macOS Configuration

1. In Firebase Console, click **Add App** > **Apple**
2. Register app:
   - iOS bundle ID: `com.example.learningHub.macos` (from `macos/Runner/Info.plist`)
   - App nickname: "Learning Hub macOS"
3. Download `GoogleService-Info.plist`
4. Place it in `macos/Runner/` directory

## Step 3: Enable Firebase Services

### Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get Started"
3. Enable sign-in methods:
   - **Anonymous** - For guest users
   - **Email/Password** - For registered users
   - **Google** (optional)
   - **Facebook** (optional)

### Set up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Start in **Test mode** (for development)
   - Production mode requires security rules
4. Choose a location (closest to your users)
5. Click "Enable"

### Configure Security Rules (Important!)

**For Development (Permissive):**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all authenticated users to read/write (for testing)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**For Production (Recommended):**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - authenticated users can read all, write with restrictions
    match /users/{userId} {
      allow read: if true; // Allow read for leaderboard
      allow create: if request.auth != null; // Any authenticated user can create
      allow update: if request.auth != null; // Allow updates for name+email matching
      allow delete: if false; // Prevent deletion
    }
    
    // Scores collection - authenticated users can write
    match /scores/{scoreId} {
      allow read: if true; // Public read for leaderboard
      allow create: if request.auth != null;
      allow update, delete: if false; // Scores are immutable
    }
    
    // Feedback collection - authenticated users can create
    match /feedback/{feedbackId} {
      allow read: if false; // Only admins via Firebase Console
      allow create: if request.auth != null;
      allow update, delete: if false;
    }
  }
}
```

## Step 4: Install Firebase CLI (Optional)

Install Firebase CLI for easier management:

```bash
npm install -g firebase-tools
firebase login
firebase init
```

Select:
- Firestore
- Functions (optional)
- Hosting (if deploying web version)

## Step 5: Update Flutter Dependencies

Run:

```bash
flutter pub get
```

## Step 6: Test Firebase Connection

1. Run the app:
   ```bash
   flutter run
   ```

2. Check the console for:
   ```
   Firebase initialized successfully
   ```

3. If you see errors, Firebase will work in offline mode using Hive

## Features Enabled by Firebase

### 1. **Leaderboard** 🏆
- Top 10 global high scores
- Real-time updates
- See your rank
- Access via trophy icon on home screen

### 2. **Cloud Score Sync** ☁️
- Scores automatically sync to cloud
- Compete with users worldwide
- Never lose your progress

### 3. **Feedback System** 💬
- User feedback stored in Firebase
- View in Firebase Console under "feedback" collection
- Includes user info, timestamp, and platform

### 4. **Future Features** (Ready to implement)
- User profiles with avatars
- Friend system
- Achievements & badges
- Social sharing
- Push notifications

## Firestore Data Structure

### Users Collection
```
users/{firebaseUid}
  ├─ name: string
  ├─ email: string
  ├─ totalScore: number
  ├─ highScore: number
  ├─ createdAt: timestamp
  └─ updatedAt: timestamp
```

### Scores Collection
```
scores/{autoId}
  ├─ userId: string (local)
  ├─ firebaseUid: string
  ├─ userName: string
  ├─ score: number
  ├─ category: string
  ├─ difficulty: string
  └─ timestamp: timestamp
```

### Feedback Collection
```
feedback/{autoId}
  ├─ userId: string (local)
  ├─ firebaseUid: string (optional)
  ├─ userName: string
  ├─ feedback: string
  ├─ screenshotUrl: string (optional)
  ├─ platform: string
  ├─ timestamp: timestamp
  └─ status: string (pending/reviewed/resolved)
```

## Viewing Data in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **Firestore Database** to see all collections
4. Click **Authentication** to see registered users
5. Use the **Query** feature to filter and search data

## Troubleshooting

### "Firebase not configured" error
- The app will work offline using Hive storage
- Complete the setup steps above to enable cloud features

### "Permission denied" errors
- Check your Firestore security rules
- Make sure user is authenticated
- Verify the rules allow the operation

### Android build errors
- Make sure `google-services.json` is in `android/app/`
- Check that you added the Google Services plugin
- Run `flutter clean && flutter pub get`

### iOS build errors
- Verify `GoogleService-Info.plist` is added to Xcode project
- Check bundle ID matches Firebase configuration
- Clean build folder in Xcode

### Web not loading
- Check browser console for errors
- Verify Firebase SDK scripts are loaded
- Check API key and project ID in `firebase-config.js`

## Cost & Quotas

Firebase has generous **free tier** (Spark Plan):
- **Firestore**: 50K reads, 20K writes, 20K deletes per day
- **Authentication**: Unlimited
- **Storage**: 1 GB

For this app with moderate usage:
- ~100 users: **FREE**
- ~1000 users: ~$5-10/month
- ~10000 users: ~$25-50/month

## Security Best Practices

1. ✅ Never commit `google-services.json` or config files to public repos
2. ✅ Use environment variables for sensitive data
3. ✅ Enable App Check for production
4. ✅ Set up proper Firestore security rules
5. ✅ Enable Firebase Analytics for monitoring
6. ✅ Set up backup and export for Firestore data

## Next Steps

After Firebase is configured:

1. ✅ Test authentication by logging in
2. ✅ Complete a quiz to see score sync
3. ✅ Check leaderboard for your rank
4. ✅ Submit feedback and verify in Firebase Console
5. ✅ Monitor usage in Firebase Console

---

Need help? Check the [official Firebase documentation](https://firebase.google.com/docs) or open an issue in the repo!

