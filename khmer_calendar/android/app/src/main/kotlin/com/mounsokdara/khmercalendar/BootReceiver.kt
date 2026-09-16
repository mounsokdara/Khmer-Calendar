package com.mounsokdara.khmercalendar

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_LOCKED_BOOT_COMPLETED &&
            action != Intent.ACTION_MY_PACKAGE_REPLACED &&
            action != Intent.ACTION_REBOOT &&
            action != "android.intent.action.QUICKBOOT_POWERON" &&
            action != "com.htc.intent.action.QUICKBOOT_POWERON" &&
            action != "android.intent.action.ACTION_BOOT_COMPLETED"
        ) {
            return
        }
        try {
            context.stopService(Intent(context, KeepAliveService::class.java))
            val nm = context.getSystemService(NotificationManager::class.java)
            nm?.cancel(KeepAliveService.ID)
        } catch (_: Exception) {
        }
        NotifyKit.sync(context)
        TodayWidgetProvider.refreshAll(context)
        MonthWidgetProvider.refreshAll(context)
        WeatherWidgetProvider.refreshAll(context)
    }

    companion object {
        const val PREFS = "khmer_perms"
    }
}
