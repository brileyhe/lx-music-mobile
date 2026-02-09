import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../utils/logger.dart';
import 'theme_initializer.dart';
import 'i18n_initializer.dart';
import 'player_initializer.dart';
import 'data_initializer.dart';
import 'common_initializer.dart';
import 'sync_initializer.dart';
import 'user_api_initializer.dart';
import 'initialization_manager.dart';
import 'initialization_progress_tracker.dart';
import 'initialization_error_reporter.dart';

/// Handles the initialization of the app, mirroring the structure of the React Native app
class AppInitializer {
  static bool _isInitialized = false;

  /// Initializes the app with all necessary components
  static Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('Starting app initialization...');

    try {
      // Initialize logging first as it's needed for other initializers
      Logger.initialize();
      Logger.info('Logger initialized');

      // Create the initialization manager
      final manager = InitializationManager();

      // Add initialization tasks with their dependencies
      manager.addTask(InitializationTask(
        name: 'Theme',
        initializer: _initializeWithTracking('Theme', ThemeInitializer.initialize),
        isCritical: true, // Theme is critical for UI
        fallback: () async {
          Logger.warn('Using default theme as fallback');
          // Default theme is already applied by Flutter
        },
      ));

      manager.addTask(InitializationTask(
        name: 'Common State',
        initializer: _initializeWithTracking('Common State', CommonInitializer.initialize),
        dependencies: [], // No dependencies
        isCritical: true, // Common state is critical
        fallback: () async {
          Logger.warn('Common state initialization failed, using defaults');
          // Use default common state values
        },
      ));

      manager.addTask(InitializationTask(
        name: 'Internationalization',
        initializer: _initializeWithTracking('Internationalization', I18nInitializer.initialize),
        dependencies: ['Common State'], // May depend on common state
        isCritical: false, // Not critical, can use default language
        fallback: () async {
          Logger.warn('Using default language as fallback');
          // Default language is already set
        },
      ));

      manager.addTask(InitializationTask(
        name: 'User API',
        initializer: _initializeWithTracking('User API', UserApiInitializer.initialize),
        dependencies: ['Common State'], // May depend on common state
        isCritical: false, // Not critical, user can still use offline features
        fallback: () async {
          Logger.warn('User API failed, user will be logged out');
          // Handle user API failure gracefully
        },
      ));

      manager.addTask(InitializationTask(
        name: 'Data',
        initializer: _initializeWithTracking('Data', DataInitializer.initialize),
        dependencies: ['Common State'], // Depends on common state
        isCritical: true, // Data is critical for app functionality
        fallback: () async {
          Logger.warn('Data initialization failed, using empty state');
          // Initialize with empty/default data
        },
      ));

      manager.addTask(InitializationTask(
        name: 'Player',
        initializer: _initializeWithTracking('Player', PlayerInitializer.initialize),
        dependencies: ['Common State'], // Depends on common state
        isCritical: true, // Player is critical for music functionality
        fallback: () async {
          Logger.warn('Player initialization failed, music features disabled');
          // Disable music features
        },
      ));

      manager.addTask(InitializationTask(
        name: 'Sync',
        initializer: _initializeWithTracking('Sync', SyncInitializer.initialize),
        dependencies: ['User API', 'Data'], // Depends on user API and data
        isCritical: false, // Not critical, sync can happen later
        fallback: () async {
          Logger.warn('Sync failed, will retry later');
          // Schedule sync for later
        },
      ));

      // Execute all initialization tasks respecting dependencies
      await manager.execute();

      _isInitialized = true;
      Logger.info('App initialization completed successfully');
    } catch (error, stackTrace) {
      Logger.error('App initialization failed: $error', stackTrace);
      rethrow;
    }
  }

  // Static tracker instance to share across the initialization process
  static final InitializationProgressTracker _progressTracker = InitializationProgressTracker();

  /// Wrapper function to track initialization progress and report errors
  static Future<void> Function() _initializeWithTracking(String stepName, Future<void> Function() initializer) {
    return () async {
      try {
        Logger.info('Starting initialization of $stepName');
        _progressTracker.addStep(stepName, 'Initializing $stepName');
        _progressTracker.startStep(stepName);
        
        await initializer();
        
        _progressTracker.completeStep(stepName);
        Logger.info('Completed initialization of $stepName');
      } catch (error, stackTrace) {
        _progressTracker.failStep(stepName, error.toString());
        
        // Determine if this is a critical task based on the initialization manager
        // For now, we'll assume certain tasks are critical
        bool isCritical = _isCriticalTask(stepName);
        
        InitializationErrorReporter.reportError(
          taskName: stepName,
          errorMessage: error.toString(),
          isCritical: isCritical,
          stackTrace: stackTrace,
        );
        
        Logger.error('Failed to initialize $stepName: $error', stackTrace);
        rethrow;
      }
    };
  }

  /// Determines if a task is critical
  static bool _isCriticalTask(String taskName) {
    // Define critical tasks - these would prevent the app from functioning properly
    const criticalTasks = {
      'Theme',
      'Common State',
      'Data',
      'Player',
    };
    return criticalTasks.contains(taskName);
  }

  /// Returns the progress tracker instance
  static InitializationProgressTracker getProgressTracker() {
    return _progressTracker;
  }
}