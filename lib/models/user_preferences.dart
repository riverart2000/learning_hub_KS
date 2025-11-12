import 'package:hive/hive.dart';
import 'learning_unit.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 6)
class UserPreferences extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  List<String> preferredCategories;

  @HiveField(3)
  Difficulty difficultyPreference;

  @HiveField(4)
  bool studyRemindersEnabled;

  @HiveField(5)
  bool isDarkMode;

  @HiveField(6)
  String colorScheme; // 'green' or 'orange'

  UserPreferences({
    required this.id,
    required this.userId,
    required this.preferredCategories,
    required this.difficultyPreference,
    required this.studyRemindersEnabled,
    this.isDarkMode = false,
    this.colorScheme = 'green',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'] as String,
      userId: json['userId'] as String,
      preferredCategories: List<String>.from(json['preferredCategories'] as List),
      difficultyPreference: Difficulty.values.firstWhere(
        (e) => e.name == json['difficultyPreference'],
        orElse: () => Difficulty.beginner,
      ),
      studyRemindersEnabled: json['studyRemindersEnabled'] as bool,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      colorScheme: json['colorScheme'] as String? ?? 'green',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'preferredCategories': preferredCategories,
      'difficultyPreference': difficultyPreference.name,
      'studyRemindersEnabled': studyRemindersEnabled,
      'isDarkMode': isDarkMode,
      'colorScheme': colorScheme,
    };
  }
}

