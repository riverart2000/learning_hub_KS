import 'package:flutter/foundation.dart';

/// Conditional logging utility - only logs in debug mode
class DebugLogger {
  /// Log message (only in debug mode)
  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
  
  /// Legacy print replacement (only logs in debug mode)
  static void print(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}

/// Global function to replace print - only logs in debug mode
void conditionalPrint(dynamic message) {
  if (kDebugMode) {
    debugPrint(message?.toString() ?? 'null');
  }
}









