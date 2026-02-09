package com.lx.music.automotive;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.view.KeyEvent;

public class AutomotiveMediaButtonReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        // Check if the intent is a media button event
        if (Intent.ACTION_MEDIA_BUTTON.equals(intent.getAction())) {
            KeyEvent event = intent.getParcelableExtra(Intent.EXTRA_KEY_EVENT);
            if (event != null) {
                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    Intent serviceIntent = new Intent(context, AutomotiveMediaService.class);
                    
                    switch (event.getKeyCode()) {
                        case KeyEvent.KEYCODE_MEDIA_PLAY:
                            serviceIntent.setAction("ACTION_PLAY");
                            context.startService(serviceIntent);
                            break;
                        case KeyEvent.KEYCODE_MEDIA_PAUSE:
                            serviceIntent.setAction("ACTION_PAUSE");
                            context.startService(serviceIntent);
                            break;
                        case KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE:
                            if (event.getFlags() == KeyEvent.FLAG_FROM_SYSTEM) {
                                // This is a headset button press, toggle play/pause
                                serviceIntent.setAction(isPlaying() ? "ACTION_PAUSE" : "ACTION_PLAY");
                                context.startService(serviceIntent);
                            }
                            break;
                        case KeyEvent.KEYCODE_MEDIA_NEXT:
                            serviceIntent.setAction("ACTION_NEXT");
                            context.startService(serviceIntent);
                            break;
                        case KeyEvent.KEYCODE_MEDIA_PREVIOUS:
                            serviceIntent.setAction("ACTION_PREVIOUS");
                            context.startService(serviceIntent);
                            break;
                    }
                }
                // Always return if the event was handled to prevent other receivers from processing
                if (isOrderedBroadcast()) {
                    abortBroadcast();
                }
            }
        }
    }

    // Placeholder method - in a real implementation, this would check the actual playback state
    private boolean isPlaying() {
        return false;
    }
}