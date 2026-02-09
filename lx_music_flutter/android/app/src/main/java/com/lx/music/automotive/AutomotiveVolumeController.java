package com.lx.music.automotive;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Build;

public class AutomotiveVolumeController {
    private AudioManager audioManager;
    private AudioFocusRequest audioFocusRequest;
    private Context context;
    private boolean isRegistered = false;

    public AutomotiveVolumeController(Context context) {
        this.context = context;
        this.audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
    }

    /**
     * Requests audio focus for the music player
     */
    public boolean requestAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            AudioFocusRequest.Builder builder = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN);
            builder.setAudioAttributes(
                new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            );
            builder.setAcceptsDelayedFocusGain(true);
            builder.setOnAudioFocusChangeListener(audioFocusChangeListener);
            
            audioFocusRequest = builder.build();
            int result = audioManager.requestAudioFocus(audioFocusRequest);
            return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED;
        } else {
            // Fallback for older versions
            int result = audioManager.requestAudioFocus(
                audioFocusChangeListener,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN
            );
            return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED;
        }
    }

    /**
     * Abandons audio focus when no longer needed
     */
    public void abandonAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (audioFocusRequest != null) {
                audioManager.abandonAudioFocusRequest(audioFocusRequest);
            }
        } else {
            audioManager.abandonAudioFocus(audioFocusChangeListener);
        }
    }

    /**
     * Adjusts the volume by the specified amount
     */
    public void adjustVolume(int direction) {
        // Adjust the volume using the music stream
        audioManager.adjustStreamVolume(
            AudioManager.STREAM_MUSIC,
            direction,
            AudioManager.FLAG_SHOW_UI
        );
    }

    /**
     * Sets the volume to a specific level
     */
    public void setVolume(int volume) {
        int maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
        int newVolume = Math.max(0, Math.min(volume, maxVolume));
        
        audioManager.setStreamVolume(
            AudioManager.STREAM_MUSIC,
            newVolume,
            AudioManager.FLAG_SHOW_UI
        );
    }

    /**
     * Gets the current volume level
     */
    public int getCurrentVolume() {
        return audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
    }

    /**
     * Gets the maximum volume level
     */
    public int getMaxVolume() {
        return audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
    }

    /**
     * Audio focus change listener to handle when other apps request audio focus
     */
    private AudioManager.OnAudioFocusChangeListener audioFocusChangeListener = 
        new AudioManager.OnAudioFocusChangeListener() {
            @Override
            public void onAudioFocusChange(int focusChange) {
                switch (focusChange) {
                    case AudioManager.AUDIOFOCUS_GAIN:
                        // Resume playback or restore volume
                        handleAudioFocusGain();
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS:
                        // Stop playback completely
                        handleAudioFocusLoss();
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                        // Pause playback temporarily
                        handleAudioFocusLossTransient();
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                        // Lower volume but continue playing
                        handleAudioFocusLossTransientCanDuck();
                        break;
                }
            }
        };

    private void handleAudioFocusGain() {
        // In a real implementation, this would resume playback if it was paused
        System.out.println("Audio focus gained - resume playback if needed");
    }

    private void handleAudioFocusLoss() {
        // In a real implementation, this would stop playback
        System.out.println("Audio focus lost - stop playback");
    }

    private void handleAudioFocusLossTransient() {
        // In a real implementation, this would pause playback temporarily
        System.out.println("Audio focus temporarily lost - pause playback");
    }

    private void handleAudioFocusLossTransientCanDuck() {
        // In a real implementation, this would lower the volume
        System.out.println("Audio focus loss - duck volume");
    }

    /**
     * Registers for volume change broadcasts
     */
    public void registerVolumeChangeReceiver() {
        // In a real implementation, this would register a broadcast receiver
        // to listen for volume changes from automotive systems
        isRegistered = true;
    }

    /**
     * Unregisters the volume change receiver
     */
    public void unregisterVolumeChangeReceiver() {
        // In a real implementation, this would unregister the broadcast receiver
        isRegistered = false;
    }

    /**
     * Checks if the device is connected to a car audio system
     */
    public boolean isConnectedToCarAudio() {
        // Check if connected via Bluetooth to a car audio system
        // This is a simplified check - a real implementation would be more sophisticated
        return audioManager.isBluetoothA2dpOn() || audioManager.isWiredHeadsetOn();
    }
}