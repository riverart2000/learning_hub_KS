import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/user_stats.dart';
import '../services/gamification_service.dart';
import '../services/achievement_notification_service.dart';
import '../utils/app_logger.dart';

/// Provider for managing gamification state
class GamificationProvider extends ChangeNotifier {
  final GamificationService _service = GamificationService();
  
  UserStats _stats = UserStats();
  List<Achievement> _achievements = [];
  bool _isInitialized = false;

  UserStats get stats => _stats;
  List<Achievement> get achievements => _achievements;
  bool get isInitialized => _isInitialized;

  /// Initialize the provider
  Future<void> init() async {
    try {
      await _service.init();
      _stats = _service.getUserStats();
      _achievements = _service.getAchievements();
      _isInitialized = true;
      notifyListeners();
      
      AppLogger.info('Gamification provider initialized', tag: 'GamificationProvider');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize gamification provider',
        tag: 'GamificationProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    _stats = _service.getUserStats();
    _achievements = _service.getAchievements();
    notifyListeners();
  }

  /// Record quiz completion
  Future<void> recordQuizCompletion({
    required BuildContext context,
    required int score,
    required int totalQuestions,
    required String subject,
  }) async {
    try {
      final newAchievements = await _service.recordQuizCompletion(
        score: score,
        totalQuestions: totalQuestions,
        subject: subject,
      );

      await refresh();

      // Show notifications
      if (context.mounted) {
        _showNotifications(context, newAchievements);
      }

      AppLogger.info(
        'Recorded quiz completion: $score/$totalQuestions',
        tag: 'GamificationProvider',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to record quiz completion',
        tag: 'GamificationProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Record flashcard session
  Future<void> recordFlashcardSession({
    required BuildContext context,
    required int cardsReviewed,
  }) async {
    try {
      final newAchievements = await _service.recordFlashcardSession(
        cardsReviewed: cardsReviewed,
      );

      await refresh();

      // Show notifications
      if (context.mounted) {
        _showNotifications(context, newAchievements);
      }

      AppLogger.info(
        'Recorded flashcard session: $cardsReviewed cards',
        tag: 'GamificationProvider',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to record flashcard session',
        tag: 'GamificationProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Record study session
  Future<void> recordStudySession({
    required BuildContext context,
    required int durationMinutes,
  }) async {
    try {
      final oldLevel = _stats.currentLevel;
      final oldStreak = _stats.currentStreak;

      final newAchievements = await _service.recordStudySession(
        durationMinutes: durationMinutes,
      );

      await refresh();

      // Show notifications
      if (context.mounted) {
        _showNotifications(context, newAchievements);
        
        // Check for level up
        if (_stats.currentLevel > oldLevel) {
          AchievementNotificationService.showLevelUp(context, _stats.currentLevel);
        }
        
        // Check for streak milestones
        if (_stats.currentStreak > oldStreak && _stats.currentStreak % 7 == 0) {
          AchievementNotificationService.showStreakMilestone(
            context,
            _stats.currentStreak,
          );
        }
      }

      AppLogger.info(
        'Recorded study session: $durationMinutes minutes',
        tag: 'GamificationProvider',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to record study session',
        tag: 'GamificationProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Show achievement notifications
  void _showNotifications(
    BuildContext context,
    List<Achievement> newAchievements,
  ) {
    if (!context.mounted) return;

    for (final achievement in newAchievements) {
      // Add slight delay between notifications
      Future.delayed(
        Duration(milliseconds: newAchievements.indexOf(achievement) * 500),
        () {
          if (context.mounted) {
            AchievementNotificationService.showAchievementUnlocked(
              context,
              achievement,
            );
          }
        },
      );
    }
  }

  /// Reset progress (for testing)
  Future<void> resetProgress() async {
    try {
      await _service.resetProgress();
      await refresh();
      
      AppLogger.info('Progress reset', tag: 'GamificationProvider');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to reset progress',
        tag: 'GamificationProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get achievements by category
  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _achievements.where((a) => a.category == category).toList();
  }

  /// Get unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  /// Get locked achievements
  List<Achievement> getLockedAchievements() {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }
}
