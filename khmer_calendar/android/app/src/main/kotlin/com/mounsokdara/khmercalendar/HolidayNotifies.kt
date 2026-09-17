package com.mounsokdara.khmercalendar

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

object PublicHolidayNotify {
    const val LIST = "public_hols"

    fun schedule(context: Context) {
        if (!WidgetStore.publicOn(context)) {
            cancel(context)
            return
        }
        val next = WidgetStore.nextListedAt(context, LIST, 8) ?: return
        NotifyKit.ensureChannels(context)
        NotifyKit.setExact(
            context,
            run {
                val bits = next.first.split("-")
                val c = java.util.Calendar.getInstance()
                c.set(bits[0].toInt(), bits[1].toInt() - 1, bits[2].toInt(), 8, 0, 0)
                c.set(java.util.Calendar.MILLISECOND, 0)
                c.timeInMillis
            },
            NotifyKit.broadcastPi(context, PublicHolidayReceiver::class.java, NotifyKit.PUBLIC_REQ),
        )
    }

    fun cancel(context: Context) {
        NotifyKit.cancelAlarm(
            context,
            NotifyKit.broadcastPi(context, PublicHolidayReceiver::class.java, NotifyKit.PUBLIC_REQ),
        )
        NotifyKit.cancelNote(context, NotifyKit.PUBLIC_ID)
    }

    fun show(context: Context) {
        if (!WidgetStore.publicOn(context)) return
        val iso = WidgetStore.todayIso()
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
        PublicHolidayNotify.show(context)
        PublicHolidayNotify.schedule(context)
    }
}

object ReligiousHolidayNotify {
    const val LIST = "religious_hols"

    fun schedule(context: Context) {
        if (!WidgetStore.religiousOn(context)) {
            cancel(context)
            return
        }
        val next = WidgetStore.nextListedAt(context, LIST, 8) ?: return
        NotifyKit.ensureChannels(context)
        NotifyKit.setExact(
            context,
            run {
                val bits = next.first.split("-")
                val c = java.util.Calendar.getInstance()
                c.set(bits[0].toInt(), bits[1].toInt() - 1, bits[2].toInt(), 8, 0, 0)
                c.set(java.util.Calendar.MILLISECOND, 0)
                c.timeInMillis
            },
            NotifyKit.broadcastPi(context, ReligiousHolidayReceiver::class.java, NotifyKit.RELIGIOUS_REQ),
        )
    }

    fun cancel(context: Context) {
        NotifyKit.cancelAlarm(
            context,
            NotifyKit.broadcastPi(context, ReligiousHolidayReceiver::class.java, NotifyKit.RELIGIOUS_REQ),
        )
        NotifyKit.cancelNote(context, NotifyKit.RELIGIOUS_ID)
    }

    fun show(context: Context) {
        if (!WidgetStore.religiousOn(context)) return
        val iso = WidgetStore.todayIso()
        val item = WidgetStore.holidayEntry(context, LIST, iso) ?: return
        val km = WidgetStore.lang(context) != "en"
        val name = if (km) item.optString("km") else item.optString("en")
        val kind = if (km) "ថ្ងៃបុណ្យសាសនា" else "Religious holiday"
        val body = listOf(kind, WidgetStore.dayDetail(context, iso)).filter { it.isNotEmpty() }.joinToString("\n")
        NotifyKit.post(context, NotifyKit.RELIGIOUS_ID, NotifyKit.CHANNEL_RELIGIOUS, name.ifEmpty { kind }, body, "day", iso)
    }
}

class ReligiousHolidayReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!WidgetStore.religiousOn(context)) {
            ReligiousHolidayNotify.cancel(context)
            return
        }
        ReligiousHolidayNotify.show(context)
        ReligiousHolidayNotify.schedule(context)
    }
}
