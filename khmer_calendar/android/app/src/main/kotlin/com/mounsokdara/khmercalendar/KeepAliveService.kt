package com.mounsokdara.khmercalendar

import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.IBinder

/** Kept so older installs can stop the old persistent notification. Never shown. */
class KeepAliveService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        running = false
        dismiss()
        stopSelf()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        running = false
        dismiss()
        stopSelf()
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        running = false
        dismiss()
        super.onDestroy()
    }

    private fun dismiss() {
        try {
            getSystemService(NotificationManager::class.java)?.cancel(ID)
        } catch (_: Exception) {
        }
    }

    companion object {
        const val CHANNEL = "khmer_keep_alive"
        const val ID = 41

        @Volatile
        var running: Boolean = false
    }
}
