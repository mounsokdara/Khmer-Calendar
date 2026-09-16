package com.mounsokdara.khmercalendar

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONObject

/** Reminder only on Silas (សីល) days. */
object SilNotify {
    fun schedule(context: Context) {
        if (!NotifyKit.silOn(context)) {
            cancel(context)
            return
        }
        val next = nextSilMillis(context) ?: return
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
        if (!NotifyKit.silOn(context)) return
        val iso = WidgetStore.todayIso()
        val lang = WidgetStore.lang(context)
        val title = if (lang == "en") "Silas day" else "ថ្ង្ទៃសីល"
        val payload = WidgetStore.dayPayload(context, iso)
        val lunar = payload?.optString("lunar").orEmpty()
        val body =
            lunar.ifEmpty {
                if (lang == "en") "A Buddhist precept day" else "ថ្ង្ទៃបួសសីលរបស៍ពុទ្ធសាសនិកជន"
            }
        NotifyKit.post(context, NotifyKit.SIL_ID, NotifyKit.CHANNEL_SIL, title, body, "day", iso)
    }

    private fun nextSilMillis(context: Context): Long? {
        val raw = WidgetStore.prefs(context).getString("marks", null) ?: return NotifyKit.nextMorning()
        val marks =
            try {
                JSONObject(raw)
            } catch (_: Exception) {
                return NotifyKit.nextMorning()
            }
        val today = WidgetStore.todayIso()
        val keys = marks.keys().asSequence().filter { marks.optString(it).contains('s') }.sorted().toList()
        val pick = keys.firstOrNull { it > today } ?: keys.firstOrNull { it == today }
        if (pick == null) return NotifyKit.nextMorning()
        val p = pick.split("-")
        if (p.size < 3) return NotifyKit.nextMorning()
        val whenAt = NotifyKit.morningOf(p[0].toInt(), p[1].toInt(), p[2].toInt())
        return if (whenAt <= System.currentTimeMillis() + 30_000) {
            keys.firstOrNull { it > today }?.let {
                val n = it.split("-")
                if (n.size >= 3) NotifyKit.morningOf(n[0].toInt(), n[1].toInt(), n[2].toInt()) else NotifyKit.nextMorning()
            } ?: NotifyKit.nextMorning()
        } else {
            whenAt
        }
    }
}

class SilNotifyReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!NotifyKit.silOn(context)) {
            SilNotify.cancel(context)
            return
        }
        val iso = WidgetStore.todayIso()
        val raw = WidgetStore.prefs(context).getString("marks", null)
        val isSil =
            try {
                raw != null && JSONObject(raw).optString(iso).contains('s')
            } catch (_: Exception) {
                false
            }
        if (isSil) SilNotify.show(context)
        SilNotify.schedule(context)
    }
}
