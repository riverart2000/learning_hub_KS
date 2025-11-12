import 'package:hive/hive.dart';

part 'flashcard.g.dart';

@HiveType(typeId: 3)
class Flashcard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String learningUnitId;

  @HiveField(2)
  String front;

  @HiveField(3)
  String back;

  @HiveField(4)
  String? hint;

  @HiveField(5)
  String? imageUrl;

  @HiveField(6)
  String? audioUrl;

  Flashcard({
    required this.id,
    required this.learningUnitId,
    required this.front,
    required this.back,
    this.hint,
    this.imageUrl,
    this.audioUrl,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      learningUnitId: json['learningUnitId'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      hint: json['hint'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'learningUnitId': learningUnitId,
      'front': front,
      'back': back,
      'hint': hint,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }
}

