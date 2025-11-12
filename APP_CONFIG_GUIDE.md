# App Configuration Guide

All app metadata (title, author, version, etc.) is now centralized in a single JSON file for easy updates!

## 📄 Configuration File

**Location:** `assets/data/app_config.json`

## 🎯 How to Update App Info

### Quick Update (5 minutes)

1. **Open** `assets/data/app_config.json`
2. **Edit** the values you want to change
3. **Save** the file
4. **Rebuild** your app

That's it! All screens will automatically use the new values.

## 📝 Configuration Structure

```json
{
  "app": {
    "name": "Learning Hub",              // App name shown everywhere
    "tagline": "Your tagline here",      // Subtitle on welcome screen
    "subtitle": "DevOps",                // Subtitle in header
    "version": "1.0.0",                  // Version number
    "description": "Your app description" // About section description
  },
  "developer": {
    "name": "Your Name",                 // Developer name in settings
    "email": "your@email.com",           // Contact email
    "organization": "Your Company"       // Organization name
  },
  "legal": {
    "copyright": "© 2025 Your App",      // Copyright notice
    "privacyNote": "Privacy message"     // Privacy statement
  },
  "welcome": {
    "title": "Welcome message",          // Welcome screen title
    "subtitle": "Tagline",               // Welcome subtitle
    "signInPrompt": "Sign in text",      // Login prompt
    "termsText": "Terms text"            // Terms & conditions
  },
  "home": {
    "welcomePrefix": "Welcome, ",        // Before username
    "categoriesTitle": "Categories"      // Categories section title
  }
}
```

## 🔧 Where Each Value Appears

### App Section
- **app.name**: 
  - Main app title bar
  - Settings screen (About section)
  - Welcome screen
  
- **app.tagline**: 
  - Welcome screen subtitle
  
- **app.subtitle**: 
  - Header subtitle (currently shows "DevOps")
  
- **app.version**: 
  - Settings screen (About section)
  
- **app.description**: 
  - Settings screen (About section)

### Developer Section
- **developer.name**: 
  - Settings → Developer → "Developed by"
  
- **developer.email**: 
  - Settings → Developer → "Contact"
  
- **developer.organization**: 
  - Available for future use

### Legal Section
- **legal.copyright**: 
  - Settings screen footer
  
- **legal.privacyNote**: 
  - Settings → Privacy & Data

### Welcome Section
- **welcome.title**: 
  - Welcome/login screen main title
  
- **welcome.subtitle**: 
  - Welcome screen tagline
  
- **welcome.signInPrompt**: 
  - "Sign in to Continue" text
  
- **welcome.termsText**: 
  - Terms and privacy text at bottom

### Home Section
- **home.welcomePrefix**: 
  - "Welcome, " before user's name
  
- **home.categoriesTitle**: 
  - Categories section heading

## 💡 Example: Rebranding Your App

Want to change from "Learning Hub" to "My Awesome App"? Just update the JSON:

```json
{
  "app": {
    "name": "My Awesome App",
    "tagline": "Learn anything, anytime",
    "subtitle": "Mathematics",
    "version": "2.0.0",
    "description": "Your comprehensive math learning platform"
  },
  "developer": {
    "name": "Your Company Name",
    "email": "support@yourcompany.com",
    "organization": "Your Company"
  },
  "legal": {
    "copyright": "© 2025 My Awesome App. All rights reserved.",
    "privacyNote": "We respect your privacy. All data stays on your device."
  }
}
```

Save, rebuild, and your entire app is rebranded! 🎉

## 🚀 No Code Changes Required!

**Before:** You had to edit 5+ files to change the app name.

**Now:** Edit 1 JSON file, everything updates automatically!

## 🛠️ Technical Details

### Service Used
`AppConfigService` (in `lib/services/app_config_service.dart`)

### Loading
Config is loaded during app startup in `main.dart`:
```dart
await AppConfigService.loadConfig();
```

### Usage in Code
```dart
Text(AppConfigService.appName)
Text(AppConfigService.developerEmail)
Text(AppConfigService.copyright)
```

### Fallback
If the JSON file is missing or invalid, the service uses hardcoded defaults to prevent crashes.

## 📋 Checklist for Updating

- [ ] Open `assets/data/app_config.json`
- [ ] Update app name
- [ ] Update version number
- [ ] Update developer info
- [ ] Update copyright year
- [ ] Update descriptions/taglines
- [ ] Save file
- [ ] Test app to verify changes
- [ ] Rebuild for production

## 🎯 Benefits

✅ **Single source of truth** - One file to update
✅ **Easy rebranding** - Change name/info everywhere at once
✅ **No code changes** - Just edit JSON
✅ **Safe fallbacks** - App won't crash if file is invalid
✅ **Clean separation** - Config separate from code
✅ **Easy versioning** - Track changes in git

---

**Now you can rebrand your app in minutes, not hours!** 🚀








