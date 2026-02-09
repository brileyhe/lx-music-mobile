import 'package:flutter/material.dart';
import '../../utils/responsive_layout.dart';
import '../../core/music/music_library_manager.dart';
import '../../core/music/playlist_manager.dart';

/// Main music library view that displays all available tracks
class MusicLibraryView extends StatefulWidget {
  const MusicLibraryView({super.key});

  @override
  State<MusicLibraryView> createState() => _MusicLibraryViewState();
}

class _MusicLibraryViewState extends State<MusicLibraryView> {
  final MusicLibraryManager _libraryManager = MusicLibraryManager();
  List<Track> _tracks = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  /// Loads tracks from the music library
  Future<void> _loadTracks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _tracks = await _libraryManager.getAllTracks();
    } catch (e) {
      // In a real app, we would show an error message
      debugPrint('Error loading tracks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Filters tracks based on the search query
  List<Track> _filterTracks() {
    if (_searchQuery.isEmpty) {
      return _tracks;
    }

    return _tracks.where((track) {
      return track.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             track.artist.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             track.album.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  /// Builds a list tile for a track
  Widget _buildTrackTile(Track track, int index) {
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
          // In a real app, this would start playing the track
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
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to Playlist'),
                onTap: () {
                  Navigator.pop(context);
                  _addToPlaylist(track);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadTrack(track);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove from Library'),
                onTap: () {
                  Navigator.pop(context);
                  _removeFromLibrary(track);
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

  /// Downloads a track for offline listening
  void _downloadTrack(Track track) {
    // In a real app, this would initiate the download process
    debugPrint('Downloading ${track.title}');
  }

  /// Removes a track from the library
  void _removeFromLibrary(Track track) {
    // In a real app, this would show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Track'),
          content: Text('Are you sure you want to remove "${track.title}" from your library?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // In a real app, this would remove the track from the library
                debugPrint('Removing ${track.title} from library');
                Navigator.pop(context);
                _loadTracks(); // Refresh the list
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTracks = _filterTracks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality would be handled by the search bar
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: ResponsiveLayout.getResponsivePadding(context),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search music...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Tracks list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTracks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_off,
                              size: ResponsiveLayout.getResponsiveIconSize(context, baseSize: 48),
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'Your music library is empty' 
                                  : 'No tracks found',
                              style: TextStyle(
                                fontSize: ResponsiveLayout.getResponsiveFontSize(context),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ResponsiveBuilder(
                        builder: (context, screenSize, constraints) {
                          if (screenSize == ScreenSize.large || screenSize == ScreenSize.extraLarge) {
                            // For larger screens, use a grid view
                            return ResponsiveGridView(
                              children: filteredTracks.asMap().entries.map((entry) {
                                final index = entry.key;
                                final track = entry.value;
                                return _buildTrackTile(track, index);
                              }).toList(),
                              childAspectRatio: 3, // More rectangular for music tracks
                            );
                          } else {
                            // For smaller screens, use a list view
                            return ResponsiveListView(
                              children: filteredTracks.asMap().entries.map((entry) {
                                final index = entry.key;
                                final track = entry.value;
                                return _buildTrackTile(track, index);
                              }).toList(),
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }
}