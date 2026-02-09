import 'package:flutter/foundation.dart';

/// Simple logging utility to mirror the logging functionality from the React Native app
class Logger {
  static bool _isEnabled = true;

  /// Initializes the logger
  static void initialize() {
    debugPrint('Logger initialized');
  }

  /// Logs an info message
  static void info(String message) {
    if (_isEnabled) {
      debugPrint('[INFO] $message');
    }
  }

  /// Logs a warning message
  static void warn(String message) {
    if (_isEnabled) {
      debugPrint('[WARN] $message');
    }
  }

  /// Logs an error message
  static void error(String message, [StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (stackTrace != null) {
      debugPrint('$stackTrace');
    }
  }

  /// Logs a debug message
  static void debug(String message) {
    if (_isEnabled && kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
  }
}