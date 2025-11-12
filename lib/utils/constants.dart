/// Application-wide constants to avoid magic numbers and strings.
/// Following SOLID principles and clean code practices.
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // Cache durations
  static const Duration defaultCacheDuration = Duration(minutes: 5);
  static const Duration shortCacheDuration = Duration(minutes: 1);
  static const Duration longCacheDuration = Duration(hours: 1);

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration dnsLookupTimeout = Duration(seconds: 5);
  static const Duration shortTimeout = Duration(seconds: 10);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  static const double defaultBorderRadius = 8.0;
  static const double smallBorderRadius = 4.0;
  static const double largeBorderRadius = 16.0;

  static const double defaultIconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Quiz/Game settings
  static const int defaultQuizTimeLimit = 30; // seconds
  static const int minQuizTimeLimit = 10;
  static const int maxQuizTimeLimit = 300;

  static const int maxQuizOptions = 5;
  static const int minQuizOptions = 2;

  // Scoring
  static const double perfectScoreMultiplier = 1.5;
  static const double quickAnswerBonus = 1.2;
  static const double minimumPassingScore = 60.0;

  // Progress tracking
  static const int maxAttempts = 5;
  static const double masteryThreshold = 90.0;

  // Data limits
  static const int maxCacheSize = 100;
  static const int maxRecentItems = 20;
  static const int maxSearchResults = 50;

  // Text limits
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  static const int maxFeedbackLength = 1000;
  static const int maxQuestionLength = 500;

  // Validation patterns
  static const String emailPattern = 
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Asset paths
  static const String dataPath = 'assets/data/';
  static const String manifestPath = '${dataPath}manifest.json';

  // Hive box names
  static const String categoriesBox = 'categories';
  static const String subcategoriesBox = 'subcategories';
  static const String learningUnitsBox = 'learning_units';
  static const String flashcardsBox = 'flashcards';
  static const String quizzesBox = 'quizzes';
  static const String questionsBox = 'questions';
  static const String usersBox = 'users';
  static const String userProgressBox = 'user_progress';
  static const String userPreferencesBox = 'user_preferences';
  static const String categoryProgressBox = 'category_progress';
  static const String subcategoryProgressBox = 'subcategory_progress';

  // Default values
  static const String defaultUserName = 'Student';
  static const String defaultColorScheme = 'Material Deep Purple';

  // Error messages
  static const String networkErrorMessage = 'Network error occurred. Please check your connection.';
  static const String dataLoadErrorMessage = 'Failed to load data. Please try again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  static const String unexpectedErrorMessage = 'An unexpected error occurred. Please try again.';

  // Success messages
  static const String dataSavedMessage = 'Data saved successfully';
  static const String loginSuccessMessage = 'Login successful';
  static const String logoutSuccessMessage = 'Logged out successfully';

  // Feature flags (for easy enabling/disabling of features)
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enableDebugLogging = true;
  static const bool enableOfflineMode = true;

  // Version requirements
  static const int minAppVersion = 1;
  static const String apiVersion = 'v1';
}

/// Color-related constants
class ColorConstants {
  ColorConstants._();

  // Semantic colors (independent of theme)
  static const int successColor = 0xFF4CAF50;
  static const int errorColor = 0xFFF44336;
  static const int warningColor = 0xFFFF9800;
  static const int infoColor = 0xFF2196F3;

  // Difficulty colors
  static const int beginnerColor = 0xFF4CAF50;
  static const int intermediateColor = 0xFFFF9800;
  static const int advancedColor = 0xFFF44336;
  static const int expertColor = 0xFF9C27B0;

  // Progress colors
  static const int notStartedColor = 0xFF9E9E9E;
  static const int inProgressColor = 0xFF2196F3;
  static const int completedColor = 0xFF4CAF50;
  static const int masteredColor = 0xFFFFD700; // Gold
}

/// Route names for navigation
class RouteConstants {
  RouteConstants._();

  static const String welcome = '/';
  static const String home = '/home';
  static const String category = '/category';
  static const String subcategory = '/subcategory';
  static const String learningUnit = '/learning-unit';
  static const String quiz = '/quiz';
  static const String flashcards = '/flashcards';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String leaderboard = '/leaderboard';
  static const String termsPrivacy = '/terms-privacy';
}
