import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 16)
enum ProgressStatus {
  @HiveField(0)
  notStarted,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  mastered,
}

@HiveType(typeId: 5)
class UserProgress extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String learningUnitId;

  @HiveField(3)
  ProgressStatus status;

  @HiveField(4)
  int attempts;

  @HiveField(5)
  double score;

  @HiveField(6)
  DateTime? lastReviewed;

  @HiveField(7)
  DateTime? nextReview;

  UserProgress({
    required this.id,
    required this.userId,
    required this.learningUnitId,
    required this.status,
    required this.attempts,
    required this.score,
    this.lastReviewed,
    this.nextReview,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      learningUnitId: json['learningUnitId'] as String,
      status: ProgressStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProgressStatus.notStarted,
      ),
      attempts: json['attempts'] as int,
      score: (json['score'] as num).toDouble(),
      lastReviewed: json['lastReviewed'] != null
          ? DateTime.parse(json['lastReviewed'] as String)
          : null,
      nextReview: json['nextReview'] != null
          ? DateTime.parse(json['nextReview'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'learningUnitId': learningUnitId,
      'status': status.name,
      'attempts': attempts,
      'score': score,
      'lastReviewed': lastReviewed?.toIso8601String(),
      'nextReview': nextReview?.toIso8601String(),
    };
  }
}

@HiveType(typeId: 12)
enum HiveProgressStatus {
  @HiveField(0)
  notStarted,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  mastered,
}

