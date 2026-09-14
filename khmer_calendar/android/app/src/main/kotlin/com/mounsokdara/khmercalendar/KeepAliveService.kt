package com.mounsokdara.khmercalendar

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

class KeepAliveService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        running = true
        startInForeground()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        running = true
        startInForeground()
        return START_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        restartIfWanted()
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        running = false
        super.onDestroy()
    }

    private fun restartIfWanted() {
        val flags = getSharedPreferences(BootReceiver.PREFS, MODE_PRIVATE)
        if (flags.getBoolean("background", false) || flags.getBoolean("autoLaunch", false)) {
            try {
                ContextCompat.startForegroundService(this, Intent(this, KeepAliveService::class.java))
            } catch (_: Exception) {
            }
        }
    }

    private fun startInForeground() {
        val nm = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26) {
            val ch = NotificationChannel(CHANNEL, "Background", NotificationManager.IMPORTANCE_LOW)
            ch.setShowBadge(false)
            nm.createNotificationChannel(ch)
        }
        val launch =
            PendingIntent.getActivity(
                this,
                0,
                Intent(this, MainActivity::class.java),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
        val notification: Notification =
            NotificationCompat.Builder(this, CHANNEL)
                .setContentTitle("ប្រតិទិនខ្មែរ")
                .setContentText("កំពុងដំណើរការផ្ទៃខាងក្រោយ")
                .setSmallIcon(R.drawable.ic_stat_notify)
                .setContentIntent(launch)
                .setOngoing(true)
                .setSilent(true)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build()
        try {
            if (Build.VERSION.SDK_INT >= 34) {
                startForeground(
                    ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
                )
            } else if (Build.VERSION.SDK_INT >= 29) {
                startForeground(ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
            } else {
                startForeground(ID, notification)
            }
        } catch (_: Exception) {
            try {
                startForeground(ID, notification)
            } catch (_: Exception) {
            }
        }
    }

    companion object {
        const val CHANNEL = "khmer_keep_alive"
        const val ID = 41

        @Volatile
        var running: Boolean = false
    }
}
