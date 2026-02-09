import 'package:flutter/material.dart';
import '../../utils/responsive_layout.dart';
import '../../core/music/music_library_manager.dart';
import '../../core/music/playlist_manager.dart';

/// Search screen that allows users to search for music
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MusicLibraryManager _libraryManager = MusicLibraryManager();
  final TextEditingController _searchController = TextEditingController();
  List<Track> _searchResults = [];
  bool _isLoading = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Performs a search with the given query
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final results = await _libraryManager.searchTracks(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
        _lastQuery = query;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Search error: $e');
    }
  }

  /// Debounces search queries to avoid too frequent API calls
  void _onSearchChanged(String value) {
    // Cancel previous search if it was scheduled
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == value) {
        _performSearch(value);
      }
    });
  }

  /// Builds a tile for a search result
  Widget _buildResultTile(Track track, int index) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.getResponsiveSpacing(context) / 2,
        vertical: ResponsiveLayout.getResponsiveSpacing(context) / 4,
      ),
      child: ListTile(
        contentPadding: ResponsiveLayout.getResponsivePadding(context),
        leading: Container(
          width: ResponsiveLayout.getResponsiveTouchTargetSize(context),
          height: ResponsiveLayout.getResponsiveTouchTargetSize(context),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.music_note,
            color: Theme.of(context).primaryColor,
            size: ResponsiveLayout.getResponsiveIconSize(context),
          ),
        ),
        title: Text(
          track.title,
          style: TextStyle(
            fontSize: ResponsiveLayout.getResponsiveFontSize(context),
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              track.artist,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 14),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              track.album,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 12),
                color: Theme.of(context).hintColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Text(
          '${track.duration.inMinutes}:${(track.duration.inSeconds % 60).toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 12),
          ),
        ),
        onTap: () {
          // In a real app, this would play the track
          debugPrint('Playing track: ${track.title}');
        },
        onLongPress: () {
          // In a real app, this would show options for the track
          _showTrackOptions(track);
        },
      ),
    );
  }

  /// Shows options for a track
  void _showTrackOptions(Track track) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Play Now'),
                onTap: () {
                  Navigator.pop(context);
                  debugPrint('Play track: ${track.title}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to Playlist'),
                onTap: () {
                  Navigator.pop(context);
                  _addToPlaylist(track);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_play),
                title: const Text('Play Next'),
                onTap: () {
                  Navigator.pop(context);
                  debugPrint('Play next: ${track.title}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  debugPrint('Download: ${track.title}');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Adds a track to a playlist
  void _addToPlaylist(Track track) {
    // In a real app, this would show a dialog to select or create a playlist
    debugPrint('Adding ${track.title} to playlist');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search music...',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onChanged: _onSearchChanged,
          onSubmitted: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchResults = [];
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search suggestions
          if (_searchController.text.isEmpty && _lastQuery.isEmpty)
            Expanded(
              child: _buildSearchSuggestions(),
            ),
          // Search results
          if (_searchController.text.isNotEmpty || _lastQuery.isNotEmpty)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: ResponsiveLayout.getResponsiveIconSize(context, baseSize: 48),
                                color: Theme.of(context).hintColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No results found for "$_lastQuery"',
                                style: TextStyle(
                                  fontSize: ResponsiveLayout.getResponsiveFontSize(context),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ResponsiveListView(
                          children: _searchResults.asMap().entries.map((entry) {
                            final index = entry.key;
                            final track = entry.value;
                            return _buildResultTile(track, index);
                          }).toList(),
                        ),
            ),
        ],
      ),
    );
  }

  /// Builds search suggestions
  Widget _buildSearchSuggestions() {
    return Padding(
      padding: ResponsiveLayout.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Search',
            style: TextStyle(
              fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Rock'),
              _buildSuggestionChip('Pop'),
              _buildSuggestionChip('Jazz'),
              _buildSuggestionChip('Classical'),
              _buildSuggestionChip('Hip Hop'),
              _buildSuggestionChip('Electronic'),
              _buildSuggestionChip('Country'),
              _buildSuggestionChip('Blues'),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Recently Played',
            style: TextStyle(
              fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // In a real app, this would show recently played tracks
          const Center(
            child: Text('Recently played tracks would appear here'),
          ),
        ],
      ),
    );
  }

  /// Builds a search suggestion chip
  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(suggestion),
      onPressed: () {
        _searchController.text = suggestion;
        _performSearch(suggestion);
      },
      labelStyle: TextStyle(
        fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 14),
      ),
    );
  }
}