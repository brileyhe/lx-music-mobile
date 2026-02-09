import '../utils/logger.dart';

/// Represents a music track in the playlist
class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String url;
  final Duration duration;
  final String? artwork;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.url,
    required this.duration,
    this.artwork,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'url': url,
        'duration': duration.inSeconds,
        'artwork': artwork,
      };

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        id: json['id'],
        title: json['title'],
        artist: json['artist'],
        album: json['album'],
        url: json['url'],
        duration: Duration(seconds: json['duration']),
        artwork: json['artwork'],
      );
}

/// Manages playlists and tracks
class PlaylistManager {
  List<Track> _tracks = [];
  int _currentIndex = -1;

  /// Adds a track to the playlist
  void addTrack(Track track) {
    _tracks.add(track);
    Logger.info('Added track to playlist: ${track.title}');
  }

  /// Adds multiple tracks to the playlist
  void addTracks(List<Track> tracks) {
    _tracks.addAll(tracks);
    Logger.info('Added ${tracks.length} tracks to playlist');
  }

  /// Removes a track at the specified index
  void removeTrackAt(int index) {
    if (index >= 0 && index < _tracks.length) {
      _tracks.removeAt(index);
      if (_currentIndex >= _tracks.length) {
        _currentIndex = _tracks.isEmpty ? -1 : _tracks.length - 1;
      } else if (index < _currentIndex) {
        _currentIndex--;
      }
      Logger.info('Removed track at index $index');
    }
  }

  /// Clears the entire playlist
  void clearPlaylist() {
    _tracks.clear();
    _currentIndex = -1;
    Logger.info('Cleared playlist');
  }

  /// Moves to the next track in the playlist
  Track? nextTrack() {
    if (_tracks.isEmpty) return null;

    _currentIndex = (_currentIndex + 1) % _tracks.length;
    Logger.info('Moved to next track: ${currentTrack?.title}');
    return currentTrack;
  }

  /// Moves to the previous track in the playlist
  Track? previousTrack() {
    if (_tracks.isEmpty) return null;

    _currentIndex = _currentIndex <= 0 ? _tracks.length - 1 : _currentIndex - 1;
    Logger.info('Moved to previous track: ${currentTrack?.title}');
    return currentTrack;
  }

  /// Jumps to a specific track in the playlist
  Track? jumpToIndex(int index) {
    if (index >= 0 && index < _tracks.length) {
      _currentIndex = index;
      Logger.info('Jumped to track: ${currentTrack?.title}');
      return currentTrack;
    }
    return null;
  }

  /// Gets the current track
  Track? get currentTrack {
    if (_currentIndex >= 0 && _currentIndex < _tracks.length) {
      return _tracks[_currentIndex];
    }
    return null;
  }

  /// Gets the current track index
  int get currentIndex => _currentIndex;

  /// Gets all tracks in the playlist
  List<Track> get tracks => List.unmodifiable(_tracks);

  /// Checks if the playlist is empty
  bool get isEmpty => _tracks.isEmpty;

  /// Gets the total number of tracks in the playlist
  int get length => _tracks.length;

  /// Shuffles the playlist
  void shuffle() {
    // Very basic shuffle algorithm
    for (int i = _tracks.length - 1; i > 0; i--) {
      int j = DateTime.now().millisecondsSinceEpoch % (i + 1);
      _tracks[i] = _tracks[j];
    }
    Logger.info('Playlist shuffled');
  }

  /// Moves a track from one position to another
  void moveTrack(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _tracks.length || 
        toIndex < 0 || toIndex >= _tracks.length) {
      return;
    }

    final track = _tracks.removeAt(fromIndex);
    _tracks.insert(toIndex, track);

    // Adjust current index if needed
    if (_currentIndex == fromIndex) {
      _currentIndex = toIndex;
    } else if (fromIndex < _currentIndex && toIndex >= _currentIndex) {
      _currentIndex--;
    } else if (fromIndex > _currentIndex && toIndex <= _currentIndex) {
      _currentIndex++;
    }

    Logger.info('Moved track from $fromIndex to $toIndex');
  }
}