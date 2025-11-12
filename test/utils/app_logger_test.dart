import 'package:flutter_test/flutter_test.dart';
import 'package:learning_kashmir_shaivism/utils/app_logger.dart';

/// Unit tests for AppLogger
void main() {
  setUp(() {
    AppLogger.setEnabled(true);
    AppLogger.setLogLevel(LogLevel.debug);
  });

  group('AppLogger Tests', () {
    test('should log debug messages', () {
      expect(() => AppLogger.debug('Debug message'), returnsNormally);
    });

    test('should log info messages', () {
      expect(() => AppLogger.info('Info message'), returnsNormally);
    });

    test('should log warning messages', () {
      expect(() => AppLogger.warning('Warning message'), returnsNormally);
    });

    test('should log error messages', () {
      expect(
        () => AppLogger.error('Error message', error: Exception('Test')),
        returnsNormally,
      );
    });

    test('should accept optional tags', () {
      expect(
        () => AppLogger.debug('Tagged message', tag: 'TestTag'),
        returnsNormally,
      );
    });

    test('should accept optional data', () {
      expect(
        () => AppLogger.info('Message with data', data: {'key': 'value'}),
        returnsNormally,
      );
    });

    test('should accept error and stack trace', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      expect(
        () => AppLogger.error(
          'Error occurred',
          error: error,
          stackTrace: stackTrace,
        ),
        returnsNormally,
      );
    });

    test('should respect log level', () {
      AppLogger.setLogLevel(LogLevel.error);

      // These should be filtered out
      expect(() => AppLogger.debug('Should not appear'), returnsNormally);
      expect(() => AppLogger.info('Should not appear'), returnsNormally);
      expect(() => AppLogger.warning('Should not appear'), returnsNormally);

      // This should appear
      expect(() => AppLogger.error('Should appear'), returnsNormally);
    });

    test('should disable all logging when setEnabled(false)', () {
      AppLogger.setEnabled(false);

      expect(() => AppLogger.debug('Should not appear'), returnsNormally);
      expect(() => AppLogger.info('Should not appear'), returnsNormally);
      expect(() => AppLogger.warning('Should not appear'), returnsNormally);
      expect(() => AppLogger.error('Should not appear'), returnsNormally);

      AppLogger.setEnabled(true);
    });

    test('should have correct log level order', () {
      expect(LogLevel.debug.level < LogLevel.info.level, true);
      expect(LogLevel.info.level < LogLevel.warning.level, true);
      expect(LogLevel.warning.level < LogLevel.error.level, true);
    });

    test('should have emojis for each log level', () {
      expect(LogLevel.debug.emoji, '🔍');
      expect(LogLevel.info.emoji, 'ℹ️');
      expect(LogLevel.warning.emoji, '⚠️');
      expect(LogLevel.error.emoji, '❌');
    });
  });
}
