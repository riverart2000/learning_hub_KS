import 'package:hive/hive.dart';

part 'learning_unit.g.dart';

@HiveType(typeId: 14)
enum LearningUnitType {
  @HiveField(0)
  flashcard,
  @HiveField(1)
  quiz,
  @HiveField(2)
  lesson,
  @HiveField(3)
  video,
  @HiveField(4)
  exercise,
  @HiveField(5)
  mixed,
}

@HiveType(typeId: 15)
enum Difficulty {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
}

@HiveType(typeId: 2)
class LearningUnit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subCategoryId;

  @HiveField(2)
  LearningUnitType type;

  @HiveField(3)
  String title;

  @HiveField(4)
  Map<String, dynamic> content;

  @HiveField(5)
  Difficulty difficulty;

  @HiveField(6)
  List<String> tags;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  LearningUnit({
    required this.id,
    required this.subCategoryId,
    required this.type,
    required this.title,
    required this.content,
    required this.difficulty,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningUnit.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return LearningUnit(
      id: json['id'] as String,
      subCategoryId: json['subCategoryId'] as String,
      type: LearningUnitType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LearningUnitType.flashcard,
      ),
      title: json['title'] as String,
      content: json['content'] != null 
          ? Map<String, dynamic>.from(json['content'] as Map)
          : {},
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      tags: List<String>.from(json['tags'] as List),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : now,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subCategoryId': subCategoryId,
      'type': type.name,
      'title': title,
      'content': content,
      'difficulty': difficulty.name,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Hive type adapters for enums
@HiveType(typeId: 10)
enum HiveLearningUnitType {
  @HiveField(0)
  flashcard,
  @HiveField(1)
  quiz,
  @HiveField(2)
  lesson,
  @HiveField(3)
  video,
  @HiveField(4)
  exercise,
  @HiveField(5)
  mixed,
}

@HiveType(typeId: 11)
enum HiveDifficulty {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
}

