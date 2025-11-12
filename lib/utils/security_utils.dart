import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../utils/app_logger.dart';

/// Security utilities for data validation and sanitization.
/// Follows security best practices and prevents common vulnerabilities.
class SecurityUtils {
  SecurityUtils._();

  /// Validates and sanitizes user input to prevent injection attacks
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    // Remove potentially dangerous characters
    String sanitized = input
        .replaceAll(RegExp(r'[<>]'), '') // Prevent HTML injection
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control characters
        .trim();

    return sanitized;
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    return emailRegex.hasMatch(email);
  }

  /// Checks if a string contains potentially malicious patterns
  static bool containsSuspiciousPatterns(String input) {
    final suspiciousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false), // Event handlers
      RegExp(r'eval\(', caseSensitive: false),
      RegExp(r'expression\(', caseSensitive: false),
      RegExp(r'\.\./'), // Path traversal
      RegExp(r'\.\.\\'), // Path traversal (Windows)
    ];

    for (final pattern in suspiciousPatterns) {
      if (pattern.hasMatch(input)) {
        AppLogger.warning(
          'Suspicious pattern detected in input',
          tag: 'SecurityUtils',
        );
        return true;
      }
    }

    return false;
  }

  /// Generates a secure hash of a string (for non-password purposes)
  static String generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validates that a file path doesn't contain path traversal attempts
  static bool isValidFilePath(String path) {
    if (path.isEmpty) return false;

    // Check for path traversal patterns
    if (path.contains('..') || path.contains('~')) {
      AppLogger.warning(
        'Path traversal attempt detected',
        tag: 'SecurityUtils',
        data: {'path': path},
      );
      return false;
    }

    return true;
  }

  /// Validates JSON structure to prevent malformed data
  static bool isValidJson(String jsonString) {
    if (jsonString.isEmpty) return false;

    try {
      json.decode(jsonString);
      return true;
    } catch (e) {
      AppLogger.warning(
        'Invalid JSON detected',
        tag: 'SecurityUtils',
      );
      return false;
    }
  }

  /// Limits string length to prevent buffer overflow attacks
  static String limitLength(String input, int maxLength) {
    if (input.length <= maxLength) return input;

    AppLogger.debug(
      'String truncated for security',
      tag: 'SecurityUtils',
      data: {'original': input.length, 'max': maxLength},
    );

    return input.substring(0, maxLength);
  }

  /// Validates that a string contains only alphanumeric characters and common punctuation
  static bool isAlphanumericSafe(String input) {
    final safePattern = RegExp(r'^[a-zA-Z0-9\s\.,!?\-_@]+$');
    return safePattern.hasMatch(input);
  }

  /// Escapes HTML special characters
  static String escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Validates URL format
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Checks if an ID is in a valid format (alphanumeric with underscores/hyphens)
  static bool isValidId(String id) {
    if (id.isEmpty) return false;

    final idPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    return idPattern.hasMatch(id) && id.length <= 100;
  }

  /// Sanitizes filename to prevent directory traversal and invalid characters
  static String sanitizeFilename(String filename) {
    if (filename.isEmpty) return 'unnamed';

    // Remove path separators and special characters
    String sanitized = filename
        .replaceAll(RegExp(r'[/\\:*?"<>|]'), '_')
        .replaceAll('..', '_')
        .trim();

    // Limit length
    if (sanitized.length > 255) {
      sanitized = sanitized.substring(0, 255);
    }

    return sanitized.isEmpty ? 'unnamed' : sanitized;
  }

  /// Validates that a number is within a safe range
  static bool isNumberInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }

  /// Checks for SQL injection patterns (for additional safety)
  static bool containsSqlInjectionPatterns(String input) {
    final sqlPatterns = [
      RegExp(r'\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER)\b', caseSensitive: false),
      RegExp(r'--'), // SQL comment
      RegExp(r';'), // Statement terminator
      RegExp(r'\bOR\b.*=.*', caseSensitive: false), // OR condition
      RegExp(r'\bUNION\b', caseSensitive: false),
    ];

    for (final pattern in sqlPatterns) {
      if (pattern.hasMatch(input)) {
        AppLogger.warning(
          'Potential SQL injection pattern detected',
          tag: 'SecurityUtils',
        );
        return true;
      }
    }

    return false;
  }

  /// Validates configuration data structure
  static bool isValidConfig(Map<String, dynamic> config, List<String> requiredKeys) {
    if (config.isEmpty) return false;

    for (final key in requiredKeys) {
      if (!config.containsKey(key)) {
        AppLogger.warning(
          'Missing required config key',
          tag: 'SecurityUtils',
          data: {'key': key},
        );
        return false;
      }
    }

    return true;
  }
}
