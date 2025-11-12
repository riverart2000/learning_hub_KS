import 'package:hive/hive.dart';

part 'quiz.g.dart';

@HiveType(typeId: 4)
class Quiz extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String learningUnitId;

  @HiveField(2)
  String question;

  @HiveField(3)
  List<String> options;

  @HiveField(4)
  int correctAnswerIndex;

  @HiveField(5)
  String? explanation;

  @HiveField(6)
  String? imageUrl;

  @HiveField(7)
  int? timeLimit;

  Quiz({
    required this.id,
    required this.learningUnitId,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.imageUrl,
    this.timeLimit,
  });

  String get correctAnswer => options[correctAnswerIndex];

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      learningUnitId: json['learningUnitId'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String?,
      imageUrl: json['imageUrl'] as String?,
      timeLimit: json['timeLimit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'learningUnitId': learningUnitId,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'imageUrl': imageUrl,
      'timeLimit': timeLimit,
    };
  }
}

