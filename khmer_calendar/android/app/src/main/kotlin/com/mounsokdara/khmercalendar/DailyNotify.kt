package com.mounsokdara.khmercalendar

import android.content.Context

/** Compatibility shim. Daily digest lives in DailyDigestNotify. */
object DailyNotify {
    fun arm(context: Context, showNow: Boolean) {
        if (NotifyKit.dailyOn(context)) {
            DailyDigestNotify.schedule(context)
            if (showNow) DailyDigestNotify.show(context)
        } else {
            DailyDigestNotify.cancel(context)
        }
        if (NotifyKit.silOn(context)) SilNotify.schedule(context) else SilNotify.cancel(context)
    }

    fun cancel(context: Context) {
        DailyDigestNotify.cancel(context)
        SilNotify.cancel(context)
    }
}
