import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Utility for monitoring and profiling app performance
/// Particularly important for ensuring compatibility with older Android versions (4.1+)
class PerformanceProfiler {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<int>> _memorySamples = {};
  static final Map<String, List<int>> _frameTimeSamples = {};

  /// Starts timing a specific operation
  static void startTiming(String operation) {
    _timers[operation] = Stopwatch()..start();
  }

  /// Stops timing a specific operation and logs the result
  static void stopTiming(String operation) {
    final stopwatch = _timers[operation];
    if (stopwatch != null) {
      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      Logger.info('$operation took ${elapsedMs}ms');
      
      // Log performance warnings for slow operations
      if (elapsedMs > 100) {
        Logger.warn('Slow operation detected: $operation took ${elapsedMs}ms (>100ms)');
      }
      
      _timers.remove(operation);
    }
  }

  /// Samples memory usage
  static void sampleMemory(String tag) {
    // In a real implementation, this would use dart:developer to get memory stats
    // For now, we'll just log that we're sampling
    Logger.debug('Memory sampled for: $tag');
  }

  /// Samples frame rendering time
  static void sampleFrameTime(Duration frameTime) {
    final frameTimeMs = frameTime.inMilliseconds;
    
    if (!_frameTimeSamples.containsKey('frames')) {
      _frameTimeSamples['frames'] = [];
    }
    
    _frameTimeSamples['frames']!.add(frameTimeMs);
    
    // Log warnings for frames that take too long (>16ms for 60fps)
    if (frameTimeMs > 16) {
      Logger.warn('Slow frame detected: ${frameTimeMs}ms (>16ms for 60fps)');
    }
  }

  /// Gets average frame time
  static double getAverageFrameTime() {
    if (!_frameTimeSamples.containsKey('frames') || _frameTimeSamples['frames']!.isEmpty) {
      return 0.0;
    }
    
    final samples = _frameTimeSamples['frames']!;
    final sum = samples.reduce((a, b) => a + b);
    return sum / samples.length;
  }

  /// Gets frame rate based on average frame time
  static double getFrameRate() {
    final avgFrameTime = getAverageFrameTime();
    if (avgFrameTime == 0) return 60.0; // Default assumption
    return (1000.0 / avgFrameTime).clamp(0, 60).toDouble();
  }

  /// Checks if the app is performing well
  static bool isPerformingWell() {
    final frameRate = getFrameRate();
    final avgFrameTime = getAverageFrameTime();
    
    // For older Android devices, we might accept slightly lower performance
    return frameRate >= 50 && avgFrameTime <= 20; // Allow up to 20ms avg frame time
  }

  /// Logs performance summary
  static void logPerformanceSummary() {
    final frameRate = getFrameRate();
    final avgFrameTime = getAverageFrameTime();
    final totalFrames = _frameTimeSamples['frames']?.length ?? 0;
    
    Logger.info('=== Performance Summary ===');
    Logger.info('Frame Rate: ${frameRate.toStringAsFixed(1)} fps');
    Logger.info('Average Frame Time: ${avgFrameTime.toStringAsFixed(2)} ms');
    Logger.info('Total Frames Sampled: $totalFrames');
    Logger.info('Performance Status: ${isPerformingWell() ? "GOOD" : "POOR"}');
    Logger.info('=========================');
  }

  /// Clears all collected performance data
  static void reset() {
    _timers.clear();
    _memorySamples.clear();
    _frameTimeSamples.clear();
  }

  /// Measures the performance of a function
  static T measureFunction<T>(String name, T Function() function) {
    startTiming(name);
    try {
      final result = function();
      stopTiming(name);
      return result;
    } catch (e) {
      stopTiming(name);
      rethrow;
    }
  }

  /// Measures the performance of an asynchronous function
  static Future<T> measureAsyncFunction<T>(String name, Future<T> Function() function) async {
    startTiming(name);
    try {
      final result = await function();
      stopTiming(name);
      return result;
    } catch (e) {
      stopTiming(name);
      rethrow;
    }
  }

  /// Gets memory usage statistics (simulated)
  static Map<String, dynamic> getMemoryStats() {
    // In a real implementation, this would use dart:developer to get actual memory stats
    // For simulation purposes, we'll return mock data
    return {
      'currentHeapSize': 10 * 1024 * 1024, // 10 MB
      'currentHeapUsed': 5 * 1024 * 1024,  // 5 MB
      'externalAllocated': 2 * 1024 * 1024, // 2 MB
    };
  }

  /// Optimizes performance for older devices
  static void optimizeForOlderDevices() {
    // Reduce animation complexity
    if (kDebugMode) {
      // In debug mode, we might want to keep animations smooth for development
      return;
    }
    
    // For older devices, we might want to reduce animation complexity
    // This would be handled by checking device capabilities
    Logger.info('Optimizing performance for older devices');
  }
}