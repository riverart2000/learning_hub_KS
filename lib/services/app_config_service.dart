import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfigService {
  static Map<String, dynamic>? _config;
  static PackageInfo? _packageInfo;

  /// Load app configuration from JSON file
  static Future<void> loadConfig() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/app_config.json');
      _config = json.decode(jsonString);
    } catch (e) {
      // Fallback to defaults if config file is missing
      _config = _getDefaultConfig();
    }
    
    // Load package info for real version
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// Get app name
  static String get appName => _config?['app']?['name'] ?? 'Learning Hub KS';

  /// Get app display name
  static String get appDisplayName => _config?['app']?['displayName'] ?? appName;

  /// Get app package name
  static String get packageName => _config?['app']?['packageName'] ?? 'com.biohackerjoe.learninghub';

  /// Get app tagline
  static String get appTagline => _config?['app']?['tagline'] ?? 'Your personal learning companion';

  /// Get app subtitle
  static String get appSubtitle => _config?['app']?['subtitle'] ?? 'PlainOS';

  /// Get app version (from pubspec.yaml, fallback to config)
  static String get appVersion => _packageInfo?.version ?? _config?['app']?['version'] ?? '0.1.0';
  
  /// Get version code
  static String get versionCode => _config?['app']?['versionCode'] ?? '1';
  
  /// Get build number
  static String get buildNumber => _packageInfo?.buildNumber ?? _config?['app']?['buildNumber'] ?? '1';

  /// Get app category
  static String get category => _config?['app']?['category'] ?? 'Education';

  /// Get content rating
  static String get contentRating => _config?['app']?['contentRating'] ?? 'Everyone';

  /// Get app short description
  static String get appShortDescription => 
      _config?['app']?['shortDescription'] ?? 
      'Minimalist learning app for focus and speed.';

  /// Get app description
  static String get appDescription => 
      _config?['app']?['description'] ?? 
      'A comprehensive learning platform featuring interactive flashcards, quizzes, and progress tracking.';

  /// Get developer name
  static String get developerName => _config?['developer']?['name'] ?? 'PlainOS by Joe Bains';

  /// Get author name
  static String get author => _config?['developer']?['author'] ?? 'Joe Bains';

  /// Get developer email
  static String get developerEmail => _config?['developer']?['email'] ?? 'joebainsodds@gmail.com';

  /// Get support email
  static String get supportEmail => _config?['developer']?['supportEmail'] ?? developerEmail;

  /// Get organization
  static String get organization => _config?['developer']?['organization'] ?? 'PlainOS';

  /// Get developer website
  static String get website => _config?['developer']?['website'] ?? 'https://plainos.io';

  /// Get developer bio
  static String get developerBio => _config?['developer']?['bio'] ?? 'Biohacker and performance coach';

  /// Get copyright text
  static String get copyright => _config?['legal']?['copyright'] ?? '© 2025 PlainOS by Joe Bains. All rights reserved.';

  /// Get privacy note
  static String get privacyNote => _config?['legal']?['privacyNote'] ?? 'We only store your name, email, and scores in the cloud for sync. Everything else stays local on your device.';

  /// Get welcome screen title
  static String get welcomeTitle => _config?['welcome']?['title'] ?? 'Welcome to Learning Hub';

  /// Get welcome screen subtitle
  static String get welcomeSubtitle => _config?['welcome']?['subtitle'] ?? 'Your personal learning companion';

  /// Get sign in prompt
  static String get signInPrompt => _config?['welcome']?['signInPrompt'] ?? 'Sign in to Continue';

  /// Get terms text
  static String get termsText => 
      _config?['welcome']?['termsText'] ?? 
      'By continuing, you agree to our Terms of Service and Privacy Policy';

  /// Get home welcome prefix
  static String get homeWelcomePrefix => _config?['home']?['welcomePrefix'] ?? 'Welcome, ';

  /// Get home categories title
  static String get homeCategoriesTitle => 
      _config?['home']?['categoriesTitle'] ?? 
      'Categories';

  /// Get full app info string for displays
  static String get fullAppInfo => '$appDisplayName v$appVersion ($buildNumber)';

  /// Get full developer info
  static String get fullDeveloperInfo => '$developerName\n$supportEmail\n$website';

  /// Platform-specific getters
  static int get minSdkVersion => _config?['app']?['platform']?['minSdkVersion'] ?? 21;
  static int get targetSdkVersion => _config?['app']?['platform']?['targetSdkVersion'] ?? 35;
  static int get compileSdkVersion => _config?['app']?['platform']?['compileSdkVersion'] ?? 36;
  static String get minMacOSVersion => _config?['app']?['platform']?['minMacOSVersion'] ?? '10.14';
  static String get minIOSVersion => _config?['app']?['platform']?['minIOSVersion'] ?? '12.0';

  /// Default configuration (fallback)
  static Map<String, dynamic> _getDefaultConfig() {
    return {
      'app': {
        'name': 'Learning Hub KS',
        'displayName': 'Learning Hub KS',
        'packageName': 'com.biohackerjoe.learninghub',
        'tagline': 'Your personal learning companion',
        'subtitle': 'PlainOS',
        'version': '0.1.0',
        'versionCode': '1',
        'buildNumber': '1',
        'description': 'A comprehensive learning platform',
        'category': 'Education',
        'contentRating': 'Everyone',
      },
      'developer': {
        'name': 'PlainOS by Joe Bains',
        'author': 'Joe Bains',
        'email': 'joebainsodds@gmail.com',
        'supportEmail': 'joebainsodds@gmail.com',
        'organization': 'PlainOS',
        'website': 'https://plainos.io',
        'bio': 'Biohacker and performance coach',
      },
      'legal': {
        'copyright': '© 2025 PlainOS by Joe Bains. All rights reserved.',
      }
    };
  }
}

