import 'dart:typed_data';
import 'package:id3/id3.dart' as id3;
import '../utils/logger.dart';

/// Represents audio metadata
class AudioMetadata {
  final String? title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final String? composer;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final int? totalTracks;
  final int? discNumber;
  final int? totalDiscs;
  final String? comment;
  final String? lyrics;
  final Uint8List? artwork;
  final String? mimeType;

  AudioMetadata({
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.composer,
    this.genre,
    this.year,
    this.trackNumber,
    this.totalTracks,
    this.discNumber,
    this.totalDiscs,
    this.comment,
    this.lyrics,
    this.artwork,
    this.mimeType,
  });

  /// Creates an empty metadata object
  static AudioMetadata empty() {
    return AudioMetadata();
  }
}

/// Parses audio metadata from files
class MetadataParser {
  /// Parses metadata from a file path
  static Future<AudioMetadata> parseFromFile(String filePath) async {
    try {
      // Using the id3 package to parse ID3 tags from MP3 files
      final tag = id3.Id3Tag.fromFilePath(filePath);
      
      if (tag == null) {
        Logger.warn('No ID3 tags found in file: $filePath');
        return AudioMetadata.empty();
      }

      // Extract image data if available
      Uint8List? artwork;
      if (tag.frames.whereType<id3.ImageFrame>().isNotEmpty) {
        final imageFrame = tag.frames.whereType<id3.ImageFrame>().first;
        artwork = Uint8List.fromList(imageFrame.imageData);
      }

      // Extract lyrics if available
      String? lyrics;
      if (tag.frames.whereType<id3.LyricsFrame>().isNotEmpty) {
        final lyricsFrame = tag.frames.whereType<id3.LyricsFrame>().first;
        lyrics = lyricsFrame.text;
      }

      return AudioMetadata(
        title: tag.frames.whereType<id3.TitleFrame>().firstOrNull?.text,
        artist: tag.frames.whereType<id3.ArtistFrame>().firstOrNull?.text,
        album: tag.frames.whereType<id3.AlbumFrame>().firstOrNull?.text,
        albumArtist: tag.frames.whereType<id3.AlbumArtistFrame>().firstOrNull?.text,
        composer: tag.frames.whereType<id3.ComposerFrame>().firstOrNull?.text,
        genre: tag.frames.whereType<id3.GenreFrame>().firstOrNull?.text,
        year: _parseYear(tag.frames.whereType<id3.YearFrame>().firstOrNull?.text),
        trackNumber: _parseTrackNumber(tag.frames.whereType<id3.TrackFrame>().firstOrNull?.text),
        comment: tag.frames.whereType<id3.CommentFrame>().firstOrNull?.text,
        lyrics: lyrics,
        artwork: artwork,
      );
    } catch (e) {
      Logger.error('Failed to parse metadata from $filePath: $e');
      return AudioMetadata.empty();
    }
  }

  /// Parses metadata from raw bytes
  static Future<AudioMetadata> parseFromBytes(Uint8List bytes) async {
    try {
      // Using the id3 package to parse ID3 tags from bytes
      final tag = id3.Id3Tag.fromBuffer(bytes.buffer.asUint8List());
      
      if (tag == null) {
        Logger.warn('No ID3 tags found in byte data');
        return AudioMetadata.empty();
      }

      // Extract image data if available
      Uint8List? artwork;
      if (tag.frames.whereType<id3.ImageFrame>().isNotEmpty) {
        final imageFrame = tag.frames.whereType<id3.ImageFrame>().first;
        artwork = Uint8List.fromList(imageFrame.imageData);
      }

      // Extract lyrics if available
      String? lyrics;
      if (tag.frames.whereType<id3.LyricsFrame>().isNotEmpty) {
        final lyricsFrame = tag.frames.whereType<id3.LyricsFrame>().first;
        lyrics = lyricsFrame.text;
      }

      return AudioMetadata(
        title: tag.frames.whereType<id3.TitleFrame>().firstOrNull?.text,
        artist: tag.frames.whereType<id3.ArtistFrame>().firstOrNull?.text,
        album: tag.frames.whereType<id3.AlbumFrame>().firstOrNull?.text,
        albumArtist: tag.frames.whereType<id3.AlbumArtistFrame>().firstOrNull?.text,
        composer: tag.frames.whereType<id3.ComposerFrame>().firstOrNull?.text,
        genre: tag.frames.whereType<id3.GenreFrame>().firstOrNull?.text,
        year: _parseYear(tag.frames.whereType<id3.YearFrame>().firstOrNull?.text),
        trackNumber: _parseTrackNumber(tag.frames.whereType<id3.TrackFrame>().firstOrNull?.text),
        comment: tag.frames.whereType<id3.CommentFrame>().firstOrNull?.text,
        lyrics: lyrics,
        artwork: artwork,
      );
    } catch (e) {
      Logger.error('Failed to parse metadata from bytes: $e');
      return AudioMetadata.empty();
    }
  }

  /// Helper to parse year from string
  static int? _parseYear(String? yearStr) {
    if (yearStr == null) return null;
    try {
      // Extract 4-digit year from string like "2023-01-01" or just "2023"
      final match = RegExp(r'\b(\d{4})\b').firstMatch(yearStr);
      return match != null ? int.tryParse(match.group(1)!) : int.tryParse(yearStr);
    } catch (e) {
      return null;
    }
  }

  /// Helper to parse track number from string
  static int? _parseTrackNumber(String? trackStr) {
    if (trackStr == null) return null;
    try {
      // Handle format like "1/10" or just "1"
      final parts = trackStr.split('/');
      return int.tryParse(parts[0]);
    } catch (e) {
      return int.tryParse(trackStr);
    }
  }

  /// Formats metadata for display
  static String formatDisplayTitle(AudioMetadata metadata) {
    if (metadata.title != null && metadata.artist != null) {
      return '${metadata.artist} - ${metadata.title}';
    } else if (metadata.title != null) {
      return metadata.title!;
    } else if (metadata.artist != null) {
      return metadata.artist!;
    } else {
      return 'Unknown Title';
    }
  }

  /// Formats metadata for display
  static String formatDisplayAlbum(AudioMetadata metadata) {
    return metadata.album ?? 'Unknown Album';
  }
}