import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/responsive_layout.dart';
import '../../core/music/playlist_manager.dart';
import '../../core/music/audio_effects_manager.dart';

/// Now playing screen that displays the currently playing track with controls
class NowPlayingScreen extends StatefulWidget {
  final PlaylistManager playlistManager;
  final AudioEffectsManager? audioEffectsManager;

  const NowPlayingScreen({
    super.key,
    required this.playlistManager,
    this.audioEffectsManager,
  });

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  Timer? _positionTimer;
  bool _showLyrics = false;

  @override
  void initState() {
    super.initState();
    _initializePlayerState();
  }

  /// Initializes the player state
  void _initializePlayerState() {
    // In a real app, this would connect to the actual audio player
    // For now, we'll simulate the state
    setState(() {
      _isPlaying = false;
    });
  }

  /// Toggles play/pause
  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startPositionTimer();
    } else {
      _stopPositionTimer();
    }
  }

  /// Starts the position timer
  void _startPositionTimer() {
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _position = _position + const Duration(seconds: 1);
        if (_position > _duration) {
          _position = _duration;
        }
      });
    });
  }

  /// Stops the position timer
  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  /// Goes to the previous track
  void _goToPrevious() {
    final previousTrack = widget.playlistManager.previousTrack();
    if (previousTrack != null) {
      setState(() {
        _position = Duration.zero;
      });
    }
  }

  /// Goes to the next track
  void _goToNext() {
    final nextTrack = widget.playlistManager.nextTrack();
    if (nextTrack != null) {
      setState(() {
        _position = Duration.zero;
      });
    }
  }

  /// Seeks to a specific position
  void _seekToPosition(double value) {
    setState(() {
      _position = Duration(milliseconds: value.round());
    });
  }

  /// Toggles lyrics visibility
  void _toggleLyrics() {
    setState(() {
      _showLyrics = !_showLyrics;
    });
  }

  /// Formats duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _stopPositionTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = widget.playlistManager.currentTrack;
    
    if (currentTrack == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Now Playing'),
        ),
        body: const Center(
          child: Text('No track is currently playing'),
        ),
      );
    }

    // Simulate duration based on track
    _duration = currentTrack.duration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lyrics),
            onPressed: _toggleLyrics,
            color: _showLyrics ? Theme.of(context).primaryColor : null,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'equalizer',
                child: ListTile(
                  leading: Icon(Icons.equalizer),
                  title: Text('Equalizer'),
                ),
              ),
              const PopupMenuItem(
                value: 'add_to_playlist',
                child: ListTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('Add to Playlist'),
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share'),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'equalizer') {
                // Navigate to equalizer screen
                debugPrint('Open equalizer');
              } else if (value == 'add_to_playlist') {
                // Add to playlist
                debugPrint('Add to playlist');
              } else if (value == 'share') {
                // Share track
                debugPrint('Share track');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Album art and track info
            Expanded(
              flex: 3,
              child: Padding(
                padding: ResponsiveLayout.getResponsivePadding(context),
                child: Column(
                  children: [
                    // Album art
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: currentTrack.artwork != null
                              ? Image.memory(
                                  currentTrack.artwork!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    Icons.album,
                                    size: ResponsiveLayout.getResponsiveIconSize(context, baseSize: 100),
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Track info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentTrack.title,
                            style: TextStyle(
                              fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 20),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentTrack.artist,
                            style: TextStyle(
                              fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 16),
                              color: Theme.of(context).hintColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentTrack.album,
                            style: TextStyle(
                              fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 14),
                              color: Theme.of(context).hintColor,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Progress bar
            Padding(
              padding: ResponsiveLayout.getResponsivePadding(context),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_position),
                    style: TextStyle(
                      fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 12),
                    ),
                  ),
                  Slider(
                    value: _position.inMilliseconds.toDouble(),
                    min: 0.0,
                    max: _duration.inMilliseconds.toDouble(),
                    onChanged: _seekToPosition,
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: TextStyle(
                      fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            // Controls
            Expanded(
              flex: 1,
              child: Padding(
                padding: ResponsiveLayout.getResponsivePadding(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        size: ResponsiveLayout.getResponsiveIconSize(context),
                      ),
                      onPressed: () {
                        widget.playlistManager.shuffle();
                        debugPrint('Shuffle playlist');
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        size: ResponsiveLayout.getResponsiveIconSize(context, baseSize: 32),
                      ),
                      onPressed: _goToPrevious,
                    ),
                    FloatingActionButton(
                      onPressed: _togglePlayPause,
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: ResponsiveLayout.getResponsiveIconSize(context, baseSize: 32),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        size: ResponsiveLayout.getResponsiveIconSize(context, baseSize: 32),
                      ),
                      onPressed: _goToNext,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        size: ResponsiveLayout.getResponsiveIconSize(context),
                      ),
                      onPressed: () {
                        debugPrint('Repeat mode');
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Lyrics panel
            if (_showLyrics)
              Expanded(
                flex: 1,
                child: Container(
                  padding: ResponsiveLayout.getResponsivePadding(context),
                  child: SingleChildScrollView(
                    child: Text(
                      'Lyrics would appear here for ${currentTrack.title}. '
                      'In a real implementation, this would fetch and display the lyrics for the current track.',
                      style: TextStyle(
                        fontSize: ResponsiveLayout.getResponsiveFontSize(context, baseSize: 14),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}