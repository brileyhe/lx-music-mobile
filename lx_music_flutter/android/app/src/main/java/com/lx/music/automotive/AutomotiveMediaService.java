package com.lx.music.automotive;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

public class AutomotiveMediaService extends Service {
    private static final String TAG = "AutomotiveMediaService";

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "AutomotiveMediaService created");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        String action = intent.getAction();
        if (action != null) {
            switch (action) {
                case "ACTION_PLAY":
                    handlePlay();
                    break;
                case "ACTION_PAUSE":
                    handlePause();
                    break;
                case "ACTION_NEXT":
                    handleNext();
                    break;
                case "ACTION_PREVIOUS":
                    handlePrevious();
                    break;
            }
        }
        return START_NOT_STICKY;
    }

    private void handlePlay() {
        Log.d(TAG, "Handling play command");
        // In a real implementation, this would communicate with the Flutter side
    }

    private void handlePause() {
        Log.d(TAG, "Handling pause command");
        // In a real implementation, this would communicate with the Flutter side
    }

    private void handleNext() {
        Log.d(TAG, "Handling next command");
        // In a real implementation, this would communicate with the Flutter side
    }

    private void handlePrevious() {
        Log.d(TAG, "Handling previous command");
        // In a real implementation, this would communicate with the Flutter side
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "AutomotiveMediaService destroyed");
    }
}