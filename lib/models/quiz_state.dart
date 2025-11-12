import 'package:hive/hive.dart';

part 'quiz_state.g.dart';

@HiveType(typeId: 14)
class QuizState extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String learningUnitId;

  @HiveField(2)
  int currentQuestionIndex;

  @HiveField(3)
  int correctAnswers;

  @HiveField(4)
  DateTime lastUpdated;

  @HiveField(5)
  List<int> answeredQuestions; // Indices of questions already answered

  QuizState({
    required this.userId,
    required this.learningUnitId,
    required this.currentQuestionIndex,
    required this.correctAnswers,
    required this.lastUpdated,
    required this.answeredQuestions,
  });

  /// Check if this state is still valid (not too old)
  bool isValid() {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    // State is valid for 24 hours
    return difference.inHours < 24;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'learningUnitId': learningUnitId,
      'currentQuestionIndex': currentQuestionIndex,
      'correctAnswers': correctAnswers,
      'lastUpdated': lastUpdated.toIso8601String(),
      'answeredQuestions': answeredQuestions,
    };
  }

  factory QuizState.fromJson(Map<String, dynamic> json) {
    return QuizState(
      userId: json['userId'] as String,
      learningUnitId: json['learningUnitId'] as String,
      currentQuestionIndex: json['currentQuestionIndex'] as int,
      correctAnswers: json['correctAnswers'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      answeredQuestions: (json['answeredQuestions'] as List).cast<int>(),
    );
  }
}








