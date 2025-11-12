/// Enum for achievement categories
enum AchievementCategory {
  general,
  quiz,
  flashcard,
  study,
  streak,
  mastery,
}

/// Model for an achievement/badge
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon; // Emoji
  final int requiredProgress;
  final AchievementCategory category;
  final int xpReward;
  final bool isUnlocked;
  final int currentProgress;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredProgress,
    required this.category,
    required this.xpReward,
    this.isUnlocked = false,
    this.currentProgress = 0,
    this.unlockedAt,
  });

  /// Calculate progress percentage
  double get progressPercentage {
    if (requiredProgress == 0) return 0.0;
    return (currentProgress / requiredProgress).clamp(0.0, 1.0);
  }

  /// Check if achievement is complete
  bool get isComplete => currentProgress >= requiredProgress;

  /// Copy with updated values
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? requiredProgress,
    AchievementCategory? category,
    int? xpReward,
    bool? isUnlocked,
    int? currentProgress,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      requiredProgress: requiredProgress ?? this.requiredProgress,
      category: category ?? this.category,
      xpReward: xpReward ?? this.xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentProgress: currentProgress ?? this.currentProgress,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'requiredProgress': requiredProgress,
      'category': category.toString().split('.').last,
      'xpReward': xpReward,
      'isUnlocked': isUnlocked,
      'currentProgress': currentProgress,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      requiredProgress: json['requiredProgress'],
      category: AchievementCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => AchievementCategory.general,
      ),
      xpReward: json['xpReward'],
      isUnlocked: json['isUnlocked'] ?? false,
      currentProgress: json['currentProgress'] ?? 0,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, progress: $currentProgress/$requiredProgress, unlocked: $isUnlocked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
