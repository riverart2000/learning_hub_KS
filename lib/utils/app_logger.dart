import 'package:flutter/foundation.dart';
import 'dart:io';

/// Centralized logging service with configurable levels and structured output.
/// 
/// Usage:
/// ```dart
/// AppLogger.debug('Debug message');
/// AppLogger.info('Info message');
/// AppLogger.warning('Warning message');
/// AppLogger.error('Error message', error: exception, stackTrace: stack);
/// ```
class AppLogger {
  static LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static bool _isEnabled = true;
  
  // Singleton pattern for configuration
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  /// Sets the minimum log level to display
  static void setLogLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// Enables or disables all logging
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Disables logging on Android in production mode
  static void disableOnAndroidProduction() {
    if (!kIsWeb && Platform.isAndroid && kReleaseMode) {
      _isEnabled = false;
    }
  }

  /// Debug level logging - detailed information for debugging
  static void debug(String message, {String? tag, Object? data}) {
    _log(LogLevel.debug, message, tag: tag, data: data);
  }

  /// Info level logging - general informational messages
  static void info(String message, {String? tag, Object? data}) {
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  /// Warning level logging - potentially harmful situations
  static void warning(String message, {String? tag, Object? data}) {
    _log(LogLevel.warning, message, tag: tag, data: data);
  }

  /// Error level logging - error events with optional exception details
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Internal logging implementation
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_isEnabled || level.level < _currentLevel.level) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.emoji;
    final tagStr = tag != null ? '[$tag] ' : '';
    final logMessage = '$levelStr $timestamp $tagStr$message';

    // Use debugPrint for better handling in Flutter
    debugPrint(logMessage);

    if (data != null) {
      debugPrint('  Data: $data');
    }

    if (error != null) {
      debugPrint('  Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('  StackTrace:\n$stackTrace');
    }
  }
}

/// Log levels in ascending order of severity
enum LogLevel {
  debug(0, '🔍'),
  info(1, 'ℹ️'),
  warning(2, '⚠️'),
  error(3, '❌');

  final int level;
  final String emoji;

  const LogLevel(this.level, this.emoji);
}
