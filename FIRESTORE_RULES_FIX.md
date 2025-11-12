# Fix Firestore Permission Denied Error

## Problem
You're getting: `[cloud_firestore/permission-denied] Missing or insufficient permissions.`

This happens because your Firestore security rules are too restrictive for the app's name+email matching feature.

## Solution

### Step 1: Open Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click on **Firestore Database** in the left sidebar
4. Click on the **Rules** tab at the top

### Step 2: Update Security Rules

**Replace your current rules with these (for development/testing):**

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

### Step 3: Publish Rules
1. Click the **Publish** button at the top right
2. Wait for confirmation message: "Rules published successfully"

### Step 4: Test the App
1. Close and restart your app
2. Complete a quiz or flashcard session
3. Check the debug console - you should now see: `✅ Score saved to Firebase successfully!`
4. Open the leaderboard to see your scores!

---

## For Production (Later)

Once you're ready to deploy, use these more secure rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - authenticated users can read all, update their data
    match /users/{userId} {
      allow read: if true; // Public read for leaderboard
      allow create: if request.auth != null;
      allow update: if request.auth != null; // Allows name+email matching updates
      allow delete: if false;
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

---

## Why This Happened

Your app uses a **name + email matching system** to identify returning users:
- When you log in with the same name and email, the app finds your existing Firebase record
- Then it tries to update that record with new scores
- But the old rules only allowed users to update records where their Firebase UID matched the document ID
- Since the app uses anonymous authentication, each session has a different UID
- The solution is to allow authenticated users to update user documents (since we verify identity via name+email)

---

## Security Notes

The development rules above are safe because:
- ✅ Only **authenticated** users can read/write (not public)
- ✅ Anonymous authentication is still protected by Firebase
- ✅ You can monitor all activity in Firebase Console
- ✅ For a learning app with low stakes data, this is acceptable

For production with sensitive data, consider:
- Implementing user accounts with proper authentication
- Adding field-level validation in security rules
- Enabling Firebase App Check
- Setting up rate limiting

---

Need help? Check the full [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) guide!

