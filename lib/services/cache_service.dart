import 'dart:async';
import '../utils/app_logger.dart';

/// In-memory caching service for improved performance.
/// 
/// Implements automatic cache expiration and memory management.
/// Follows singleton pattern for consistent cache across the app.
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal() {
    AppLogger.debug('CacheService initialized', tag: 'CacheService');
    _startCleanupTimer();
  }

  final Map<String, _CacheEntry> _cache = {};
  Timer? _cleanupTimer;
  
  // Default cache expiration: 5 minutes
  static const Duration _defaultTTL = Duration(minutes: 5);
  
  // Maximum cache size (number of entries)
  static const int _maxCacheSize = 100;

  /// Stores a value in the cache with optional TTL (time-to-live)
  void set<T>(String key, T value, {Duration? ttl}) {
    if (key.trim().isEmpty) {
      AppLogger.warning('Attempted to cache with empty key', tag: 'CacheService');
      return;
    }

    // Enforce cache size limit
    if (_cache.length >= _maxCacheSize && !_cache.containsKey(key)) {
      _evictOldestEntry();
    }

    final expiresAt = DateTime.now().add(ttl ?? _defaultTTL);
    _cache[key] = _CacheEntry(value, expiresAt);
    
    AppLogger.debug(
      'Cached item',
      tag: 'CacheService',
      data: {'key': key, 'expiresAt': expiresAt.toIso8601String()},
    );
  }

  /// Retrieves a value from the cache
  /// Returns null if key doesn't exist or value has expired
  T? get<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) {
      AppLogger.debug('Cache miss', tag: 'CacheService', data: {'key': key});
      return null;
    }

    // Check if expired
    if (DateTime.now().isAfter(entry.expiresAt)) {
      AppLogger.debug('Cache expired', tag: 'CacheService', data: {'key': key});
      _cache.remove(key);
      return null;
    }

    AppLogger.debug('Cache hit', tag: 'CacheService', data: {'key': key});
    return entry.value as T?;
  }

  /// Removes a specific item from the cache
  void remove(String key) {
    _cache.remove(key);
    AppLogger.debug('Cache entry removed', tag: 'CacheService', data: {'key': key});
  }

  /// Clears all items from the cache
  void clear() {
    final count = _cache.length;
    _cache.clear();
    AppLogger.info('Cache cleared', tag: 'CacheService', data: {'itemsCleared': count});
  }

  /// Checks if a key exists in the cache and hasn't expired
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return false;
    }
    
    return true;
  }

  /// Returns the current cache size
  int get size => _cache.length;

  /// Evicts the oldest entry to make room for new ones
  void _evictOldestEntry() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.expiresAt.isBefore(oldestTime)) {
        oldestTime = entry.value.expiresAt;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
      AppLogger.debug('Evicted oldest cache entry', tag: 'CacheService', data: {'key': oldestKey});
    }
  }

  /// Starts a periodic timer to clean up expired entries
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _cleanupExpiredEntries();
    });
  }

  /// Removes all expired entries from the cache
  void _cleanupExpiredEntries() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _cache.entries) {
      if (now.isAfter(entry.value.expiresAt)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      AppLogger.debug(
        'Cleaned up expired cache entries',
        tag: 'CacheService',
        data: {'count': keysToRemove.length},
      );
    }
  }

  /// Disposes the cache service and cancels timers
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
    AppLogger.debug('CacheService disposed', tag: 'CacheService');
  }
}

/// Internal cache entry with expiration time
class _CacheEntry {
  final Object? value;
  final DateTime expiresAt;

  _CacheEntry(this.value, this.expiresAt);
}
