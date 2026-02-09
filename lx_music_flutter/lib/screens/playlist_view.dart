import 'package:flutter/material.dart';
import '../../utils/responsive_layout.dart';
import '../../core/music/playlist_manager.dart';

/// Playlist view that displays and manages playlists
class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  final PlaylistManager _playlistManager = PlaylistManager();
  List<Track> _playlistTracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  /// Loads tracks from the current playlist
  Future<void> _loadPlaylist() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _playlistTracks = _playlistManager.tracks;
    } catch (e) {
      // In a real app, we would show an error message
      debugPrint('Error loading playlist: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Builds a list tile for a track in the playlist
  Widget _buildPlaylistTrackTile(Track track, int index) {
    final isCurrentTrack = _playlistManager.currentIndex == index;
    
    return Dismissible(
      key: Key('playlist_track_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _playlistManager.removeTrackAt(index);
        setState(() {
          _playlistTracks.removeAt(index);
        });
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: ResponsiveLayout.getResponsivePadding(context),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
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
              color: isCurrentTrack 
                  ? Theme.of(context).primaryColor.withOpacity(0.2) 
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.music_note,
                  color: Theme.of(context).primaryColor,
                  size: ResponsiveLayout.getResponsiveIconSize(context),
                ),
                if (isCurrentTrack)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          title: Text(
            track.title,
            style: TextStyle(
              fontSize: ResponsiveLayout.getResponsiveFontSize(context),
              fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            track.artist,
            style: TextStyle(
              fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 14),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  size: ResponsiveLayout.getResponsiveIconSize(context, baseSize: 20),
                ),
                onPressed: () {
                  _moveTrackUp(index);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  size: ResponsiveLayout.getResponsiveIconSize(context, baseSize: 20),
                ),
                onPressed: () {
                  _moveTrackDown(index);
                },
              ),
            ],
          ),
          onTap: () {
            // Play the selected track
            _playlistManager.jumpToIndex(index);
            debugPrint('Playing track: ${track.title}');
          },
        ),
      ),
    );
  }

  /// Moves a track up in the playlist
  void _moveTrackUp(int index) {
    if (index > 0) {
      _playlistManager.moveTrack(index, index - 1);
      setState(() {
        // Swap the tracks in the local list
        final temp = _playlistTracks[index];
        _playlistTracks[index] = _playlistTracks[index - 1];
        _playlistTracks[index - 1] = temp;
        
        // Update the current index if needed
        if (_playlistManager.currentIndex == index) {
          _playlistManager.jumpToIndex(index - 1);
        } else if (_playlistManager.currentIndex == index - 1) {
          _playlistManager.jumpToIndex(index);
        }
      });
    }
  }

  /// Moves a track down in the playlist
  void _moveTrackDown(int index) {
    if (index < _playlistTracks.length - 1) {
      _playlistManager.moveTrack(index, index + 1);
      setState(() {
        // Swap the tracks in the local list
        final temp = _playlistTracks[index];
        _playlistTracks[index] = _playlistTracks[index + 1];
        _playlistTracks[index + 1] = temp;
        
        // Update the current index if needed
        if (_playlistManager.currentIndex == index) {
          _playlistManager.jumpToIndex(index + 1);
        } else if (_playlistManager.currentIndex == index + 1) {
          _playlistManager.jumpToIndex(index);
        }
      });
    }
  }

  /// Plays the next track
  void _playNext() {
    final nextTrack = _playlistManager.nextTrack();
    if (nextTrack != null) {
      debugPrint('Playing next track: ${nextTrack.title}');
      setState(() {});
    }
  }

  /// Plays the previous track
  void _playPrevious() {
    final prevTrack = _playlistManager.previousTrack();
    if (prevTrack != null) {
      debugPrint('Playing previous track: ${prevTrack.title}');
      setState(() {});
    }
  }

  /// Shuffles the playlist
  void _shufflePlaylist() {
    _playlistManager.shuffle();
    setState(() {
      _playlistTracks = _playlistManager.tracks;
    });
  }

  /// Clears the playlist
  void _clearPlaylist() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Playlist'),
          content: const Text('Are you sure you want to clear the entire playlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _playlistManager.clearPlaylist();
                setState(() {
                  _playlistTracks = _playlistManager.tracks;
                });
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'shuffle',
                child: ListTile(
                  leading: Icon(Icons.shuffle),
                  title: Text('Shuffle'),
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear),
                  title: Text('Clear Playlist'),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'shuffle') {
                _shufflePlaylist();
              } else if (value == 'clear') {
                _clearPlaylist();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Playlist info
          Container(
            padding: ResponsiveLayout.getResponsivePadding(context),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Playlist',
                        style: TextStyle(
                          fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_playlistTracks.length} tracks',
                        style: TextStyle(
                          fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 14),
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_playlistManager.currentTrack != null)
                  Text(
                    'Now Playing: ${_playlistManager.currentTrack!.title}',
                    style: TextStyle(
                      fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 14),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          
          // Controls
          Padding(
            padding: ResponsiveLayout.getResponsivePadding(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _playlistTracks.isEmpty ? null : _playPrevious,
                  icon: Icon(
                    Icons.skip_previous,
                    size: ResponsiveLayout.getResponsiveIconSize(context),
                  ),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      ResponsiveLayout.getResponsiveTouchTargetSize(context) * 2,
                      ResponsiveLayout.getResponsiveButtonHeight(context),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _shufflePlaylist,
                  icon: Icon(
                    Icons.shuffle,
                    size: ResponsiveLayout.getResponsiveIconSize(context),
                  ),
                  label: const Text('Shuffle'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      ResponsiveLayout.getResponsiveTouchTargetSize(context) * 2,
                      ResponsiveLayout.getResponsiveButtonHeight(context),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _playlistTracks.isEmpty ? null : _playNext,
                  icon: Icon(
                    Icons.skip_next,
                    size: ResponsiveLayout.getResponsiveIconSize(context),
                  ),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(
                      ResponsiveLayout.getResponsiveTouchTargetSize(context) * 2,
                      ResponsiveLayout.getResponsiveButtonHeight(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tracks list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _playlistTracks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.queue_music,
                              size: ResponsiveLayout.getResponsiveIconSize(context, baseSize: 48),
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Playlist is empty',
                              style: TextStyle(
                                fontSize: ResponsiveLayout.getResponsiveFontSize(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // In a real app, this would navigate to the music library
                                debugPrint('Navigate to music library to add tracks');
                              },
                              child: const Text('Add Tracks'),
                            ),
                          ],
                        ),
                      )
                    : ResponsiveListView(
                        children: _playlistTracks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final track = entry.value;
                          return _buildPlaylistTrackTile(track, index);
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }
}