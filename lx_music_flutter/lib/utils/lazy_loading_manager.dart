import 'package:flutter/material.dart';
import '../core/music/music_library_manager.dart';
import '../core/music/playlist_manager.dart';
import '../utils/logger.dart';

/// Lazy loading implementation for large music libraries
/// Helps manage memory and performance when dealing with large collections
class LazyLoadingManager {
  final MusicLibraryManager _libraryManager;
  final int _pageSize;
  
  // Cache for loaded pages
  final Map<int, List<Track>> _pageCache = {};
  final Set<int> _loadedPages = {};
  
  int _totalTracks = 0;
  bool _isInitialized = false;

  LazyLoadingManager({
    required MusicLibraryManager libraryManager,
    int pageSize = 50, // Reasonable default for older devices
  }) : _libraryManager = libraryManager, _pageSize = pageSize;

  /// Initializes the lazy loader
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Get total count of tracks
    _totalTracks = (await _libraryManager.getAllTracks()).length;
    _isInitialized = true;
    
    Logger.info('Lazy loading initialized with $_totalTracks tracks');
  }

  /// Gets the total number of tracks
  int getTotalTrackCount() {
    return _totalTracks;
  }

  /// Gets the total number of pages
  int getTotalPages() {
    return (_totalTracks / _pageSize).ceil();
  }

  /// Loads a specific page of tracks
  Future<List<Track>> loadPage(int pageNumber) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check if page is already cached
    if (_pageCache.containsKey(pageNumber)) {
      Logger.debug('Loaded page $pageNumber from cache');
      return _pageCache[pageNumber]!;
    }

    // Calculate the range of tracks to load
    final startIndex = pageNumber * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, _totalTracks);
    
    if (startIndex >= _totalTracks) {
      return []; // No more tracks to load
    }

    Logger.info('Loading page $pageNumber ($startIndex-$endIndex)');

    // In a real implementation, the MusicLibraryManager would need to support
    // pagination. For now, we'll load all tracks and slice them.
    // This is inefficient but serves as a placeholder for the concept.
    final allTracks = await _libraryManager.getAllTracks();
    final pageTracks = allTracks.skip(startIndex).take(endIndex - startIndex).toList();

    // Cache the loaded page
    _pageCache[pageNumber] = pageTracks;
    _loadedPages.add(pageNumber);

    Logger.debug('Loaded ${pageTracks.length} tracks for page $pageNumber');

    return pageTracks;
  }

  /// Preloads the next page if not already loaded
  Future<void> preloadPage(int pageNumber) async {
    if (pageNumber < getTotalPages() && !_loadedPages.contains(pageNumber)) {
      // Use a background task to preload
      Future.microtask(() async {
        await loadPage(pageNumber);
        Logger.debug('Preloaded page $pageNumber');
      });
    }
  }

  /// Clears the cache to free up memory
  void clearCache() {
    _pageCache.clear();
    _loadedPages.clear();
    Logger.info('Lazy loading cache cleared');
  }

  /// Gets a specific track by index using lazy loading
  Future<Track?> getTrackAtIndex(int index) async {
    if (index < 0 || index >= _totalTracks) {
      return null;
    }

    final pageNumber = index ~/ _pageSize;
    final pageIndex = index % _pageSize;

    final page = await loadPage(pageNumber);
    if (pageIndex < page.length) {
      return page[pageIndex];
    }

    return null;
  }

  /// Gets a range of tracks using lazy loading
  Future<List<Track>> getTracksInRange(int start, int end) async {
    if (start < 0 || end > _totalTracks || start >= end) {
      return [];
    }

    final result = <Track>[];

    final startPage = start ~/ _pageSize;
    final endPage = end ~/ _pageSize;

    // Load all required pages
    for (int i = startPage; i <= endPage; i++) {
      final page = await loadPage(i);
      result.addAll(page);
    }

    // Slice the result to the exact range
    final startIndex = start % _pageSize;
    final endIndex = startPage == endPage 
        ? startIndex + (end - start) 
        : result.length;

    return result.sublist(startIndex, endIndex);
  }
}

/// A widget that implements lazy loading for displaying large lists of tracks
class LazyLoadingTrackList extends StatefulWidget {
  final LazyLoadingManager lazyLoader;
  final void Function(Track)? onTrackTap;
  final void Function(Track)? onTrackLongPress;

  const LazyLoadingTrackList({
    super.key,
    required this.lazyLoader,
    this.onTrackTap,
    this.onTrackLongPress,
  });

  @override
  State<LazyLoadingTrackList> createState() => _LazyLoadingTrackListState();
}

class _LazyLoadingTrackListState extends State<LazyLoadingTrackList> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, List<Track>> _loadedPages = {};
  final Set<int> _loadingPages = <int>{};
  final int _preloadThreshold = 5; // Preload when within 5 items of threshold

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handles scroll events to trigger loading of new pages
  void _onScroll() {
    if (_scrollController.position.extentAfter < 500) {
      // Near the end of the list, load more items
      _loadMore();
    }
  }

  /// Loads more items when scrolling near the end
  Future<void> _loadMore() async {
    final totalItems = widget.lazyLoader.getTotalTrackCount();
    final loadedItems = _loadedPages.values.expand((page) => page).length;
    
    if (loadedItems >= totalItems) {
      return; // Already loaded everything
    }

    final nextPage = loadedItems ~/ widget.lazyLoader._pageSize;
    
    if (!_loadingPages.contains(nextPage) && !_loadedPages.containsKey(nextPage)) {
      _loadingPages.add(nextPage);
      
      try {
        final tracks = await widget.lazyLoader.loadPage(nextPage);
        setState(() {
          _loadedPages[nextPage] = tracks;
          _loadingPages.remove(nextPage);
        });
        
        // Preload the next page
        widget.lazyLoader.preloadPage(nextPage + 1);
      } catch (e) {
        Logger.error('Failed to load page $nextPage: $e');
        _loadingPages.remove(nextPage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = widget.lazyLoader.getTotalPages();
    final allTracks = <Track>[];
    
    // Combine all loaded pages
    for (int i = 0; i < totalPages; i++) {
      if (_loadedPages.containsKey(i)) {
        allTracks.addAll(_loadedPages[i]!);
      }
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: allTracks.length + (_loadingPages.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < allTracks.length) {
          final track = allTracks[index];
          return _buildTrackItem(track);
        } else {
          // Loading indicator at the end
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  /// Builds a single track item
  Widget _buildTrackItem(Track track) {
    return Card(
      child: ListTile(
        title: Text(track.title),
        subtitle: Text('${track.artist} • ${track.album}'),
        trailing: Text(
          '${track.duration.inMinutes}:${(track.duration.inSeconds % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () => widget.onTrackTap?.call(track),
        onLongPress: () => widget.onTrackLongPress?.call(track),
      ),
    );
  }
}

/// A search implementation that uses lazy loading
class LazyLoadingSearch {
  final LazyLoadingManager _lazyLoader;
  final MusicLibraryManager _libraryManager;

  LazyLoadingSearch(this._lazyLoader, this._libraryManager);

  /// Searches tracks using lazy loading to manage memory
  Future<List<Track>> searchTracks(String query, {int maxResults = 100}) async {
    if (query.isEmpty) {
      return [];
    }

    final results = <Track>[];
    final totalTracks = _lazyLoader.getTotalTrackCount();
    final totalPages = _lazyLoader.getTotalPages();

    // Search through pages one by one to manage memory
    for (int pageNum = 0; pageNum < totalPages && results.length < maxResults; pageNum++) {
      final page = await _lazyLoader.loadPage(pageNum);
      
      for (final track in page) {
        if (results.length >= maxResults) break;
        
        if (track.title.toLowerCase().contains(query.toLowerCase()) ||
            track.artist.toLowerCase().contains(query.toLowerCase()) ||
            track.album.toLowerCase().contains(query.toLowerCase())) {
          results.add(track);
        }
      }
    }

    Logger.info('Found ${results.length} tracks matching "$query"');
    return results;
  }
}