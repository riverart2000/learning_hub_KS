# Update Firebase Package Name

## 🔥 Firebase Console Update Required

Since you changed the package name from `com.biohackerjoe.learninghub` to `com.biohackerjoe.learninghubks`, you need to update Firebase.

## ⚠️ Important Note

I've temporarily updated `google-services.json` with the new package name so the build will work. However, **Firebase won't work properly** until you update it in the Firebase Console.

## 🔧 Proper Firebase Setup

### Option 1: Add New Android App (Recommended)

1. **Go to Firebase Console:**
   - https://console.firebase.google.com
   - Select project: `learning-hub-9602f`

2. **Add New Android App:**
   - Click ⚙️ (Settings) → Project Settings
   - Scroll to "Your apps"
   - Click "Add app" → Select Android
   - Enter package name: `com.biohackerjoe.learninghubks`
   - Click "Register app"

3. **Download New google-services.json:**
   - Download the new `google-services.json`
   - Replace `/Users/riverart/flutter/learning_hub_KS/android/app/google-services.json`

4. **Keep Old App (Optional):**
   - You can keep the old package registered
   - Or delete it if no longer needed

### Option 2: Use the Same Firebase App

Alternatively, you can revert the package name back to `com.biohackerjoe.learninghub` and keep using the existing Firebase configuration.

## 🎯 Current Configuration

### Android App Details:
- **Package Name:** `com.biohackerjoe.learninghubks` (NEW)
- **Firebase Project:** `learning-hub-9602f`
- **Project Number:** `64060012863`

### Firebase Services Used:
- ✅ Authentication
- ✅ Cloud Firestore
- ✅ Analytics

## 📋 Checklist After Firebase Update

- [ ] New Android app added in Firebase Console
- [ ] google-services.json downloaded and replaced
- [ ] Build runs successfully
- [ ] Firebase Authentication works
- [ ] Cloud Firestore read/write works
- [ ] Analytics events appear in Firebase Console

## 🚀 Quick Build After Firebase Update

```bash
# Clean build
flutter clean

# Build APK
./build_universal_apk.sh

# Test Firebase features:
# - Sign in/Sign out
# - Save progress to Firestore
# - Check Analytics in Firebase Console
```

## ⚡ For Now (Testing Without Firebase)

If you want to build and test without Firebase working:

1. The current build should complete now
2. App will install but Firebase features won't work
3. Update Firebase Console when ready

---

**Need Help?** 
- Firebase Console: https://console.firebase.google.com
- Firebase Android Setup: https://firebase.google.com/docs/android/setup

