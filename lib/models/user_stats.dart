/// Model for tracking user statistics and progress
class UserStats {
  final int totalXP;
  final int currentLevel;
  final int quizzesCompleted;
  final int flashcardsReviewed;
  final int studySessionsCompleted;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final Map<String, int> subjectMastery; // subject -> questions correct
  final Map<String, int> dailyActivity; // date -> minutes studied
  final int totalStudyTimeMinutes;
  final double averageQuizScore;

  UserStats({
    this.totalXP = 0,
    this.currentLevel = 1,
    this.quizzesCompleted = 0,
    this.flashcardsReviewed = 0,
    this.studySessionsCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    Map<String, int>? subjectMastery,
    Map<String, int>? dailyActivity,
    this.totalStudyTimeMinutes = 0,
    this.averageQuizScore = 0.0,
  })  : subjectMastery = subjectMastery ?? {},
        dailyActivity = dailyActivity ?? {};

  /// Calculate XP required for next level
  int xpForNextLevel() {
    return currentLevel * 100; // Simple formula: 100 XP per level
  }

  /// Calculate progress to next level
  double levelProgress() {
    int xpForLevel = xpForNextLevel();
    int xpIntoLevel = totalXP % xpForLevel;
    return xpIntoLevel / xpForLevel;
  }

  /// Calculate total correct answers across all subjects
  int get totalCorrectAnswers {
    return subjectMastery.values.fold(0, (sum, count) => sum + count);
  }

  /// Get most practiced subject
  String? get topSubject {
    if (subjectMastery.isEmpty) return null;
    return subjectMastery.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Copy with updated values
  UserStats copyWith({
    int? totalXP,
    int? currentLevel,
    int? quizzesCompleted,
    int? flashcardsReviewed,
    int? studySessionsCompleted,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    Map<String, int>? subjectMastery,
    Map<String, int>? dailyActivity,
    int? totalStudyTimeMinutes,
    double? averageQuizScore,
  }) {
    return UserStats(
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      flashcardsReviewed: flashcardsReviewed ?? this.flashcardsReviewed,
      studySessionsCompleted:
          studySessionsCompleted ?? this.studySessionsCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      subjectMastery: subjectMastery ?? Map.from(this.subjectMastery),
      dailyActivity: dailyActivity ?? Map.from(this.dailyActivity),
      totalStudyTimeMinutes:
          totalStudyTimeMinutes ?? this.totalStudyTimeMinutes,
      averageQuizScore: averageQuizScore ?? this.averageQuizScore,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalXP': totalXP,
      'currentLevel': currentLevel,
      'quizzesCompleted': quizzesCompleted,
      'flashcardsReviewed': flashcardsReviewed,
      'studySessionsCompleted': studySessionsCompleted,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'subjectMastery': subjectMastery,
      'dailyActivity': dailyActivity,
      'totalStudyTimeMinutes': totalStudyTimeMinutes,
      'averageQuizScore': averageQuizScore,
    };
  }

  /// Create from JSON
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalXP: json['totalXP'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      quizzesCompleted: json['quizzesCompleted'] ?? 0,
      flashcardsReviewed: json['flashcardsReviewed'] ?? 0,
      studySessionsCompleted: json['studySessionsCompleted'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'])
          : null,
      subjectMastery: json['subjectMastery'] != null
          ? Map<String, int>.from(json['subjectMastery'])
          : {},
      dailyActivity: json['dailyActivity'] != null
          ? Map<String, int>.from(json['dailyActivity'])
          : {},
      totalStudyTimeMinutes: json['totalStudyTimeMinutes'] ?? 0,
      averageQuizScore: json['averageQuizScore']?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'UserStats(level: $currentLevel, xp: $totalXP, quizzes: $quizzesCompleted, streak: $currentStreak)';
  }
}
