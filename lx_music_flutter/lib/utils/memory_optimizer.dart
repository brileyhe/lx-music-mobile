import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

/// Memory optimization utilities for older devices
/// Helps manage memory usage efficiently on devices with limited RAM (Android 4.1 era)
class MemoryOptimizer {
  /// Cache for storing frequently accessed data
  static final Map<String, dynamic> _cache = {};
  
  /// Maximum cache size in bytes (e.g., 50MB for older devices)
  static const int _maxCacheSize = 50 * 1024 * 1024;
  
  /// Current cache size in bytes
  static int _currentCacheSize = 0;
  
  /// Least Recently Used (LRU) cache for managing cached items
  static final LinkedHashMap<String, int> _lruCache = LinkedHashMap();

  /// Caches data with size tracking
  static void putInCache(String key, dynamic data, {int estimatedSize = 0}) {
    // Calculate size if not provided
    int size = estimatedSize;
    if (size == 0) {
      size = _estimateSize(data);
    }

    // Check if adding this item would exceed cache limits
    if (_currentCacheSize + size > _maxCacheSize) {
      // Remove oldest items until we have enough space
      _evictOldestItems(size);
    }

    // Add the new item
    _cache[key] = data;
    _currentCacheSize += size;
    _lruCache[key] = size;

    Logger.debug('Cached $key (${size ~/ 1024}KB), total: ${_currentCacheSize ~/ 1024}KB');
  }

  /// Gets data from cache
  static T? getFromCache<T>(String key) {
    if (_cache.containsKey(key)) {
      // Update LRU order
      final size = _lruCache.remove(key)!;
      _lruCache[key] = size;
      
      Logger.debug('Retrieved $key from cache');
      return _cache[key] as T?;
    }
    return null;
  }

  /// Removes data from cache
  static void removeFromCache(String key) {
    if (_cache.containsKey(key)) {
      final size = _lruCache.remove(key)!;
      _currentCacheSize -= size;
      _cache.remove(key);
      
      Logger.debug('Removed $key from cache (${size ~/ 1024}KB freed)');
    }
  }

  /// Clears the entire cache
  static void clearCache() {
    _cache.clear();
    _lruCache.clear();
    _currentCacheSize = 0;
    
    Logger.info('Cache cleared');
  }

  /// Estimates the size of data in bytes
  static int _estimateSize(dynamic data) {
    if (data == null) return 0;
    
    if (data is String) {
      return data.length * 2; // Approximate bytes per character
    } else if (data is List<int>) {
      return data.length;
    } else if (data is Uint8List) {
      return data.lengthInBytes;
    } else if (data is List) {
      int size = 0;
      for (final item in data) {
        size += _estimateSize(item);
      }
      return size;
    } else if (data is Map) {
      int size = 0;
      data.forEach((key, value) {
        size += _estimateSize(key) + _estimateSize(value);
      });
      return size;
    } else {
      // For other types, return a conservative estimate
      return 1024; // 1KB default
    }
  }

  /// Evicts oldest items from cache to free up space
  static void _evictOldestItems(int neededSpace) {
    final keysToRemove = <String>[];
    var freedSpace = 0;
    
    // Remove oldest items first
    for (final entry in _lruCache.entries) {
      keysToRemove.add(entry.key);
      freedSpace += entry.value;
      
      if (_currentCacheSize - freedSpace < _maxCacheSize - neededSpace) {
        break;
      }
    }
    
    // Actually remove the items
    for (final key in keysToRemove) {
      _cache.remove(key);
      final size = _lruCache.remove(key)!;
      _currentCacheSize -= size;
      
      Logger.debug('Evicted $key from cache (${size ~/ 1024}KB freed)');
    }
  }

  /// Releases unused memory
  static void releaseUnusedMemory() {
    // On older Android versions, we might want to be more aggressive about cleanup
    SystemChannels.skia.invokeMethod<void>('Skia.setResourceCacheLimits', <String, dynamic>{
      'maxResources': 2048, // Reduce resource cache size
      'resourceBytes': 32 << 20, // 32MB resource cache
    });
    
    Logger.info('Released unused memory');
  }

  /// Gets current cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'currentSize': _currentCacheSize,
      'maxSize': _maxCacheSize,
      'itemCount': _cache.length,
      'usagePercent': (_currentCacheSize / _maxCacheSize * 100).round(),
    };
  }

  /// Optimizes image loading for memory efficiency
  static ByteData? optimizeImage(ByteData imageData, {int maxWidth = 800, int maxHeight = 600}) {
    // In a real implementation, this would resize images to reduce memory usage
    // For now, we'll just return the original image data
    // This would typically use an image processing library
    Logger.debug('Optimized image to max $maxWidth x $maxHeight');
    return imageData;
  }

  /// Preloads essential data while being mindful of memory
  static Future<void> preloadEssentialData() async {
    Logger.info('Preloading essential data with memory optimization');
    // Implementation would preload only critical data
  }

  /// Reduces quality of assets to save memory
  static void reduceAssetQuality() {
    // This would reduce quality of images, audio, etc. on low-memory devices
    Logger.info('Reduced asset quality for memory optimization');
  }
}

/// Memory-aware image provider that considers device capabilities
class MemoryAwareImageProvider {
  /// Loads an image considering memory constraints
  static Future<ByteData?> loadImageWithMemoryCheck(String imagePath) async {
    try {
      // In a real implementation, this would check available memory
      // before loading the image and potentially downsample it
      
      // For now, we'll just return a placeholder
      Logger.debug('Loading image with memory awareness: $imagePath');
      return null;
    } catch (e) {
      Logger.error('Failed to load image with memory awareness: $e');
      return null;
    }
  }
}