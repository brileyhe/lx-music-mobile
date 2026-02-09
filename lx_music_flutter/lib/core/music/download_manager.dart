import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../utils/logger.dart';

/// Represents a download task
class DownloadTask {
  final String id;
  final String url;
  final String fileName;
  final String title;
  final String artist;
  final String album;
  DownloadStatus status;
  int progress;
  String? filePath;
  String? errorMessage;

  DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    required this.title,
    required this.artist,
    required this.album,
    this.status = DownloadStatus.pending,
    this.progress = 0,
    this.filePath,
    this.errorMessage,
  });
}

/// Status of a download task
enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

/// Manages music downloads for offline listening
class DownloadManager {
  final List<DownloadTask> _downloadQueue = [];
  final Map<String, StreamController<int>> _progressControllers = {};
  final HttpClient _httpClient = HttpClient();

  /// Starts downloading a track
  Future<void> downloadTrack({
    required String id,
    required String url,
    required String fileName,
    required String title,
    required String artist,
    required String album,
  }) async {
    // Check if already downloading
    if (_downloadQueue.any((task) => task.id == id)) {
      Logger.warn('Download already exists for track: $id');
      return;
    }

    final task = DownloadTask(
      id: id,
      url: url,
      fileName: fileName,
      title: title,
      artist: artist,
      album: album,
    );

    _downloadQueue.add(task);
    _progressControllers[id] = StreamController<int>();

    try {
      await _performDownload(task);
    } catch (e) {
      Logger.error('Download failed for track $id: $e');
      task.status = DownloadStatus.failed;
      task.errorMessage = e.toString();
    }
  }

  /// Performs the actual download
  Future<void> _performDownload(DownloadTask task) async {
    task.status = DownloadStatus.downloading;
    Logger.info('Starting download for: ${task.title}');

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDocDir.path}/downloads/${task.fileName}';
      task.filePath = filePath;

      // Create downloads directory if it doesn't exist
      final Directory downloadsDir = Directory('${appDocDir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final File file = File(filePath);
      final IOSink fileSink = file.openWrite();

      final response = await http.Client().send(http.Request('GET', Uri.parse(task.url)));

      int downloaded = 0;
      final int total = response.contentLength ?? 0;

      await for (final chunk in response.stream) {
        await fileSink.add(chunk);
        downloaded += chunk.length;

        if (total > 0) {
          task.progress = ((downloaded / total) * 100).round();
          _progressControllers[task.id]?.add(task.progress);
        }
      }

      await fileSink.close();
      task.status = DownloadStatus.completed;
      Logger.info('Download completed for: ${task.title}');
    } catch (e) {
      task.status = DownloadStatus.failed;
      task.errorMessage = e.toString();
      Logger.error('Download failed: $e');
      rethrow;
    }
  }

  /// Pauses a download
  void pauseDownload(String taskId) {
    final task = _downloadQueue.firstWhere(
      (task) => task.id == taskId,
      orElse: () => throw Exception('Download task not found: $taskId'),
    );

    if (task.status == DownloadStatus.downloading) {
      task.status = DownloadStatus.paused;
      Logger.info('Paused download: ${task.title}');
    }
  }

  /// Resumes a paused download
  Future<void> resumeDownload(String taskId) async {
    final task = _downloadQueue.firstWhere(
      (task) => task.id == taskId,
      orElse: () => throw Exception('Download task not found: $taskId'),
    );

    if (task.status == DownloadStatus.paused) {
      await _performDownload(task);
    }
  }

  /// Cancels a download
  void cancelDownload(String taskId) {
    final task = _downloadQueue.firstWhere(
      (task) => task.id == taskId,
      orElse: () => throw Exception('Download task not found: $taskId'),
    );

    task.status = DownloadStatus.cancelled;
    _progressControllers[taskId]?.close();
    _progressControllers.remove(taskId);
    Logger.info('Cancelled download: ${task.id}');
  }

  /// Gets all download tasks
  List<DownloadTask> getAllDownloads() {
    return List.unmodifiable(_downloadQueue);
  }

  /// Gets a specific download task
  DownloadTask? getDownloadById(String taskId) {
    return _downloadQueue.firstWhere(
      (task) => task.id == taskId,
      orElse: () => null,
    );
  }

  /// Gets download progress stream for a specific task
  Stream<int>? getDownloadProgress(String taskId) {
    return _progressControllers[taskId]?.stream;
  }

  /// Checks if a track is already downloaded
  Future<bool> isTrackDownloaded(String fileName) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String filePath = '${appDocDir.path}/downloads/$fileName';
    final File file = File(filePath);
    return await file.exists();
  }

  /// Gets the file path for a downloaded track
  Future<String?> getDownloadedFilePath(String fileName) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String filePath = '${appDocDir.path}/downloads/$fileName';
    final File file = File(filePath);
    
    if (await file.exists()) {
      return filePath;
    }
    return null;
  }

  /// Deletes a downloaded file
  Future<void> deleteDownloadedFile(String fileName) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String filePath = '${appDocDir.path}/downloads/$fileName';
    final File file = File(filePath);
    
    if (await file.exists()) {
      await file.delete();
      Logger.info('Deleted downloaded file: $fileName');
    }
  }

  /// Cleans up resources
  Future<void> dispose() async {
    for (final controller in _progressControllers.values) {
      await controller.close();
    }
    _progressControllers.clear();
    _httpClient.close();
  }
}