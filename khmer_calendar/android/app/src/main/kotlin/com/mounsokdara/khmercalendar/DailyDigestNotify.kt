package com.mounsokdara.khmercalendar

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import java.util.Calendar

/** Optional morning digest. Off unless notifyDaily is explicitly true. */
object DailyDigestNotify {
    fun schedule(context: Context) {
        if (!NotifyKit.dailyOn(context)) {
            cancel(context)
            return
        }
        NotifyKit.ensureChannels(context)
        NotifyKit.setExact(
            context,
            NotifyKit.nextMorning(),
            NotifyKit.broadcastPi(context, DailyNotifyReceiver::class.java, NotifyKit.DAILY_REQ),
        )
    }

    fun cancel(context: Context) {
        NotifyKit.cancelAlarm(
            context,
            NotifyKit.broadcastPi(context, DailyNotifyReceiver::class.java, NotifyKit.DAILY_REQ),
        )
        NotifyKit.cancelNote(context, NotifyKit.DAILY_ID)
    }

    fun show(context: Context) {
        if (!NotifyKit.dailyOn(context)) return
        val iso = WidgetStore.todayIso()
        val payload = WidgetStore.dayPayload(context, iso)
        val weekday = payload?.optString("weekday").takeUnless { it.isNullOrEmpty() } ?: WidgetStore.weekdayToday(context)
        val day = Calendar.getInstance().get(Calendar.DAY_OF_MONTH)
        val lunar = payload?.optString("lunar").orEmpty()
        val holiday = payload?.optString("holiday").orEmpty()
        val body =
            listOf(lunar, holiday).filter { it.isNotEmpty() }.joinToString("  ")
                .ifEmpty { WidgetStore.title(context) }
        NotifyKit.post(context, NotifyKit.DAILY_ID, NotifyKit.CHANNEL_DAILY, "$weekday $day", body, "day", iso)
    }
}

/** Kept so already-queued daily alarms still land here after the 1.0.1 update. */
class DailyNotifyReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!NotifyKit.dailyOn(context)) {
            DailyDigestNotify.cancel(context)
        } else {
            DailyDigestNotify.show(context)
            DailyDigestNotify.schedule(context)
        }
        TodayWidgetProvider.refreshAll(context)
        MonthWidgetProvider.refreshAll(context)
        WeatherWidgetProvider.refreshAll(context)
    }
}
