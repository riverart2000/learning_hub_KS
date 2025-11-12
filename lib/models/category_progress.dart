import 'package:hive/hive.dart';

part 'category_progress.g.dart';

@HiveType(typeId: 20)
class CategoryProgress extends HiveObject {
  @HiveField(0)
  String categoryId;

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

  CategoryProgress({
    required this.categoryId,
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

  // Check if completed (all questions attempted)
  bool get isCompleted => totalQuestions > 0 && attemptedQuestions >= totalQuestions;

  // Check if perfect score
  bool get isPerfect => isCompleted && correctAnswers == totalQuestions;

  // Get status for coloring
  CategoryStatus get status {
    if (isPerfect) return CategoryStatus.perfect;
    if (isCompleted) return CategoryStatus.completed;
    if (isStarted) return CategoryStatus.inProgress;
    return CategoryStatus.notStarted;
  }
}

enum CategoryStatus {
  notStarted,   // Grey
  inProgress,   // Yellow
  completed,    // Orange
  perfect,      // Green
}

