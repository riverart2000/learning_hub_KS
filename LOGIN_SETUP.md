# Login Setup Guide

This app supports two login methods:
1. **Facebook Login** via `flutter_facebook_auth`
2. **Manual Email/Name** entry

## Installation

Run the following command to install the dependencies:

```bash
flutter pub get
```

---

## Facebook Login Setup

### Step 1: Create Facebook App

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or use an existing one
3. Get your **App ID** (you'll need this for configuration)

---

### Step 2: Android Configuration

#### 2.1 Generate Key Hash

Run this command in your terminal:

```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android | openssl sha1 -binary | openssl base64
```

**Your generated key hash:** `e/wWXNjQurk5S5P0EkZaIvjcMps=`

#### 2.2 Add Key Hash to Facebook

1. Go to your Facebook app at https://developers.facebook.com/apps/YOUR_APP_ID/settings/basic/
2. Click "Add Platform" → Select "Android"
3. Add:
   - **Package Name**: `com.example.learning_hub` (or your actual package name)
   - **Class Name**: `com.example.learning_hub.MainActivity`
   - **Key Hashes**: Paste your generated hash (e.g., `e/wWXNjQurk5S5P0EkZaIvjcMps=`)
4. Save changes

#### 2.3 Configure Android Files

The following files have already been configured for you:

**`android/app/src/main/AndroidManifest.xml`** - Contains:
- Facebook App ID metadata
- Facebook Activity declarations
- Internet permission

**`android/app/src/main/res/values/strings.xml`** - Contains:
```xml
<string name="facebook_app_id">313510345870536</string>
<string name="fb_login_protocol_scheme">fb313510345870536</string>
```

✅ **Your Facebook App ID (313510345870536) is already configured!**

---

### Step 3: iOS Configuration (Optional)

If you want to support iOS:

1. Add to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fb313510345870536</string>
    </array>
  </dict>
</array>

<key>FacebookAppID</key>
<string>313510345870536</string>
<key>FacebookDisplayName</key>
<string>Learning Hub</string>

<key>LSApplicationQueriesSchemes</key>
<array>
  <string>fbapi</string>
  <string>fb-messenger-share-api</string>
</array>
```

---

### Step 4: Web Configuration (Optional)

If you want to support Web:

1. Add to `web/index.html` before `</body>`:

```html
<script async defer crossorigin="anonymous" 
  src="https://connect.facebook.net/en_US/sdk.js"></script>

<script>
  window.fbAsyncInit = function() {
    FB.init({
      appId      : '313510345870536',
      cookie     : true,
      xfbml      : true,
      version    : 'v12.0'
    });
  };
</script>
```

---

## Manual Email/Name Login

This is already implemented and requires no additional setup!

Users can simply:
1. Enter their full name
2. Enter a valid email address
3. Click "Get Started"

The app validates:
- ✅ Name is not empty
- ✅ Email format is valid

---

## Testing

### Test Facebook Login

1. Run your app:
   ```bash
   flutter run
   ```

2. Click "Continue with Facebook"
3. Log in with your Facebook account
4. Grant permissions
5. You should be logged in! 🎉

### Test Email Login

1. Run your app
2. Enter your name and email
3. Click "Get Started"
4. You should be logged in! 🎉

---

## Production Considerations

### For Release Builds

When building for production, generate a **release key hash**:

1. First, create a release keystore if you haven't:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Generate the release key hash:
   ```bash
   keytool -exportcert -alias upload -keystore ~/upload-keystore.jks | openssl sha1 -binary | openssl base64
   ```

3. Add the release key hash to Facebook Developer Console

### Facebook App Review

For production apps:
1. Your Facebook app needs to be in "Live" mode (not "Development")
2. You may need to submit for App Review for certain permissions
3. Add your privacy policy URL in Facebook settings

---

## Troubleshooting

### Facebook Login Not Working

1. **Check App ID**: Make sure `313510345870536` is your correct App ID
2. **Check Key Hash**: Verify the key hash is added to Facebook console
3. **Check Package Name**: Ensure it matches in Facebook settings and `build.gradle.kts`
4. **Check Facebook App Mode**: Make sure it's in "Development" mode for testing

### Email Validation Fails

The app uses regex pattern: `r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'`

Valid examples:
- ✅ `user@example.com`
- ✅ `john.doe@company.co.uk`
- ❌ `invalid@email` (missing TLD)
- ❌ `@example.com` (missing username)

---

## Security Notes

⚠️ **Important Security Considerations:**

1. **Never commit** Facebook App Secret to version control
2. For production apps, store sensitive data in environment variables
3. Implement proper backend authentication for production use
4. The current implementation stores user data locally - consider server-side storage for production

---

## Support

For more information:
- [Facebook Login for Android](https://developers.facebook.com/docs/facebook-login/android)
- [flutter_facebook_auth Package](https://pub.dev/packages/flutter_facebook_auth)
- [Firebase Authentication](https://firebase.google.com/docs/auth) (for future enhancements)

---

## Summary

✅ **What's Configured:**
- Facebook App ID: `313510345870536`
- Debug Key Hash: `e/wWXNjQurk5S5P0EkZaIvjcMps=`
- Android configuration files
- Email/name login

🔧 **What You Need to Do:**
1. Add key hash to Facebook Developer Console
2. Add package name to Facebook settings
3. Test the login flow

That's it! Your login system is ready to use. 🎉
