import 'package:flutter/foundation.dart';
import '../models/user.dart';

/// Offline stub implementation of FirebaseService.
/// All methods behave gracefully when Firebase is disabled or removed.
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // ==================== Authentication ====================

  Future<(Object?, String?)> signInAnonymously() async {
    debugPrint('ℹ️ Firebase disabled: signInAnonymously() skipped');
    return (null, 'Firebase offline');
  }

  Future<(Object?, String?)> signInWithEmail(String email, String password) async {
    debugPrint('ℹ️ Firebase disabled: signInWithEmail() skipped');
    return (null, 'Firebase offline');
  }

  Future<(Object?, String?)> createAccountWithEmail(String email, String password) async {
    debugPrint('ℹ️ Firebase disabled: createAccountWithEmail() skipped');
    return (null, 'Firebase offline');
  }

  Object? getCurrentFirebaseUser() => null;

  bool isAuthenticated() => false;

  Future<void> signOut() async {
    debugPrint('ℹ️ Firebase disabled: signOut() skipped');
  }

  // ==================== User Data ====================

  Future<void> saveUserProfile(User user) async {
    debugPrint('ℹ️ Firebase disabled: saveUserProfile() skipped');
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    debugPrint('ℹ️ Firebase disabled: getUserProfile() returning null');
    return null;
  }

  Future<Map<String, dynamic>?> findUserByNameAndEmail(String name, String email) async {
    debugPrint('ℹ️ Firebase disabled: findUserByNameAndEmail() returning null');
    return null;
  }

  // ==================== Scores & Leaderboard ====================

  Future<void> saveScore({
    required String userId,
    required String userName,
    required String userEmail,
    required double score,
    required String category,
    required String difficulty,
  }) async {
    debugPrint('ℹ️ Firebase disabled: saveScore() skipped');
  }

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    debugPrint('ℹ️ Firebase disabled: getLeaderboard() returning empty list');
    return [];
  }

  Future<int> getUserRank(String uid) async {
    debugPrint('ℹ️ Firebase disabled: getUserRank() returning -1');
    return -1;
  }

  Future<int> getUserRankByNameEmail(String name, String email) async {
    debugPrint('ℹ️ Firebase disabled: getUserRankByNameEmail() returning -1');
    return -1;
  }

  Future<bool> submitFeedback({
    required String userId,
    required String userName,
    required String feedbackText,
    String? screenshotUrl,
  }) async {
    debugPrint('ℹ️ Firebase disabled: submitFeedback() skipped');
    return false;
  }

  Future<List<Map<String, dynamic>>> getAllFeedback({int limit = 50}) async {
    debugPrint('ℹ️ Firebase disabled: getAllFeedback() returning empty list');
    return [];
  }

  // ==================== Utilities ====================

  bool isInitialized() => false;

  Future<List<Map<String, dynamic>>> getUserScores(
    String firebaseUid, {
    int limit = 20,
  }) async {
    debugPrint('ℹ️ Firebase disabled: getUserScores() returning empty list');
    return [];
  }

  Future<(bool, String?)> deleteUserAccount(String name, String email) async {
    debugPrint('ℹ️ Firebase disabled: deleteUserAccount() nothing to delete');
    return (true, null);
  }
}

