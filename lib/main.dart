import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'services/hive_service.dart';
import 'services/user_service.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'services/quote_service.dart';
import 'services/app_config_service.dart';
import 'providers/theme_provider.dart';
import 'providers/gamification_provider.dart';
import 'screens/sidemenu_home_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/data_loader_service.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure logging based on environment
  if (kReleaseMode && !kIsWeb && Platform.isAndroid) {
    AppLogger.disableOnAndroidProduction();
  }
  
  AppLogger.info('Application starting', tag: 'Main');
  
  // Firebase removed: run entirely in offline/local mode
  AppLogger.info('Firebase disabled. Running in offline mode with local storage.', tag: 'Main');
  
  // Initialize Hive
  await HiveService.initHive();
  AppLogger.info('Hive initialized', tag: 'Main');
  
  // Load app configuration
  await AppConfigService.loadConfig();
  AppLogger.info('App configuration loaded', tag: 'Main');
  
  // Load all data files (questions, quizzes, categories, etc.)
  await DataLoaderService.loadAllDataFiles();
  AppLogger.info('All data files loaded', tag: 'Main');
  
  // Load motivational quotes
  await QuoteService.loadQuotes();
  AppLogger.info('Motivational quotes loaded', tag: 'Main');
  
  // Debug: Print manifest contents
  await DataLoaderService.printManifest();
  
  // Debug: Validate all files exist
  final validation = await DataLoaderService.validateManifest();
  AppLogger.debug('Validation results', tag: 'Main', data: validation);
  
   // Clear data to force fresh load (TEMPORARY)
  await DataLoaderService.clearAllData();

  // Load all JSON data files from assets/data directory
  await HiveService.loadSampleData();
  
  // Debug: Check what was actually loaded
  await DataLoaderService.debugDataStatus();
  
  // Check if user is already logged in
  final authService = AuthService();
  final isLoggedIn = authService.isLoggedIn();
  
  // Get or create default user if logged in
  String? userId;
  if (isLoggedIn) {
    final user = UserService.getCurrentUser();
    userId = user?.id;
  }
  
  AppLogger.info(
    'Application initialized',
    tag: 'Main',
    data: {'isLoggedIn': isLoggedIn, 'userId': userId},
  );
  
  runApp(LearningHubApp(
    isLoggedIn: isLoggedIn,
    userId: userId,
  ));
}

class LearningHubApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userId;
  
  const LearningHubApp({
    super.key,
    required this.isLoggedIn,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..setCurrentUser(userId ?? ''),
        ),
        ChangeNotifierProvider(
          create: (context) => GamificationProvider()..init(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return BetterFeedback(
            theme: FeedbackThemeData(
              background: Colors.grey,
              feedbackSheetColor: Colors.white,
              drawColors: [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
              ],
            ),
            child: MaterialApp(
              title: AppConfigService.appName,
              theme: themeProvider.currentTheme,
              home: isLoggedIn ? const SideMenuHomeScreen() : const WelcomeScreen(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}

/// Helper function to handle feedback submission
Future<void> sendFeedback(BuildContext context, UserFeedback feedback) async {
  try {
    final firebaseService = FirebaseService();
    final user = UserService.getCurrentUser();
    
    // Save feedback to Firebase
    bool savedToFirebase = false;
    if (user != null) {
      savedToFirebase = await firebaseService.submitFeedback(
        userId: user.id,
        userName: user.name,
        feedbackText: feedback.text,
        screenshotUrl: null, // Could upload screenshot to Firebase Storage
      );
    }

    // Also send via email (optional backup) - only on mobile/desktop
    if (!kIsWeb) {
      try {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/feedback_screenshot.png');
        await file.writeAsBytes(feedback.screenshot);

        final Email email = Email(
          body: '''
Learning Hub Feedback

User: ${user?.name ?? 'Anonymous'}
Email: ${user?.email ?? 'Not provided'}

Comment:
${feedback.text}

---
This feedback was submitted via the Learning Hub app.
${savedToFirebase ? '\n✓ Also saved to Firebase' : ''}
          ''',
          subject: 'Learning Hub App Feedback',
          recipients: [AppConfigService.supportEmail], // Configurable support email
          attachmentPaths: [file.path],
          isHTML: false,
        );

        await FlutterEmailSender.send(email);
      } catch (emailError) {
        debugPrint('Email sending failed: $emailError');
        // Continue anyway if Firebase succeeded
      }
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedToFirebase
                ? 'Thank you for your feedback! It has been saved.'
                : 'Thank you for your feedback!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending feedback: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}