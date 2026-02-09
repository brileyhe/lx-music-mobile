import 'package:just_audio/just_audio.dart';
import '../utils/logger.dart';

/// Represents an equalizer band with frequency and gain
class EqualizerBand {
  final double frequency; // in Hz
  final double minGain; // in dB
  final double maxGain; // in dB
  double gain; // in dB

  EqualizerBand({
    required this.frequency,
    required this.minGain,
    required this.maxGain,
    required this.gain,
  });
}

/// Manages equalizer and audio effects
class AudioEffectsManager {
  final AudioPlayer? _audioPlayer;
  List<EqualizerBand> _bands = [];
  bool _isEnabled = false;

  AudioEffectsManager(this._audioPlayer) {
    // Initialize with standard equalizer bands
    _initDefaultBands();
  }

  /// Initializes default equalizer bands
  void _initDefaultBands() {
    // Standard 5-band equalizer
    _bands = [
      EqualizerBand(frequency: 60, minGain: -12, maxGain: 12, gain: 0),    // Bass
      EqualizerBand(frequency: 230, minGain: -12, maxGain: 12, gain: 0),   // Low Midrange
      EqualizerBand(frequency: 910, minGain: -12, maxGain: 12, gain: 0),   // Midrange
      EqualizerBand(frequency: 3600, minGain: -12, maxGain: 12, gain: 0),  // High Midrange
      EqualizerBand(frequency: 14000, minGain: -12, maxGain: 12, gain: 0), // Treble
    ];
  }

  /// Enables/disables the equalizer
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    Logger.info('Equalizer ${enabled ? "enabled" : "disabled"}');
  }

  /// Gets the current state of the equalizer
  bool get isEnabled => _isEnabled;

  /// Sets the gain for a specific band
  void setBandGain(int bandIndex, double gain) {
    if (bandIndex >= 0 && bandIndex < _bands.length) {
      final band = _bands[bandIndex];
      // Clamp the gain to the valid range
      band.gain = gain.clamp(band.minGain, band.maxGain);
      Logger.debug('Set band ${band.frequency}Hz gain to ${band.gain}dB');
    }
  }

  /// Gets the gain for a specific band
  double getBandGain(int bandIndex) {
    if (bandIndex >= 0 && bandIndex < _bands.length) {
      return _bands[bandIndex].gain;
    }
    return 0.0;
  }

  /// Gets all equalizer bands
  List<EqualizerBand> get bands => List.unmodifiable(_bands);

  /// Applies a preset equalizer setting
  void applyPreset(EqualizerPreset preset) {
    switch (preset) {
      case EqualizerPreset.normal:
        for (int i = 0; i < _bands.length; i++) {
          _bands[i].gain = 0.0;
        }
        break;
      case EqualizerPreset.classical:
        _bands[0].gain = 0.0;   // 60Hz
        _bands[1].gain = 0.0;   // 230Hz
        _bands[2].gain = 0.0;   // 910Hz
        _bands[3].gain = 7.0;   // 3600Hz
        _bands[4].gain = 8.0;   // 14000Hz
        break;
      case EqualizerPreset.dance:
        _bands[0].gain = 5.0;   // 60Hz
        _bands[1].gain = 4.0;   // 230Hz
        _bands[2].gain = -1.0;  // 910Hz
        _bands[3].gain = 5.0;   // 3600Hz
        _bands[4].gain = 6.0;   // 14000Hz
        break;
      case EqualizerPreset.flat:
        for (int i = 0; i < _bands.length; i++) {
          _bands[i].gain = 0.0;
        }
        break;
      case EqualizerPreset.pop:
        _bands[0].gain = 2.0;   // 60Hz
        _bands[1].gain = 4.0;   // 230Hz
        _bands[2].gain = 3.0;   // 910Hz
        _bands[3].gain = 2.0;   // 3600Hz
        _bands[4].gain = 0.0;   // 14000Hz
        break;
      case EqualizerPreset.rock:
        _bands[0].gain = 4.0;   // 60Hz
        _bands[1].gain = 2.0;   // 230Hz
        _bands[2].gain = -3.0;  // 910Hz
        _bands[3].gain = 4.0;   // 3600Hz
        _bands[4].gain = 5.0;   // 14000Hz
        break;
    }
    Logger.info('Applied equalizer preset: ${preset.toString()}');
  }

  /// Sets the overall replay gain
  void setReplayGain(double gain) {
    // Just_audio doesn't have built-in replay gain, so we'll simulate it with volume
    // Note: This is a simplified implementation
    double clampedGain = gain.clamp(0.1, 2.0); // Limit between 0.1 and 2.0
    _audioPlayer?.setVolume(clampedGain);
    Logger.debug('Set replay gain to ${clampedGain.toStringAsFixed(2)}');
  }

  /// Sets the bass boost level
  void setBassBoost(double level) {
    // This would typically require platform-specific implementation
    // For now, we'll adjust the lowest frequency band
    double clampedLevel = level.clamp(0.0, 12.0);
    if (_bands.isNotEmpty) {
      _bands[0].gain = clampedLevel;
    }
    Logger.debug('Set bass boost to ${clampedLevel}dB');
  }

  /// Sets the virtualizer strength
  void setVirtualizer(double strength) {
    // Virtualizer effect would require platform-specific implementation
    // For now, we'll just log the attempt
    double clampedStrength = strength.clamp(0.0, 1.0);
    Logger.debug('Set virtualizer strength to ${clampedStrength.toStringAsFixed(2)}');
  }

  /// Sets the loudness enhancement
  void setLoudnessEnhancement(bool enabled) {
    // Loudness enhancement would require platform-specific implementation
    Logger.debug('Set loudness enhancement to ${enabled ? "on" : "off"}');
  }
}

/// Predefined equalizer presets
enum EqualizerPreset {
  normal,
  classical,
  dance,
  flat,
  pop,
  rock,
}