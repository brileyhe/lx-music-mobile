import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/logger.dart';

/// Audio playback service that handles music playback functionality
/// This mirrors the functionality from react-native-track-player
class AudioPlaybackService extends BackgroundAudioTask {
  late AudioPlayer _audioPlayer;
  late AudioHandler _audioHandler;
  
  @override
  Future<void> onStart(AudioServiceBackgroundContext context) async {
    _audioPlayer = AudioPlayer();
    _audioHandler = await AudioService.init(
      builder: () => _audioPlayer,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.lx.music.audio',
        androidNotificationChannelName: 'LX Music Audio',
        androidNotificationOngoing: true,
      ),
    );
    
    // Handle player events
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        _audioHandler.state.add(_audioHandler.state.value.copyWith(
          processingState: AudioProcessingState.ready,
          playing: true,
        ));
      } else {
        _audioHandler.state.add(_audioHandler.state.value.copyWith(
          playing: false,
        ));
      }
    });
    
    Logger.info('Audio playback service started');
  }

  @override
  Future<void> onStop() async {
    await _audioPlayer.dispose();
    await _audioHandler.close();
    await super.onStop();
  }

  @override
  Future<void> onPause() async {
    await _audioPlayer.pause();
    _audioHandler.state.add(_audioHandler.state.value.copyWith(playing: false));
  }

  @override
  Future<void> onPlay() async {
    await _audioPlayer.play();
    _audioHandler.state.add(_audioHandler.state.value.copyWith(playing: true));
  }

  @override
  Future<void> onSkipToNext() async {
    // Implementation for skipping to next track
    Logger.info('Skipping to next track');
  }

  @override
  Future<void> onSkipToPrevious() async {
    // Implementation for skipping to previous track
    Logger.info('Skipping to previous track');
  }

  @override
  Future<void> onSeekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Plays a track with the given URL
  Future<void> playTrack(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      _audioHandler.state.add(_audioHandler.state.value.copyWith(playing: true));
    } catch (e) {
      Logger.error('Failed to play track: $e');
    }
  }

  /// Pauses the current track
  Future<void> pauseTrack() async {
    await _audioPlayer.pause();
    _audioHandler.state.add(_audioHandler.state.value.copyWith(playing: false));
  }

  /// Stops playback
  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    _audioHandler.state.add(_audioHandler.state.value.copyWith(playing: false));
  }
}