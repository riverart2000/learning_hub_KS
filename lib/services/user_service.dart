import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../models/user_progress.dart';
import '../models/user_preferences.dart';
import '../models/learning_unit.dart';
import 'hive_service.dart';
import 'firebase_service.dart';

class UserService {
  static const Uuid _uuid = Uuid();

  static Future<User> createUser({
    required String name,
    required String email,
  }) async {
    // First, check if user exists in Firebase
    final firebaseService = FirebaseService();
    final existingUserData = await firebaseService.findUserByNameAndEmail(name, email);
    
    User user;
    
    if (existingUserData != null) {
      // User exists in Firebase - load their scores
      debugPrint('📥 Loading existing user from Firebase');
      user = User(
        id: _uuid.v4(), // New local ID
        name: name,
        email: email,
        createdAt: existingUserData['createdAt'] != null 
            ? DateTime.parse(existingUserData['createdAt'])
            : DateTime.now(),
        totalScore: (existingUserData['totalScore'] ?? 0.0).toDouble(),
        highScore: (existingUserData['highScore'] ?? 0.0).toDouble(),
      );
      debugPrint('✅ Loaded scores - High: ${user.highScore}, Total: ${user.totalScore}');
    } else {
      // New user - start fresh
      debugPrint('🆕 Creating new user');
      user = User(
        id: _uuid.v4(),
        name: name,
        email: email,
        createdAt: DateTime.now(),
        totalScore: 0.0,
        highScore: 0.0,
      );
    }

    await HiveService.saveUser(user);

    // Create default preferences
    final preferences = UserPreferences(
      id: user.id,
      userId: user.id,
      preferredCategories: [],
      difficultyPreference: Difficulty.beginner,
      studyRemindersEnabled: true,
      isDarkMode: false,
      colorScheme: 'green',
    );

    await HiveService.saveUserPreferences(preferences);

    return user;
  }

  static User? getCurrentUser() {
    return HiveService.getCurrentUser();
  }
  
  static Future<User?> findUserByEmail(String email) async {
    // Search all users in Hive for matching email
    final box = Hive.box<User>('users');
    try {
      return box.values.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      // User not found
      return null;
    }
  }

  static Future<User> getOrCreateDefaultUser() async {
    User? user = getCurrentUser();
    
    user ??= await createUser(
        name: 'Student',
        email: 'student@learninghub.com',
      );
    
    return user;
  }

  static Future<void> updateUserScore(String userId, double scoreToAdd) async {
    await HiveService.updateUserScore(userId, scoreToAdd);
  }

  static Future<void> recordProgress({
    required String userId,
    required String learningUnitId,
    required double score,
    required ProgressStatus status,
  }) async {
    final existingProgress = HiveService.getUserProgress(userId, learningUnitId);
    
    final progress = UserProgress(
      id: existingProgress?.id ?? '${userId}_$learningUnitId',
      userId: userId,
      learningUnitId: learningUnitId,
      status: status,
      attempts: (existingProgress?.attempts ?? 0) + 1,
      score: score > (existingProgress?.score ?? 0) ? score : (existingProgress?.score ?? 0),
      lastReviewed: DateTime.now(),
      nextReview: _calculateNextReview(status, score),
    );

    await HiveService.saveUserProgress(progress);
    
    // Update user's total score
    if (score > (existingProgress?.score ?? 0)) {
      final scoreIncrease = score - (existingProgress?.score ?? 0);
      await updateUserScore(userId, scoreIncrease);
    }
  }

  static DateTime? _calculateNextReview(ProgressStatus status, double score) {
    if (status == ProgressStatus.mastered) {
      return DateTime.now().add(const Duration(days: 7));
    } else if (status == ProgressStatus.completed && score >= 80) {
      return DateTime.now().add(const Duration(days: 3));
    } else if (status == ProgressStatus.completed) {
      return DateTime.now().add(const Duration(days: 1));
    }
    return null;
  }

  static UserProgress? getUserProgress(String userId, String learningUnitId) {
    return HiveService.getUserProgress(userId, learningUnitId);
  }

  static List<UserProgress> getUserProgressList(String userId) {
    return HiveService.getUserProgressList(userId);
  }

  static UserPreferences? getUserPreferences(String userId) {
    return HiveService.getUserPreferences(userId);
  }

  static Future<void> saveUserPreferences(UserPreferences preferences) async {
    await HiveService.saveUserPreferences(preferences);
  }

  static double calculateScore({
    required int correctAnswers,
    required int totalQuestions,
    required Difficulty difficulty,
  }) {
    final baseScore = (correctAnswers / totalQuestions) * 100;
    
    // Apply difficulty multiplier
    double multiplier;
    switch (difficulty) {
      case Difficulty.beginner:
        multiplier = 1.0;
        break;
      case Difficulty.intermediate:
        multiplier = 2.0;
        break;
      case Difficulty.advanced:
        multiplier = 3.0;
        break;
    }
    
    return baseScore * multiplier;
  }

  static ProgressStatus getProgressStatus(double score) {
    if (score >= 95) {
      return ProgressStatus.mastered;
    } else if (score >= 70) {
      return ProgressStatus.completed;
    } else {
      return ProgressStatus.inProgress;
    }
  }

  static Map<String, dynamic> getUserStats(String userId) {
    final progressList = getUserProgressList(userId);
    final user = HiveService.getCurrentUser();
    
    final totalUnits = progressList.length;
    final completedUnits = progressList.where((p) => 
      p.status == ProgressStatus.completed || p.status == ProgressStatus.mastered
    ).length;
    final masteredUnits = progressList.where((p) => 
      p.status == ProgressStatus.mastered
    ).length;
    
    final averageScore = progressList.isNotEmpty 
      ? progressList.map((p) => p.score).reduce((a, b) => a + b) / progressList.length
      : 0.0;
    
    return {
      'totalScore': user?.totalScore ?? 0.0,
      'highScore': user?.highScore ?? 0.0,
      'totalUnits': totalUnits,
      'completedUnits': completedUnits,
      'masteredUnits': masteredUnits,
      'averageScore': averageScore,
      'completionRate': totalUnits > 0 ? (completedUnits / totalUnits) * 100 : 0.0,
    };
  }

  static Future<void> updateUserName(String userId, String newName) async {
    final user = HiveService.getCurrentUser();
    if (user != null && user.id == userId) {
      user.name = newName;
      await HiveService.saveUser(user);
    }
  }

  static Future<void> clearCurrentUser() async {
    // Clear the current user from Hive storage
    await HiveService.clearCurrentUser();
    debugPrint('Current user cleared from storage');
  }

  // Photo functionality removed for privacy compliance
}

