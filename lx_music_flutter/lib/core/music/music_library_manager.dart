import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../utils/logger.dart';
import '../music/playlist_manager.dart'; // Track class is defined here

/// Manages the music library database
class MusicLibraryDatabase {
  static Database? _database;

  /// Opens the database connection
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'music_library.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  /// Creates the necessary tables
  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE music_library (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT NOT NULL,
        url TEXT NOT NULL,
        duration INTEGER NOT NULL,
        artwork TEXT,
        added_date INTEGER NOT NULL,
        file_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_date INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE playlist_tracks (
        playlist_id TEXT NOT NULL,
        track_id TEXT NOT NULL,
        position INTEGER NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE,
        FOREIGN KEY (track_id) REFERENCES music_library (id) ON DELETE CASCADE,
        UNIQUE(playlist_id, position)
      )
    ''');

    Logger.info('Database tables created');
  }

  /// Closes the database connection
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

/// Manages the music library functionality
class MusicLibraryManager {
  /// Adds a track to the music library
  Future<void> addTrackToLibrary(Track track) async {
    final db = await MusicLibraryDatabase.database;
    
    await db.insert(
      'music_library',
      {
        'id': track.id,
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
        'url': track.url,
        'duration': track.duration.inSeconds,
        'artwork': track.artwork,
        'added_date': DateTime.now().millisecondsSinceEpoch,
        'file_path': Uri.parse(track.url).pathSegments.last,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    Logger.info('Added track to library: ${track.title}');
  }

  /// Adds multiple tracks to the music library
  Future<void> addTracksToLibrary(List<Track> tracks) async {
    final db = await MusicLibraryDatabase.database;
    
    Batch batch = db.batch();
    for (Track track in tracks) {
      batch.insert(
        'music_library',
        {
          'id': track.id,
          'title': track.title,
          'artist': track.artist,
          'album': track.album,
          'url': track.url,
          'duration': track.duration.inSeconds,
          'artwork': track.artwork,
          'added_date': DateTime.now().millisecondsSinceEpoch,
          'file_path': Uri.parse(track.url).pathSegments.last,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit();
    Logger.info('Added ${tracks.length} tracks to library');
  }

  /// Gets all tracks in the music library
  Future<List<Track>> getAllTracks() async {
    final db = await MusicLibraryDatabase.database;
    
    final List<Map<String, dynamic>> maps = await db.query('music_library');
    
    return List.generate(maps.length, (i) {
      return Track(
        id: maps[i]['id'],
        title: maps[i]['title'],
        artist: maps[i]['artist'],
        album: maps[i]['album'],
        url: maps[i]['url'],
        duration: Duration(seconds: maps[i]['duration']),
        artwork: maps[i]['artwork'],
      );
    });
  }

  /// Searches for tracks by title, artist, or album
  Future<List<Track>> searchTracks(String query) async {
    final db = await MusicLibraryDatabase.database;
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM music_library 
      WHERE title LIKE ? OR artist LIKE ? OR album LIKE ?
    ''', ['%$query%', '%$query%', '%$query%']);
    
    return List.generate(maps.length, (i) {
      return Track(
        id: maps[i]['id'],
        title: maps[i]['title'],
        artist: maps[i]['artist'],
        album: maps[i]['album'],
        url: maps[i]['url'],
        duration: Duration(seconds: maps[i]['duration']),
        artwork: maps[i]['artwork'],
      );
    });
  }

  /// Removes a track from the music library
  Future<void> removeTrackFromLibrary(String trackId) async {
    final db = await MusicLibraryDatabase.database;
    
    await db.delete(
      'music_library',
      where: 'id = ?',
      whereArgs: [trackId],
    );
    
    Logger.info('Removed track from library: $trackId');
  }

  /// Gets tracks by a specific artist
  Future<List<Track>> getTracksByArtist(String artist) async {
    final db = await MusicLibraryDatabase.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'music_library',
      where: 'artist = ?',
      whereArgs: [artist],
    );
    
    return List.generate(maps.length, (i) {
      return Track(
        id: maps[i]['id'],
        title: maps[i]['title'],
        artist: maps[i]['artist'],
        album: maps[i]['album'],
        url: maps[i]['url'],
        duration: Duration(seconds: maps[i]['duration']),
        artwork: maps[i]['artwork'],
      );
    });
  }

  /// Gets tracks from a specific album
  Future<List<Track>> getTracksByAlbum(String album) async {
    final db = await MusicLibraryDatabase.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'music_library',
      where: 'album = ?',
      whereArgs: [album],
    );
    
    return List.generate(maps.length, (i) {
      return Track(
        id: maps[i]['id'],
        title: maps[i]['title'],
        artist: maps[i]['artist'],
        album: maps[i]['album'],
        url: maps[i]['url'],
        duration: Duration(seconds: maps[i]['duration']),
        artwork: maps[i]['artwork'],
      );
    });
  }

  /// Checks if a track exists in the library
  Future<bool> trackExists(String trackId) async {
    final db = await MusicLibraryDatabase.database;
    
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM music_library WHERE id = ?',
      [trackId],
    ));
    
    return count! > 0;
  }
}