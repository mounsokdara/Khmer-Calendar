package com.mounsokdara.khmercalendar

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

object NotifyKit {
    const val CHANNEL_DAILY = "khmer_daily"
    const val CHANNEL_SIL = "khmer_sil"
    const val CHANNEL_HOLIDAYS = "khmer_holidays"
    const val CHANNEL_EVENTS = "khmer_events"
    const val CHANNEL_TASKS = "khmer_tasks"
    const val DAILY_ID = 1001
    const val SIL_ID = 1002
    const val DAILY_REQ = 41
    const val SIL_REQ = 42

    fun dailyOn(context: Context): Boolean = WidgetStore.dailyOn(context)

    fun silOn(context: Context): Boolean = WidgetStore.silOn(context)

    fun ensureChannels(context: Context) {
        if (Build.VERSION.SDK_INT < 26) return
        val nm = context.getSystemService(NotificationManager::class.java) ?: return
        listOf("khmer_daily_digest", "khmer_reminders").forEach { id ->
            try {
                nm.deleteNotificationChannel(id)
            } catch (_: Exception) {
            }
        }
        val km = WidgetStore.lang(context) != "en"
        fun ch(id: String, name: String, desc: String, high: Boolean = false) {
            val c =
                NotificationChannel(
                    id,
                    name,
                    if (high) NotificationManager.IMPORTANCE_HIGH else NotificationManager.IMPORTANCE_DEFAULT,
                )
            c.description = desc
            c.enableVibration(true)
            nm.createNotificationChannel(c)
        }
        ch(CHANNEL_DAILY, if (km) "រំលឹកប្រចាំថ្ងៃ" else "Daily reminder", if (km) "ជូនដំណឹងព្រឹកពីប្រតិទិនថ្ងៃនេះ" else "Morning calendar recap")
        ch(CHANNEL_SIL, if (km) "ថ្ងៃសីល" else "Silas day", if (km) "ជូនដំណឹងនៅថ្ងៃសីល" else "Reminder on precept days", high = true)
        ch(CHANNEL_HOLIDAYS, if (km) "ថ្ងៃឈប់សម្រាក" else "Holidays", if (km) "ថ្ងៃឈប់សម្រាកសាធារណៈ" else "Public holidays")
        ch(CHANNEL_EVENTS, if (km) "ព្រឹត្តិការណ៍" else "Events", if (km) "ព្រឹត្តិការណ៍ក្នុងប្រតិទិន" else "Calendar events")
        ch(CHANNEL_TASKS, if (km) "កិច្ចការ" else "Tasks", if (km) "ការរំលឹកកិច្ចការ" else "Task reminders")
    }

    fun post(context: Context, id: Int, channel: String, title: String, body: String, tab: String, date: String?) {
        ensureChannels(context)
        val nm = context.getSystemService(NotificationManager::class.java) ?: return
        val builder =
            if (Build.VERSION.SDK_INT >= 26) {
                Notification.Builder(context, channel)
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
                .setContentIntent(WidgetStore.launch(context, tab, date))
                .build()
        nm.notify(id, n)
    }

    fun cancelNote(context: Context, id: Int) {
        context.getSystemService(NotificationManager::class.java)?.cancel(id)
        context.getSystemService(NotificationManager::class.java)?.cancel(WidgetStore.NOTIFY_ID)
    }

    fun setExact(context: Context, whenAt: Long, pi: PendingIntent) {
        val am = context.getSystemService(AlarmManager::class.java) ?: return
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

    fun cancelAlarm(context: Context, pi: PendingIntent) {
        context.getSystemService(AlarmManager::class.java)?.cancel(pi)
    }

    fun broadcastPi(context: Context, cls: Class<*>, req: Int): PendingIntent {
        val intent = Intent(context, cls)
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, req, intent, flags)
    }

    fun morningOf(year: Int, month: Int, day: Int): Long {
        val c = java.util.Calendar.getInstance()
        c.set(year, month - 1, day, 7, 0, 0)
        c.set(java.util.Calendar.MILLISECOND, 0)
        return c.timeInMillis
    }

    fun nextMorning(): Long {
        val c = java.util.Calendar.getInstance()
        c.set(java.util.Calendar.HOUR_OF_DAY, 7)
        c.set(java.util.Calendar.MINUTE, 0)
        c.set(java.util.Calendar.SECOND, 0)
        c.set(java.util.Calendar.MILLISECOND, 0)
        if (c.timeInMillis <= System.currentTimeMillis() + 30_000) c.add(java.util.Calendar.DATE, 1)
        return c.timeInMillis
    }

    fun sync(context: Context) {
        if (dailyOn(context)) DailyDigestNotify.schedule(context) else DailyDigestNotify.cancel(context)
        if (silOn(context)) SilNotify.schedule(context) else SilNotify.cancel(context)
    }

    fun writeFlags(context: Context, notifyOn: Boolean?, notifyDaily: Boolean?, notifySil: Boolean?) {
        val ed = WidgetStore.prefs(context).edit()
        notifyOn?.let { ed.putBoolean("notifyOn", it) }
        notifyDaily?.let { ed.putBoolean("notifyDaily", it) }
        notifySil?.let { ed.putBoolean("notifySil", it) }
        ed.apply()
    }
}
