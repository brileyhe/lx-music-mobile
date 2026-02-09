import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:collection';
import '../utils/logger.dart';

/// Configuration for asset loading optimization
class AssetLoadConfig {
  final int maxCacheSize; // Maximum cache size in MB
  final Duration cacheStalePeriod; // How long before cache is considered stale
  final int maxConcurrentLoads; // Maximum number of concurrent asset loads
  final bool compressImages; // Whether to compress images
  final int targetImageSize; // Target size for images on lower-end devices

  const AssetLoadConfig({
    this.maxCacheSize = 50, // 50MB default for older devices
    this.cacheStalePeriod = const Duration(days: 7),
    this.maxConcurrentLoads = 3, // Limit concurrent loads for older devices
    this.compressImages = true,
    this.targetImageSize = 800, // Reasonable size for older devices
  });
}

/// Optimized asset loader for older devices
class OptimizedAssetLoader {
  static final OptimizedAssetLoader _instance = OptimizedAssetLoader._internal();
  factory OptimizedAssetLoader() => _instance;
  OptimizedAssetLoader._internal();

  final AssetLoadConfig _config = const AssetLoadConfig();
  final Map<String, AssetCacheEntry> _memoryCache = {};
  final Queue<String> _lruQueue = Queue<String>();
  final Map<String, Future<Uint8List?>> _pendingLoads = {};
  BaseCacheManager? _cacheManager;

  /// Initializes the asset loader
  Future<void> initialize() async {
    _cacheManager = await CacheManager.getInstance();
    Logger.info('Optimized asset loader initialized');
  }

  /// Loads an image asset with optimization
  Future<Image> loadImage(
    String assetPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) async {
    // Use the target size from config if no specific size is provided
    final targetWidth = width ?? _config.targetImageSize.toDouble();
    final targetHeight = height ?? _config.targetImageSize.toDouble();

    // First check memory cache
    final cachedImage = _memoryCache[assetPath];
    if (cachedImage != null && !cachedImage.isStale()) {
      Logger.debug('Loaded image from memory cache: $assetPath');
      return Image.memory(
        cachedImage.data,
        width: targetWidth,
        height: targetHeight,
        fit: fit,
      );
    }

    // Check if there's already a load in progress
    if (_pendingLoads.containsKey(assetPath)) {
      Logger.debug('Waiting for pending load: $assetPath');
      final data = await _pendingLoads[assetPath];
      if (data != null) {
        return Image.memory(data, width: targetWidth, height: targetHeight, fit: fit);
      }
    }

    // Load the asset
    final completer = Future<Uint8List?>.value();
    _pendingLoads[assetPath] = _loadImageData(assetPath);

    try {
      final imageData = await _pendingLoads[assetPath];
      _pendingLoads.remove(assetPath);

      if (imageData == null) {
        Logger.warn('Could not load image: $assetPath');
        return Image.asset('assets/images/placeholder.png', // fallback
            width: targetWidth, height: targetHeight, fit: fit);
      }

      // Cache in memory
      _cacheInMemory(assetPath, imageData);

      return Image.memory(imageData, width: targetWidth, height: targetHeight, fit: fit);
    } catch (e) {
      _pendingLoads.remove(assetPath);
      Logger.error('Error loading image $assetPath: $e');
      return Image.asset('assets/images/placeholder.png', // fallback
          width: targetWidth, height: targetHeight, fit: fit);
    }
  }

  /// Loads image data from asset or network
  Future<Uint8List?> _loadImageData(String assetPath) async {
    try {
      Uint8List imageData;

      if (assetPath.startsWith('http')) {
        // Network image
        imageData = await _loadNetworkImage(assetPath);
      } else {
        // Local asset
        imageData = await rootBundle.load(assetPath).then((value) => value.buffer.asUint8List());
      }

      // Optimize the image if needed
      if (_config.compressImages) {
        imageData = await _optimizeImage(imageData);
      }

      return imageData;
    } catch (e) {
      Logger.error('Failed to load image data for $assetPath: $e');
      return null;
    }
  }

  /// Loads a network image with caching
  Future<Uint8List> _loadNetworkImage(String url) async {
    try {
      // Use the cache manager to handle network image caching
      final file = await _cacheManager?.getSingleFile(
        url,
        headers: {'User-Agent': 'LX-Music-Flutter/1.0'},
      );
      
      if (file != null) {
        return await file.readAsBytes();
      } else {
        throw Exception('Could not load network image');
      }
    } catch (e) {
      Logger.error('Failed to load network image $url: $e');
      // Return a placeholder image
      return await rootBundle.load('assets/images/placeholder.png')
          .then((value) => value.buffer.asUint8List());
    }
  }

  /// Optimizes an image (compresses/resizes)
  Future<Uint8List> _optimizeImage(Uint8List imageData) async {
    // In a real implementation, this would use an image processing library
    // For now, we'll just return the original image with a log
    Logger.debug('Optimized image (simulated)');
    return imageData;
  }

  /// Loads raw asset data
  Future<ByteData> loadAsset(String assetPath) async {
    try {
      return await rootBundle.load(assetPath);
    } catch (e) {
      Logger.error('Failed to load asset $assetPath: $e');
      // Return empty ByteData as fallback
      return ByteData(0);
    }
  }

  /// Caches data in memory
  void _cacheInMemory(String key, Uint8List data) {
    // Check if we need to evict items due to size limits
    _evictIfOverLimit();

    // Add to cache
    _memoryCache[key] = AssetCacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );

    // Add to LRU queue
    _lruQueue.addLast(key);

    Logger.debug('Cached asset in memory: $key (${data.lengthInBytes} bytes)');
  }

  /// Evicts items from memory cache if over the size limit
  void _evictIfOverLimit() {
    int currentSize = _memoryCache.values.fold(0, (sum, entry) => sum + entry.data.lengthInBytes);
    final maxSize = _config.maxCacheSize * 1024 * 1024; // Convert MB to bytes

    while (currentSize > maxSize && _lruQueue.isNotEmpty) {
      final oldestKey = _lruQueue.removeFirst();
      final removedEntry = _memoryCache.remove(oldestKey);
      
      if (removedEntry != null) {
        currentSize -= removedEntry.data.lengthInBytes;
        Logger.debug('Evicted from cache: $oldestKey');
      }
    }
  }

  /// Checks if an asset is in memory cache
  bool isInMemoryCache(String key) {
    final entry = _memoryCache[key];
    return entry != null && !entry.isStale();
  }

  /// Clears the memory cache
  void clearMemoryCache() {
    _memoryCache.clear();
    _lruQueue.clear();
    Logger.info('Cleared memory cache');
  }

  /// Gets cache statistics
  Map<String, dynamic> getCacheStats() {
    int totalSize = _memoryCache.values.fold(0, (sum, entry) => sum + entry.data.lengthInBytes);
    return {
      'memoryCacheItemCount': _memoryCache.length,
      'memoryCacheSize': totalSize,
      'maxMemoryCacheSize': _config.maxCacheSize * 1024 * 1024,
      'pendingLoads': _pendingLoads.length,
    };
  }

  /// Preloads assets that are likely to be needed
  Future<void> preloadAssets(List<String> assetPaths) async {
    Logger.info('Preloading ${assetPaths.length} assets');
    
    // Process assets in chunks to avoid overwhelming the system
    const chunkSize = _AssetLoadConfig.maxConcurrentLoads;
    for (int i = 0; i < assetPaths.length; i += chunkSize) {
      final chunk = assetPaths.skip(i).take(chunkSize).toList();
      await Future.wait(chunk.map((path) => _loadImageData(path)));
    }
    
    Logger.info('Finished preloading assets');
  }
}

/// Entry in the asset cache
class AssetCacheEntry {
  final Uint8List data;
  final DateTime timestamp;
  final Duration stalePeriod;

  AssetCacheEntry({
    required this.data,
    required this.timestamp,
    Duration? stalePeriod,
  }) : stalePeriod = stalePeriod ?? const AssetLoadConfig().cacheStalePeriod;

  /// Checks if the cache entry is stale
  bool isStale() {
    return DateTime.now().difference(timestamp) > stalePeriod;
  }
}

/// A widget that uses optimized asset loading
class OptimizedImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget Function(BuildContext, Object?, StackTrace?)? errorWidget;

  const OptimizedImage.asset(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  const OptimizedImage.network(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: OptimizedAssetLoader().loadImage(
        assetPath,
        width: width,
        height: height,
        fit: fit,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else if (snapshot.hasError) {
          if (errorWidget != null) {
            return errorWidget!(context, snapshot.error, snapshot.stackTrace);
          }
          return placeholder ?? const Icon(Icons.image_not_supported);
        } else {
          return placeholder ?? const CircularProgressIndicator();
        }
      },
    );
  }
}

/// Singleton instance of the asset loader
OptimizedAssetLoader assetLoader = OptimizedAssetLoader();