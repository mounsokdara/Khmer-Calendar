package com.mounsokdara.khmercalendar

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.Calendar

object DailyNotify {
    fun arm(context: Context, showNow: Boolean) {
        if (!WidgetStore.notificationsOn(context)) return
        ensureChannel(context)
        schedule(context)
        val prefs = WidgetStore.prefs(context)
        val never = !prefs.getBoolean("dailyShown", false)
        if (showNow || never) {
            show(context)
            prefs.edit().putBoolean("dailyShown", true).apply()
        }
    }

    fun cancel(context: Context) {
        val am = context.getSystemService(AlarmManager::class.java) ?: return
        am.cancel(alarmPi(context))
        context.getSystemService(NotificationManager::class.java)?.cancel(WidgetStore.NOTIFY_ID)
    }

    fun show(context: Context) {
        if (!WidgetStore.notificationsOn(context)) return
        ensureChannel(context)
        val iso = WidgetStore.todayIso()
        val payload = WidgetStore.dayPayload(context, iso)
        val weekday = payload?.optString("weekday").takeUnless { it.isNullOrEmpty() } ?: WidgetStore.weekdayToday(context)
        val day = Calendar.getInstance().get(Calendar.DAY_OF_MONTH)
        val lunar = payload?.optString("lunar").orEmpty()
        val holiday = payload?.optString("holiday").orEmpty()
        val title = "$weekday $day"
        val body =
            listOf(lunar, holiday).filter { it.isNotEmpty() }.joinToString("  ")
                .ifEmpty { WidgetStore.title(context) }
        val nm = context.getSystemService(NotificationManager::class.java) ?: return
        val builder =
            if (Build.VERSION.SDK_INT >= 26) {
                Notification.Builder(context, WidgetStore.CHANNEL)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(context)
            }
        val n =
            builder
                .setSmallIcon(R.drawable.ic_stat_notify)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(Notification.BigTextStyle().bigText(body))
                .setAutoCancel(true)
                .setContentIntent(WidgetStore.launch(context, "day"))
                .build()
        nm.notify(WidgetStore.NOTIFY_ID, n)
    }

    fun schedule(context: Context) {
        val am = context.getSystemService(AlarmManager::class.java) ?: return
        val whenAt = nextMorning()
        val pi = alarmPi(context)
        try {
            if (Build.VERSION.SDK_INT >= 31 && !am.canScheduleExactAlarms()) {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, whenAt, pi)
            } else {
                am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, whenAt, pi)
            }
        } catch (_: Exception) {
            try {
                am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, whenAt, pi)
            } catch (_: Exception) {
            }
        }
    }

    private fun nextMorning(): Long {
        val c = Calendar.getInstance()
        c.set(Calendar.HOUR_OF_DAY, 7)
        c.set(Calendar.MINUTE, 0)
        c.set(Calendar.SECOND, 0)
        c.set(Calendar.MILLISECOND, 0)
        if (c.timeInMillis <= System.currentTimeMillis() + 30_000) c.add(Calendar.DATE, 1)
        return c.timeInMillis
    }

    private fun alarmPi(context: Context): PendingIntent {
        val intent = Intent(context, DailyNotifyReceiver::class.java)
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, WidgetStore.ALARM_REQ, intent, flags)
    }

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < 26) return
        val nm = context.getSystemService(NotificationManager::class.java) ?: return
        val ch =
            NotificationChannel(WidgetStore.CHANNEL, WidgetStore.CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH)
        ch.description = "Morning Khmer calendar"
        ch.enableVibration(true)
        nm.createNotificationChannel(ch)
    }
}

class DailyNotifyReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        DailyNotify.show(context)
        DailyNotify.schedule(context)
        TodayWidgetProvider.refreshAll(context)
        MonthWidgetProvider.refreshAll(context)
        WeatherWidgetProvider.refreshAll(context)
    }
}
