import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lx_music_flutter/utils/logger.dart';

/// Represents an initialization error
class InitializationError {
  final String taskName;
  final String errorMessage;
  final DateTime timestamp;
  final StackTrace? stackTrace;
  final bool isCritical;

  InitializationError({
    required this.taskName,
    required this.errorMessage,
    required this.isCritical,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  /// Converts the error to a map representation
  Map<String, dynamic> toMap() {
    return {
      'taskName': taskName,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
      'isCritical': isCritical,
      'stackTrace': stackTrace?.toString(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toMap());
  }
}

/// Reports initialization errors
class InitializationErrorReporter {
  static final List<InitializationError> _errors = [];
  static bool _isReportingEnabled = true;

  /// Reports an initialization error
  static void reportError({
    required String taskName,
    required String errorMessage,
    required bool isCritical,
    StackTrace? stackTrace,
  }) {
    if (!_isReportingEnabled) return;

    final error = InitializationError(
      taskName: taskName,
      errorMessage: errorMessage,
      isCritical: isCritical,
      stackTrace: stackTrace,
    );

    _errors.add(error);
    Logger.error(
        'Initialization Error [${isCritical ? 'CRITICAL' : 'NON-CRITICAL'}]: ${error.taskName} - ${error.errorMessage}',
        stackTrace);

    // For critical errors, we might want to send to a remote service
    if (isCritical) {
      _handleCriticalError(error);
    }
  }

  /// Handles critical errors specially
  static void _handleCriticalError(InitializationError error) {
    // In a real implementation, this might send the error to a crash reporting service
    Logger.error(
        'CRITICAL INITIALIZATION ERROR: ${error.taskName} - ${error.errorMessage}');
  }

  /// Gets all reported errors
  static List<InitializationError> getErrors() {
    return List.unmodifiable(_errors);
  }

  /// Gets only critical errors
  static List<InitializationError> getCriticalErrors() {
    return List.unmodifiable(
        _errors.where((error) => error.isCritical).toList());
  }

  /// Gets only non-critical errors
  static List<InitializationError> getNonCriticalErrors() {
    return List.unmodifiable(
        _errors.where((error) => !error.isCritical).toList());
  }

  /// Checks if there were any critical errors
  static bool hasCriticalErrors() {
    return _errors.any((error) => error.isCritical);
  }

  /// Checks if there were any errors at all
  static bool hasErrors() {
    return _errors.isNotEmpty;
  }

  /// Clears all reported errors
  static void clearErrors() {
    _errors.clear();
  }

  /// Disables error reporting
  static void disableReporting() {
    _isReportingEnabled = false;
  }

  /// Enables error reporting
  static void enableReporting() {
    _isReportingEnabled = true;
  }

  /// Generates a summary of initialization errors
  static String generateErrorSummary() {
    if (_errors.isEmpty) {
      return 'No initialization errors occurred.';
    }

    final criticalErrors = getCriticalErrors();
    final nonCriticalErrors = getNonCriticalErrors();

    final buffer = StringBuffer();
    buffer.writeln('Initialization Error Summary:');
    buffer.writeln('Total Errors: ${_errors.length}');
    buffer.writeln('Critical Errors: ${criticalErrors.length}');
    buffer.writeln('Non-Critical Errors: ${nonCriticalErrors.length}');
    buffer.writeln('');

    if (criticalErrors.isNotEmpty) {
      buffer.writeln('Critical Errors:');
      for (final error in criticalErrors) {
        buffer.writeln('  - ${error.taskName}: ${error.errorMessage}');
      }
      buffer.writeln('');
    }

    if (nonCriticalErrors.isNotEmpty) {
      buffer.writeln('Non-Critical Errors:');
      for (final error in nonCriticalErrors) {
        buffer.writeln('  - ${error.taskName}: ${error.errorMessage}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
