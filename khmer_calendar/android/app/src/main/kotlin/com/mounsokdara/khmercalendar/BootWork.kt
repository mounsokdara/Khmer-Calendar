package com.mounsokdara.khmercalendar

import android.app.NotificationManager
import android.content.Context
import android.content.Intent

/** Shared work for process start (App Startup) and BOOT_COMPLETED. */
object BootWork {
    fun run(context: Context) {
        val app = context.applicationContext
        try {
            app.stopService(Intent(app, KeepAliveService::class.java))
            app.getSystemService(NotificationManager::class.java)
                ?.cancel(KeepAliveService.ID)
        } catch (_: Exception) {
        }
        try {
            NotifyKit.sync(app)
        } catch (_: Exception) {
        }
        try {
            TodayWidgetProvider.refreshAll(app)
            MonthWidgetProvider.refreshAll(app)
            WeatherWidgetProvider.refreshAll(app)
        } catch (_: Exception) {
        }
    }
}
