import 'package:flutter_test/flutter_test.dart';
import 'package:learning_kashmir_shaivism/services/cache_service.dart';

/// Unit tests for CacheService
void main() {
  late CacheService cacheService;

  setUp(() {
    cacheService = CacheService();
    cacheService.clear();
  });

  group('CacheService Tests', () {
    test('should store and retrieve value', () {
      cacheService.set('key1', 'value1');
      
      final result = cacheService.get<String>('key1');
      
      expect(result, 'value1');
    });

    test('should return null for non-existent key', () {
      final result = cacheService.get<String>('nonexistent');
      
      expect(result, isNull);
    });

    test('should handle different types', () {
      cacheService.set('string', 'text');
      cacheService.set('int', 42);
      cacheService.set('double', 3.14);
      cacheService.set('bool', true);
      
      expect(cacheService.get<String>('string'), 'text');
      expect(cacheService.get<int>('int'), 42);
      expect(cacheService.get<double>('double'), 3.14);
      expect(cacheService.get<bool>('bool'), true);
    });

    test('should expire cached values after TTL', () async {
      cacheService.set(
        'expiring',
        'value',
        ttl: const Duration(milliseconds: 100),
      );
      
      expect(cacheService.get<String>('expiring'), 'value');
      
      await Future.delayed(const Duration(milliseconds: 150));
      
      expect(cacheService.get<String>('expiring'), isNull);
    });

    test('should remove specific key', () {
      cacheService.set('key1', 'value1');
      cacheService.set('key2', 'value2');
      
      cacheService.remove('key1');
      
      expect(cacheService.get<String>('key1'), isNull);
      expect(cacheService.get<String>('key2'), 'value2');
    });

    test('should clear all cached items', () {
      cacheService.set('key1', 'value1');
      cacheService.set('key2', 'value2');
      cacheService.set('key3', 'value3');
      
      cacheService.clear();
      
      expect(cacheService.size, 0);
      expect(cacheService.get<String>('key1'), isNull);
      expect(cacheService.get<String>('key2'), isNull);
      expect(cacheService.get<String>('key3'), isNull);
    });

    test('should check if key exists', () {
      cacheService.set('key1', 'value1');
      
      expect(cacheService.has('key1'), true);
      expect(cacheService.has('nonexistent'), false);
    });

    test('should return correct cache size', () {
      expect(cacheService.size, 0);
      
      cacheService.set('key1', 'value1');
      expect(cacheService.size, 1);
      
      cacheService.set('key2', 'value2');
      expect(cacheService.size, 2);
      
      cacheService.remove('key1');
      expect(cacheService.size, 1);
    });

    test('should handle complex objects', () {
      final testData = {
        'name': 'Test',
        'value': 42,
        'nested': {'inner': 'value'},
      };
      
      cacheService.set('complex', testData);
      
      final result = cacheService.get<Map<String, dynamic>>('complex');
      
      expect(result, testData);
      expect(result?['name'], 'Test');
      expect(result?['nested'], {'inner': 'value'});
    });

    test('should not accept empty keys', () {
      cacheService.set('', 'value');
      
      expect(cacheService.size, 0);
    });

    test('should update existing key', () {
      cacheService.set('key1', 'value1');
      expect(cacheService.get<String>('key1'), 'value1');
      
      cacheService.set('key1', 'value2');
      expect(cacheService.get<String>('key1'), 'value2');
      expect(cacheService.size, 1);
    });

    test('should handle null values', () {
      cacheService.set('nullable', null);
      
      expect(cacheService.has('nullable'), true);
      expect(cacheService.get('nullable'), isNull);
    });
  });
}
