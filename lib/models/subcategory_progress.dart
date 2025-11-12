import 'package:hive/hive.dart';

part 'subcategory_progress.g.dart';

@HiveType(typeId: 21)
class SubcategoryProgress extends HiveObject {
  @HiveField(0)
  String subcategoryId;

  @HiveField(1)
  String userId;

  @HiveField(2)
  int totalQuestions;

  @HiveField(3)
  int attemptedQuestions;

  @HiveField(4)
  int correctAnswers;

  @HiveField(5)
  DateTime? lastAccessedAt;

  @HiveField(6)
  DateTime? completedAt;

  SubcategoryProgress({
    required this.subcategoryId,
    required this.userId,
    this.totalQuestions = 0,
    this.attemptedQuestions = 0,
    this.correctAnswers = 0,
    this.lastAccessedAt,
    this.completedAt,
  });

  // Calculate progress percentage
  double get progressPercentage {
    if (totalQuestions == 0) return 0.0;
    return (attemptedQuestions / totalQuestions) * 100;
  }

  // Calculate accuracy
  double get accuracy {
    if (attemptedQuestions == 0) return 0.0;
    return (correctAnswers / attemptedQuestions) * 100;
  }

  // Check if started
  bool get isStarted => attemptedQuestions > 0;

  // Check if completed
  bool get isCompleted => totalQuestions > 0 && attemptedQuestions >= totalQuestions;

  // Check if perfect score
  bool get isPerfect => isCompleted && correctAnswers == totalQuestions;

  // Get status for coloring
  SubcategoryStatus get status {
    if (isPerfect) return SubcategoryStatus.perfect;
    if (isCompleted) return SubcategoryStatus.completed;
    if (isStarted) return SubcategoryStatus.inProgress;
    return SubcategoryStatus.notStarted;
  }
}

enum SubcategoryStatus {
  notStarted,   // Grey
  inProgress,   // Yellow
  completed,    // Orange
  perfect,      // Green
}

