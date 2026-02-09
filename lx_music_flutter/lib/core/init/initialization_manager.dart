import 'dart:async';
import 'package:lx_music_flutter/utils/logger.dart';

/// Represents an initialization task with dependencies
class InitializationTask {
  final String name;
  final Future<void> Function() initializer;
  final List<String> dependencies;
  final bool isCritical;
  final Future<void> Function()? fallback;
  final int maxRetries;
  bool isCompleted = false;

  InitializationTask({
    required this.name,
    required this.initializer,
    this.dependencies = const [],
    this.isCritical = false,
    this.fallback,
    this.maxRetries = 3, // Default to 3 retries for recoverable failures
  });
}

/// Manages the initialization of app components with dependency tracking
class InitializationManager {
  final List<InitializationTask> _tasks = [];
  final Set<String> _completedTasks = <String>{};

  /// Adds a task to the initialization queue
  void addTask(InitializationTask task) {
    _tasks.add(task);
  }

  /// Executes all initialization tasks respecting dependencies
  Future<void> execute() async {
    Logger.info('Starting initialization with dependency management');

    // Keep track of tasks that have been processed
    final List<String> processedTasks = [];

    // Keep processing tasks until all are completed or no progress is made
    int lastProcessedCount = 0;

    while (_completedTasks.length < _tasks.length) {
      int currentProcessedCount = _completedTasks.length;

      // Find tasks whose dependencies are all satisfied
      for (final task in _tasks) {
        if (_completedTasks.contains(task.name)) {
          continue; // Already completed
        }

        // Check if all dependencies are satisfied
        bool allDependenciesMet = true;
        for (final dependency in task.dependencies) {
          if (!_completedTasks.contains(dependency)) {
            allDependenciesMet = false;
            break;
          }
        }

        if (allDependenciesMet) {
          await _executeTaskWithRetry(task);
        }
      }

      // If no progress was made, there might be circular dependencies
      if (currentProcessedCount == lastProcessedCount) {
        Logger.warn(
            'No progress made in initialization - possible circular dependency');
        // Try to initialize any remaining tasks that don't have dependencies
        for (final task in _tasks) {
          if (!_completedTasks.contains(task.name) &&
              task.dependencies.isEmpty) {
            await _executeTaskWithRetry(task);
          }
        }

        // If still no progress, break to avoid infinite loop
        if (currentProcessedCount == _completedTasks.length) {
          Logger.error(
              'Unable to make progress in initialization - breaking loop');
          break;
        }
      }

      lastProcessedCount = _completedTasks.length;
    }

    Logger.info(
        'Initialization completed. ${_completedTasks.length}/${_tasks.length} tasks completed.');
  }

  /// Executes a task with retry logic
  Future<void> _executeTaskWithRetry(InitializationTask task) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt <= task.maxRetries) {
      try {
        Logger.debug(
            'Initializing: ${task.name} (Attempt ${attempt + 1}/${task.maxRetries + 1})');
        await task.initializer();

        _completedTasks.add(task.name);
        Logger.info('Completed initialization: ${task.name}');
        return; // Success, exit the retry loop
      } catch (error, stackTrace) {
        lastException = error as Exception;
        attempt++;

        if (attempt <= task.maxRetries) {
          Logger.warn(
              'Failed to initialize ${task.name} (attempt $attempt), retrying in ${attempt} seconds...');
          // Wait before retrying, with exponential backoff
          await Future.delayed(Duration(seconds: attempt));
        } else {
          Logger.error(
              'Failed to initialize ${task.name} after ${task.maxRetries + 1} attempts: $error',
              stackTrace);

          // Handle fallback if available
          if (task.fallback != null) {
            try {
              Logger.info('Attempting fallback for ${task.name}');
              await task.fallback!();
              _completedTasks.add(task.name);
              Logger.info('Fallback completed for ${task.name}');
              return; // Success with fallback
            } catch (fallbackError, fallbackStackTrace) {
              Logger.error('Fallback failed for ${task.name}: $fallbackError',
                  fallbackStackTrace);

              // If task is critical, rethrow the error
              if (task.isCritical) {
                Logger.error(
                    'Critical task ${task.name} failed and fallback also failed');
                rethrow;
              }
            }
          } else if (task.isCritical) {
            // If task is critical and no fallback, rethrow the error
            Logger.error('Critical task ${task.name} failed');
            rethrow;
          } else {
            // For non-critical tasks, continue with other tasks
            Logger.warn(
                'Non-critical task ${task.name} failed, continuing with other tasks');
            // Mark as completed anyway to allow other tasks to proceed
            _completedTasks.add(task.name);
          }
        }
      }
    }
  }

  /// Checks if a specific task is completed
  bool isTaskCompleted(String taskName) {
    return _completedTasks.contains(taskName);
  }
}
