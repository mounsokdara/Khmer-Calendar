package com.mounsokdara.khmercalendar

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

private const val RELIGIOUS_BLUE = 0xFF1E88E5.toInt()
private const val MAX_HOLIDAY_ALARMS = 24

private fun holidayAt(iso: String, hour: Int): Long? {
    val bits = iso.split("-")
    if (bits.size < 3) return null
    val c = Calendar.getInstance()
    c.set(bits[0].toInt(), bits[1].toInt() - 1, bits[2].toInt(), hour, 0, 0)
    c.set(Calendar.MILLISECOND, 0)
    return c.timeInMillis
}

private fun holidayPi(context: Context, cls: Class<*>, req: Int, iso: String): PendingIntent {
    val intent = Intent(context, cls).putExtra("date", iso)
    val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    return PendingIntent.getBroadcast(context, req, intent, flags)
}

private fun listedHolidays(context: Context, listKey: String): List<Pair<String, JSONObject>> {
    val raw = WidgetStore.prefs(context).getString(listKey, "[]") ?: return emptyList()
    return try {
        val arr = JSONArray(raw)
        val out = ArrayList<Pair<String, JSONObject>>()
        for (i in 0 until arr.length()) {
            val o = arr.optJSONObject(i) ?: continue
            val iso = o.optString("d")
            if (iso.length >= 10) out.add(iso to o)
        }
        out
    } catch (_: Exception) {
        emptyList()
    }
}

private fun scheduleHolidayAlarms(context: Context, listKey: String, cls: Class<*>, baseReq: Int, hour: Int) {
    val now = System.currentTimeMillis()
    var n = 0
    for ((iso, _) in listedHolidays(context, listKey)) {
        val at = holidayAt(iso, hour) ?: continue
        if (at <= now + 30_000) continue
        NotifyKit.setExact(context, at, holidayPi(context, cls, baseReq + n, iso))
        n++
        if (n >= MAX_HOLIDAY_ALARMS) break
    }
}

private fun cancelHolidayAlarms(context: Context, cls: Class<*>, baseReq: Int) {
    for (i in 0 until MAX_HOLIDAY_ALARMS) {
        NotifyKit.cancelAlarm(context, holidayPi(context, cls, baseReq + i, ""))
    }
}

object PublicHolidayNotify {
    const val LIST = "public_hols"

    fun arm(context: Context, showNow: Boolean) {
        if (!WidgetStore.publicOn(context)) {
            cancel(context)
            return
        }
        schedule(context)
        if (showNow) show(context)
    }

    fun schedule(context: Context) {
        if (!WidgetStore.publicOn(context)) {
            cancel(context)
            return
        }
        NotifyKit.ensureChannels(context)
        cancelHolidayAlarms(context, PublicHolidayReceiver::class.java, NotifyKit.PUBLIC_REQ)
        scheduleHolidayAlarms(context, LIST, PublicHolidayReceiver::class.java, NotifyKit.PUBLIC_REQ, 8)
    }

    fun cancel(context: Context) {
        cancelHolidayAlarms(context, PublicHolidayReceiver::class.java, NotifyKit.PUBLIC_REQ)
        NotifyKit.cancelNote(context, NotifyKit.PUBLIC_ID)
    }

    fun show(context: Context, iso: String = WidgetStore.todayIso()) {
        if (!WidgetStore.publicOn(context)) return
        val item = WidgetStore.holidayEntry(context, LIST, iso) ?: return
        val km = WidgetStore.lang(context) != "en"
        val name = if (km) item.optString("km") else item.optString("en")
        val kind = if (km) "ថ្ងៃឈប់សម្រាកសាធារណៈ" else "Public holiday"
        val body = listOf(kind, WidgetStore.dayDetail(context, iso)).filter { it.isNotEmpty() }.joinToString("\n")
        NotifyKit.post(context, NotifyKit.PUBLIC_ID, NotifyKit.CHANNEL_PUBLIC, name.ifEmpty { kind }, body, "day", iso)
    }
}

class PublicHolidayReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!WidgetStore.publicOn(context)) {
            PublicHolidayNotify.cancel(context)
            return
        }
        PublicHolidayNotify.show(context, intent.getStringExtra("date") ?: WidgetStore.todayIso())
        PublicHolidayNotify.schedule(context)
    }
}

object ReligiousHolidayNotify {
    const val LIST = "religious_hols"

    fun arm(context: Context, showNow: Boolean) {
        if (!WidgetStore.religiousOn(context)) {
            cancel(context)
            return
        }
        schedule(context)
        if (showNow) show(context)
    }

    fun schedule(context: Context) {
        if (!WidgetStore.religiousOn(context)) {
            cancel(context)
            return
        }
        NotifyKit.ensureChannels(context)
        cancelHolidayAlarms(context, ReligiousHolidayReceiver::class.java, NotifyKit.RELIGIOUS_REQ)
        scheduleHolidayAlarms(context, LIST, ReligiousHolidayReceiver::class.java, NotifyKit.RELIGIOUS_REQ, 8)
    }

    fun cancel(context: Context) {
        cancelHolidayAlarms(context, ReligiousHolidayReceiver::class.java, NotifyKit.RELIGIOUS_REQ)
        NotifyKit.cancelNote(context, NotifyKit.RELIGIOUS_ID)
    }

    fun show(context: Context, iso: String = WidgetStore.todayIso()) {
        if (!WidgetStore.religiousOn(context)) return
        val item = WidgetStore.holidayEntry(context, LIST, iso) ?: return
        val km = WidgetStore.lang(context) != "en"
        val name = if (km) item.optString("km") else item.optString("en")
        val kind = if (km) "ថ្ងៃបុណ្យសាសនា" else "Religious holiday"
        val body = listOf(kind, WidgetStore.dayDetail(context, iso)).filter { it.isNotEmpty() }.joinToString("\n")
        NotifyKit.post(
            context,
            NotifyKit.RELIGIOUS_ID,
            NotifyKit.CHANNEL_RELIGIOUS,
            name.ifEmpty { kind },
            body,
            "day",
            iso,
            color = RELIGIOUS_BLUE,
        )
    }
}

class ReligiousHolidayReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!WidgetStore.religiousOn(context)) {
            ReligiousHolidayNotify.cancel(context)
            return
        }
        ReligiousHolidayNotify.show(context, intent.getStringExtra("date") ?: WidgetStore.todayIso())
        ReligiousHolidayNotify.schedule(context)
    }
}
