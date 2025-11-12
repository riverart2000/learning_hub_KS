import 'package:hive/hive.dart';
import '../models/achievement.dart';
import '../models/user_stats.dart';
import '../utils/app_logger.dart';

/// Service for managing gamification features (achievements, XP, levels, streaks)
class GamificationService {
  static const String _statsBoxName = 'user_stats';
  static const String _achievementsBoxName = 'achievements';
  static const String _statsKey = 'current_stats';

  /// Initialize the service and create default achievements
  Future<void> init() async {
    try {
      await Hive.openBox(_statsBoxName);
      await Hive.openBox(_achievementsBoxName);

      // Create default achievements if they don't exist
      final achievementsBox = Hive.box(_achievementsBoxName);
      if (achievementsBox.isEmpty) {
        await _createDefaultAchievements();
      }

      AppLogger.info('Gamification service initialized', tag: 'Gamification');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize gamification service',
        tag: 'Gamification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get current user stats
  UserStats getUserStats() {
    try {
      final box = Hive.box(_statsBoxName);
      final data = box.get(_statsKey);
      if (data != null) {
        return UserStats.fromJson(Map<String, dynamic>.from(data));
      }
      return UserStats();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get user stats',
        tag: 'Gamification',
        error: e,
        stackTrace: stackTrace,
      );
      return UserStats();
    }
  }

  /// Save user stats
  Future<void> _saveUserStats(UserStats stats) async {
    try {
      final box = Hive.box(_statsBoxName);
      await box.put(_statsKey, stats.toJson());
      AppLogger.debug('User stats saved', tag: 'Gamification');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save user stats',
        tag: 'Gamification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get all achievements
  List<Achievement> getAchievements() {
    try {
      final box = Hive.box(_achievementsBoxName);
      return box.values
          .map((e) => Achievement.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get achievements',
        tag: 'Gamification',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get achievements by category
  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return getAchievements()
        .where((a) => a.category == category)
        .toList();
  }

  /// Get unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    return getAchievements().where((a) => a.isUnlocked).toList();
  }

  /// Get locked achievements
  List<Achievement> getLockedAchievements() {
    return getAchievements().where((a) => !a.isUnlocked).toList();
  }

  /// Save achievement
  Future<void> _saveAchievement(Achievement achievement) async {
    try {
      final box = Hive.box(_achievementsBoxName);
      await box.put(achievement.id, achievement.toJson());
      AppLogger.debug('Achievement saved: ${achievement.id}', tag: 'Gamification');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save achievement',
        tag: 'Gamification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Award XP to user
  Future<({bool leveledUp, int newLevel, int xpGained})> awardXP(
    int amount,
    String reason,
  ) async {
    final stats = getUserStats();
    final oldLevel = stats.currentLevel;
    final newXP = stats.totalXP + amount;

    // Calculate new level
    int newLevel = oldLevel;
    int xpForNextLevel = oldLevel * 100;
    int currentXP = newXP;

    while (currentXP >= xpForNextLevel) {
      newLevel++;
      currentXP -= xpForNextLevel;
      xpForNextLevel = newLevel * 100;
    }

    final leveledUp = newLevel > oldLevel;

    await _saveUserStats(stats.copyWith(
      totalXP: newXP,
      currentLevel: newLevel,
    ));

    AppLogger.info(
      'Awarded $amount XP for: $reason (Level $oldLevel -> $newLevel)',
      tag: 'Gamification',
    );

    return (leveledUp: leveledUp, newLevel: newLevel, xpGained: amount);
  }

  /// Record quiz completion
  Future<List<Achievement>> recordQuizCompletion({
    required int score,
    required int totalQuestions,
    required String subject,
  }) async {
    final stats = getUserStats();
    final percentage = (score / totalQuestions * 100).round();
    
    // Update stats
    final updatedStats = stats.copyWith(
      quizzesCompleted: stats.quizzesCompleted + 1,
      averageQuizScore: (stats.averageQuizScore * stats.quizzesCompleted + percentage) / 
          (stats.quizzesCompleted + 1),
    );

    // Update subject mastery
    final mastery = Map<String, int>.from(updatedStats.subjectMastery);
    mastery[subject] = (mastery[subject] ?? 0) + score;
    
    await _saveUserStats(updatedStats.copyWith(subjectMastery: mastery));

    // Award XP based on performance
    int xpReward = (percentage * 0.5).round(); // Max 50 XP for perfect score
    await awardXP(xpReward, 'Completed quiz with $percentage%');

    // Check for quiz achievements
    return await _checkAchievements();
  }

  /// Record flashcard session
  Future<List<Achievement>> recordFlashcardSession({
    required int cardsReviewed,
  }) async {
    final stats = getUserStats();
    
    await _saveUserStats(stats.copyWith(
      flashcardsReviewed: stats.flashcardsReviewed + cardsReviewed,
    ));

    // Award XP (5 XP per card)
    await awardXP(cardsReviewed * 5, 'Reviewed $cardsReviewed flashcards');

    return await _checkAchievements();
  }

  /// Record study session
  Future<List<Achievement>> recordStudySession({
    required int durationMinutes,
  }) async {
    final stats = getUserStats();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Update daily activity
    final activity = Map<String, int>.from(stats.dailyActivity);
    final todayKey = today.toIso8601String().split('T')[0];
    activity[todayKey] = (activity[todayKey] ?? 0) + durationMinutes;
    
    // Update streak
    final lastActivity = stats.lastActivityDate;
    int newStreak = stats.currentStreak;
    
    if (lastActivity != null) {
      final lastDate = DateTime(
        lastActivity.year,
        lastActivity.month,
        lastActivity.day,
      );
      final daysDiff = today.difference(lastDate).inDays;
      
      if (daysDiff == 0) {
        // Same day, no change to streak
      } else if (daysDiff == 1) {
        // Consecutive day, increment streak
        newStreak++;
      } else {
        // Streak broken, reset to 1
        newStreak = 1;
      }
    } else {
      // First activity
      newStreak = 1;
    }
    
    final longestStreak = newStreak > stats.longestStreak ? newStreak : stats.longestStreak;
    
    await _saveUserStats(stats.copyWith(
      studySessionsCompleted: stats.studySessionsCompleted + 1,
      totalStudyTimeMinutes: stats.totalStudyTimeMinutes + durationMinutes,
      currentStreak: newStreak,
      longestStreak: longestStreak,
      lastActivityDate: now,
      dailyActivity: activity,
    ));

    // Award XP (2 XP per minute)
    await awardXP(durationMinutes * 2, 'Studied for $durationMinutes minutes');

    return await _checkAchievements();
  }

  /// Check and unlock achievements based on current stats
  Future<List<Achievement>> _checkAchievements() async {
    final stats = getUserStats();
    final achievements = getAchievements();
    final newlyUnlocked = <Achievement>[];

    for (final achievement in achievements) {
      if (achievement.isUnlocked) continue;

      int currentProgress = 0;

      // Calculate progress based on achievement ID
      switch (achievement.id) {
        case 'first_quiz':
          currentProgress = stats.quizzesCompleted;
          break;
        case 'quiz_master':
          currentProgress = stats.quizzesCompleted;
          break;
        case 'quiz_legend':
          currentProgress = stats.quizzesCompleted;
          break;
        case 'first_flashcard':
          currentProgress = stats.flashcardsReviewed;
          break;
        case 'flashcard_enthusiast':
          currentProgress = stats.flashcardsReviewed;
          break;
        case 'flashcard_expert':
          currentProgress = stats.flashcardsReviewed;
          break;
        case 'first_study':
          currentProgress = stats.studySessionsCompleted;
          break;
        case 'dedicated_learner':
          currentProgress = stats.totalStudyTimeMinutes;
          break;
        case 'study_marathon':
          currentProgress = stats.totalStudyTimeMinutes;
          break;
        case 'streak_starter':
          currentProgress = stats.currentStreak;
          break;
        case 'week_warrior':
          currentProgress = stats.currentStreak;
          break;
        case 'month_master':
          currentProgress = stats.currentStreak;
          break;
        case 'level_5':
          currentProgress = stats.currentLevel;
          break;
        case 'level_10':
          currentProgress = stats.currentLevel;
          break;
        case 'level_25':
          currentProgress = stats.currentLevel;
          break;
        case 'getting_started':
          currentProgress = stats.quizzesCompleted + stats.flashcardsReviewed;
          break;
      }

      // Update progress
      final updated = achievement.copyWith(currentProgress: currentProgress);
      await _saveAchievement(updated);

      // Check if unlocked
      if (updated.isComplete && !updated.isUnlocked) {
        final unlocked = updated.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        await _saveAchievement(unlocked);
        
        // Award XP for unlocking
        await awardXP(unlocked.xpReward, 'Unlocked: ${unlocked.title}');
        
        newlyUnlocked.add(unlocked);
        AppLogger.info(
          'Achievement unlocked: ${unlocked.title}',
          tag: 'Gamification',
        );
      }
    }

    return newlyUnlocked;
  }

  /// Reset all progress (for testing)
  Future<void> resetProgress() async {
    try {
      final statsBox = Hive.box(_statsBoxName);
      final achievementsBox = Hive.box(_achievementsBoxName);
      
      await statsBox.clear();
      await achievementsBox.clear();
      await _createDefaultAchievements();
      
      AppLogger.info('Progress reset', tag: 'Gamification');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to reset progress',
        tag: 'Gamification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Create default achievements
  Future<void> _createDefaultAchievements() async {
    final defaultAchievements = [
      // Quiz achievements
      Achievement(
        id: 'first_quiz',
        title: 'First Steps',
        description: 'Complete your first quiz',
        icon: '📝',
        requiredProgress: 1,
        category: AchievementCategory.quiz,
        xpReward: 10,
      ),
      Achievement(
        id: 'quiz_master',
        title: 'Quiz Master',
        description: 'Complete 10 quizzes',
        icon: '🎯',
        requiredProgress: 10,
        category: AchievementCategory.quiz,
        xpReward: 50,
      ),
      Achievement(
        id: 'quiz_legend',
        title: 'Quiz Legend',
        description: 'Complete 50 quizzes',
        icon: '👑',
        requiredProgress: 50,
        category: AchievementCategory.quiz,
        xpReward: 200,
      ),
      
      // Flashcard achievements
      Achievement(
        id: 'first_flashcard',
        title: 'Card Flipper',
        description: 'Review your first flashcard',
        icon: '🃏',
        requiredProgress: 1,
        category: AchievementCategory.flashcard,
        xpReward: 10,
      ),
      Achievement(
        id: 'flashcard_enthusiast',
        title: 'Card Enthusiast',
        description: 'Review 50 flashcards',
        icon: '🎴',
        requiredProgress: 50,
        category: AchievementCategory.flashcard,
        xpReward: 50,
      ),
      Achievement(
        id: 'flashcard_expert',
        title: 'Memory Expert',
        description: 'Review 200 flashcards',
        icon: '🧠',
        requiredProgress: 200,
        category: AchievementCategory.flashcard,
        xpReward: 150,
      ),
      
      // Study achievements
      Achievement(
        id: 'first_study',
        title: 'Study Beginner',
        description: 'Complete your first study session',
        icon: '📚',
        requiredProgress: 1,
        category: AchievementCategory.study,
        xpReward: 10,
      ),
      Achievement(
        id: 'dedicated_learner',
        title: 'Dedicated Learner',
        description: 'Study for 60 minutes total',
        icon: '⏱️',
        requiredProgress: 60,
        category: AchievementCategory.study,
        xpReward: 75,
      ),
      Achievement(
        id: 'study_marathon',
        title: 'Study Marathon',
        description: 'Study for 300 minutes total',
        icon: '🏃',
        requiredProgress: 300,
        category: AchievementCategory.study,
        xpReward: 250,
      ),
      
      // Streak achievements
      Achievement(
        id: 'streak_starter',
        title: 'Consistency Starter',
        description: 'Maintain a 3-day streak',
        icon: '🔥',
        requiredProgress: 3,
        category: AchievementCategory.streak,
        xpReward: 25,
      ),
      Achievement(
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: '⚡',
        requiredProgress: 7,
        category: AchievementCategory.streak,
        xpReward: 100,
      ),
      Achievement(
        id: 'month_master',
        title: 'Month Master',
        description: 'Maintain a 30-day streak',
        icon: '💎',
        requiredProgress: 30,
        category: AchievementCategory.streak,
        xpReward: 500,
      ),
      
      // Level achievements
      Achievement(
        id: 'level_5',
        title: 'Rising Star',
        description: 'Reach Level 5',
        icon: '⭐',
        requiredProgress: 5,
        category: AchievementCategory.mastery,
        xpReward: 50,
      ),
      Achievement(
        id: 'level_10',
        title: 'Expert Scholar',
        description: 'Reach Level 10',
        icon: '🌟',
        requiredProgress: 10,
        category: AchievementCategory.mastery,
        xpReward: 150,
      ),
      Achievement(
        id: 'level_25',
        title: 'Legendary Master',
        description: 'Reach Level 25',
        icon: '✨',
        requiredProgress: 25,
        category: AchievementCategory.mastery,
        xpReward: 600,
      ),
      
      // General
      Achievement(
        id: 'getting_started',
        title: 'Getting Started',
        description: 'Complete your first quiz or flashcard',
        icon: '🚀',
        requiredProgress: 1,
        category: AchievementCategory.general,
        xpReward: 5,
      ),
    ];

    for (final achievement in defaultAchievements) {
      await _saveAchievement(achievement);
    }

    AppLogger.info(
      'Created ${defaultAchievements.length} default achievements',
      tag: 'Gamification',
    );
  }
}
