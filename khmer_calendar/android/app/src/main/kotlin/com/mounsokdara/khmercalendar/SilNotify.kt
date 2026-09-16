package com.mounsokdara.khmercalendar

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Reminder only on សីល days. Separate from the daily recap. */
object SilNotify {
    fun arm(context: Context, showNow: Boolean) {
        if (!WidgetStore.silOn(context)) {
            cancel(context)
            return
        }
        schedule(context)
        if (showNow && WidgetStore.isSilDay(context)) show(context)
    }

    fun schedule(context: Context) {
        if (!WidgetStore.silOn(context)) {
            cancel(context)
            return
        }
        val next = WidgetStore.nextSilAt(context) ?: return
        NotifyKit.ensureChannels(context)
        NotifyKit.setExact(
            context,
            next,
            NotifyKit.broadcastPi(context, SilNotifyReceiver::class.java, NotifyKit.SIL_REQ),
        )
    }

    fun cancel(context: Context) {
        NotifyKit.cancelAlarm(
            context,
            NotifyKit.broadcastPi(context, SilNotifyReceiver::class.java, NotifyKit.SIL_REQ),
        )
        NotifyKit.cancelNote(context, NotifyKit.SIL_ID)
    }

    fun show(context: Context) {
        if (!WidgetStore.silOn(context)) return
        if (!WidgetStore.isSilDay(context)) return
        val lang = WidgetStore.lang(context)
        val iso = WidgetStore.todayIso()
        val payload = WidgetStore.dayPayload(context, iso)
        val lunar = payload?.optString("lunar").orEmpty()
        val title = if (lang == "en") "Silas day" else "ថ្ងៃសីល"
        val body = lunar.ifEmpty { title }
        NotifyKit.post(context, NotifyKit.SIL_ID, NotifyKit.CHANNEL_SIL, title, body, "day", iso)
    }
}

class SilNotifyReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!WidgetStore.silOn(context)) {
            SilNotify.cancel(context)
            return
        }
        SilNotify.show(context)
        SilNotify.schedule(context)
    }
}
