import 'package:hive/hive.dart';

part 'user.g.dart';

/// User model with input validation and error handling
@HiveType(typeId: 7)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  double totalScore;

  @HiveField(5)
  double highScore;

  // Photo functionality removed for privacy compliance

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.totalScore = 0.0,
    this.highScore = 0.0,
  }) {
    _validate();
  }

  /// Validates user data for consistency and correctness
  void _validate() {
    if (id.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('User name cannot be empty');
    }
    if (email.trim().isEmpty) {
      throw ArgumentError('User email cannot be empty');
    }
    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format: $email');
    }
    if (totalScore < 0) {
      throw ArgumentError('Total score cannot be negative');
    }
    if (highScore < 0) {
      throw ArgumentError('High score cannot be negative');
    }
  }

  /// Validates email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
        highScore: (json['highScore'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      throw FormatException('Failed to parse User from JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'totalScore': totalScore,
      'highScore': highScore,
    };
  }

  /// Creates a copy of the user with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    double? totalScore,
    double? highScore,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      totalScore: totalScore ?? this.totalScore,
      highScore: highScore ?? this.highScore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, totalScore: $totalScore, highScore: $highScore)';
  }
}

