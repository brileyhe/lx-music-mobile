import 'dart:async';
import 'package:lx_music_flutter/utils/logger.dart';

/// Represents the state of an initialization task
class InitializationStep {
  final String name;
  final String description;
  bool isCompleted;
  DateTime? startTime;
  DateTime? endTime;
  String? errorMessage;

  InitializationStep({
    required this.name,
    required this.description,
    this.isCompleted = false,
    this.startTime,
    this.endTime,
    this.errorMessage,
  });
}

/// Tracks the progress of initialization steps
class InitializationProgressTracker {
  final List<InitializationStep> _steps = [];
  final StreamController<InitializationStep> _stepController =
      StreamController<InitializationStep>.broadcast();
  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  int _totalSteps = 0;
  int _completedSteps = 0;

  /// Adds a new initialization step to track
  void addStep(String name, String description) {
    _steps.add(InitializationStep(
      name: name,
      description: description,
    ));
    _totalSteps = _steps.length;
  }

  /// Marks a step as started
  void startStep(String name) {
    final step = _steps.firstWhere((s) => s.name == name,
        orElse: () => throw ArgumentError('Step not found: $name'));
    step.startTime = DateTime.now();
    _updateStatus('Initializing: ${step.description}');
    Logger.info('Started initialization step: $name');
  }

  /// Marks a step as completed
  void completeStep(String name) {
    final step = _steps.firstWhere((s) => s.name == name,
        orElse: () => throw ArgumentError('Step not found: $name'));
    step.isCompleted = true;
    step.endTime = DateTime.now();
    _completedSteps++;

    _stepController.add(step);
    _updateProgress();
    _updateStatus('Completed: ${step.description}');
    Logger.info(
        'Completed initialization step: $name ($_completedSteps/$_totalSteps)');
  }

  /// Marks a step as failed
  void failStep(String name, String error) {
    final step = _steps.firstWhere((s) => s.name == name,
        orElse: () => throw ArgumentError('Step not found: $name'));
    step.isCompleted = false;
    step.endTime = DateTime.now();
    step.errorMessage = error;
    _stepController.add(step);
    _updateStatus('Failed: ${step.description} - $error');
    Logger.error('Failed initialization step: $name - $error');
  }

  /// Updates the overall progress percentage
  void _updateProgress() {
    if (_totalSteps > 0) {
      final progress = _completedSteps / _totalSteps;
      _progressController.add(progress);
    }
  }

  /// Updates the current status message
  void _updateStatus(String status) {
    _statusController.add(status);
  }

  /// Gets the current progress as a percentage (0.0 to 1.0)
  double getProgress() {
    if (_totalSteps == 0) return 0.0;
    return _completedSteps / _totalSteps;
  }

  /// Gets the current status message
  String getStatus() {
    if (_completedSteps == 0) return 'Starting initialization...';
    if (_completedSteps == _totalSteps) return 'Initialization complete!';
    return 'Initializing ($_completedSteps/$_totalSteps)...';
  }

  /// Gets the stream of step updates
  Stream<InitializationStep> get stepStream => _stepController.stream;

  /// Gets the stream of progress updates
  Stream<double> get progressStream => _progressController.stream;

  /// Gets the stream of status updates
  Stream<String> get statusStream => _statusController.stream;

  /// Gets the list of all steps
  List<InitializationStep> get steps => List.unmodifiable(_steps);

  /// Gets the total number of steps
  int get totalSteps => _totalSteps;

  /// Gets the number of completed steps
  int get completedSteps => _completedSteps;

  /// Resets the tracker
  void reset() {
    _steps.clear();
    _totalSteps = 0;
    _completedSteps = 0;
  }

  /// Disposes of the streams
  void dispose() {
    _stepController.close();
    _progressController.close();
    _statusController.close();
  }
}
