import 'package:hive/hive.dart';
import 'learning_unit.dart'; // For Difficulty enum

// part 'question.g.dart'; // Will add adapter manually

@HiveType(typeId: 8)
class Question extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String learningUnitId;

  @HiveField(2)
  String question;

  @HiveField(3)
  String correctAnswer;

  @HiveField(4)
  String? hint;

  @HiveField(5)
  String? explanation;

  @HiveField(6)
  String? imageUrl;

  @HiveField(7)
  String? audioUrl;

  @HiveField(8)
  Difficulty difficulty;

  @HiveField(9)
  List<String> tags;

  @HiveField(10)
  int? timeLimit;

  Question({
    required this.id,
    required this.learningUnitId,
    required this.question,
    required this.correctAnswer,
    this.hint,
    this.explanation,
    this.imageUrl,
    this.audioUrl,
    required this.difficulty,
    required this.tags,
    this.timeLimit,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      learningUnitId: json['learningUnitId'] as String,
      question: json['question'] as String,
      correctAnswer: json['correctAnswer'] as String,
      hint: json['hint'] as String?,
      explanation: json['explanation'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == (json['difficulty'] ?? 'beginner'),
        orElse: () => Difficulty.beginner,
      ),
      tags: List<String>.from(json['tags'] as List? ?? []),
      timeLimit: json['timeLimit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'learningUnitId': learningUnitId,
      'question': question,
      'correctAnswer': correctAnswer,
      'hint': hint,
      'explanation': explanation,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'difficulty': difficulty.name,
      'tags': tags,
      'timeLimit': timeLimit,
    };
  }

  // Convert Question to Flashcard for dynamic generation
  Map<String, dynamic> toFlashcard() {
    return {
      'id': 'fc_$id',
      'learningUnitId': learningUnitId,
      'front': question,
      'back': correctAnswer,
      'hint': hint,
      'explanation': explanation,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'difficulty': difficulty.name,
      'tags': tags,
    };
  }

  // Convert Question to Quiz for dynamic generation
  Map<String, dynamic> toQuiz() {
    // Create options with the correct answer and some generic distractors
    final options = [
      correctAnswer,
      'Option A',
      'Option B', 
      'Option C',
      'Option D'
    ];
    
    return {
      'id': 'qz_$id',
      'learningUnitId': learningUnitId,
      'question': question,
      'options': options,
      'correctAnswerIndex': 0, // The correct answer is always at index 0
      'explanation': explanation,
      'imageUrl': imageUrl,
      'timeLimit': timeLimit,
    };
  }
}

// Manual Hive adapter for Question
class QuestionAdapter extends TypeAdapter<Question> {
  @override
  final int typeId = 8;

  @override
  Question read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Question(
      id: fields[0] as String,
      learningUnitId: fields[1] as String,
      question: fields[2] as String,
      correctAnswer: fields[3] as String,
      hint: fields[4] as String?,
      explanation: fields[5] as String?,
      imageUrl: fields[6] as String?,
      audioUrl: fields[7] as String?,
      difficulty: fields[8] as Difficulty,
      tags: (fields[9] as List?)?.cast<String>() ?? [],
      timeLimit: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Question obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.learningUnitId)
      ..writeByte(2)
      ..write(obj.question)
      ..writeByte(3)
      ..write(obj.correctAnswer)
      ..writeByte(4)
      ..write(obj.hint)
      ..writeByte(5)
      ..write(obj.explanation)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.audioUrl)
      ..writeByte(8)
      ..write(obj.difficulty)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.timeLimit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}