import 'package:flutter_test/flutter_test.dart';
import 'package:learning_kashmir_shaivism/models/user.dart';

/// Unit tests for User model with validation
void main() {
  group('User Model Tests', () {
    test('should create a valid user', () {
      final user = User(
        id: 'test123',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        totalScore: 100.0,
        highScore: 50.0,
      );

      expect(user.id, 'test123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.totalScore, 100.0);
      expect(user.highScore, 50.0);
    });

    test('should throw error for empty id', () {
      expect(
        () => User(
          id: '',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for empty name', () {
      expect(
        () => User(
          id: 'test123',
          name: '',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for empty email', () {
      expect(
        () => User(
          id: 'test123',
          name: 'Test User',
          email: '',
          createdAt: DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for invalid email format', () {
      expect(
        () => User(
          id: 'test123',
          name: 'Test User',
          email: 'invalid-email',
          createdAt: DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for negative total score', () {
      expect(
        () => User(
          id: 'test123',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          totalScore: -10.0,
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for negative high score', () {
      expect(
        () => User(
          id: 'test123',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          highScore: -5.0,
        ),
        throwsArgumentError,
      );
    });

    test('should create user from JSON', () {
      final json = {
        'id': 'test123',
        'name': 'Test User',
        'email': 'test@example.com',
        'createdAt': DateTime.now().toIso8601String(),
        'totalScore': 100.0,
        'highScore': 50.0,
      };

      final user = User.fromJson(json);

      expect(user.id, 'test123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.totalScore, 100.0);
      expect(user.highScore, 50.0);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': 'test123',
        'name': 'Test User',
        'email': 'test@example.com',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final user = User.fromJson(json);

      expect(user.totalScore, 0.0);
      expect(user.highScore, 0.0);
    });

    test('should convert user to JSON', () {
      final user = User(
        id: 'test123',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2025, 1, 1),
        totalScore: 100.0,
        highScore: 50.0,
      );

      final json = user.toJson();

      expect(json['id'], 'test123');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['totalScore'], 100.0);
      expect(json['highScore'], 50.0);
      expect(json['createdAt'], isNotNull);
    });

    test('should create copy with updated fields', () {
      final user = User(
        id: 'test123',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        totalScore: 100.0,
        highScore: 50.0,
      );

      final updatedUser = user.copyWith(
        name: 'Updated User',
        totalScore: 200.0,
      );

      expect(updatedUser.name, 'Updated User');
      expect(updatedUser.totalScore, 200.0);
      expect(updatedUser.id, user.id);
      expect(updatedUser.email, user.email);
    });

    test('should correctly implement equality', () {
      final user1 = User(
        id: 'test123',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );

      final user2 = User(
        id: 'test123',
        name: 'Different Name',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('should correctly implement toString', () {
      final user = User(
        id: 'test123',
        name: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
        totalScore: 100.0,
        highScore: 50.0,
      );

      final str = user.toString();

      expect(str, contains('test123'));
      expect(str, contains('Test User'));
      expect(str, contains('test@example.com'));
    });
  });
}
