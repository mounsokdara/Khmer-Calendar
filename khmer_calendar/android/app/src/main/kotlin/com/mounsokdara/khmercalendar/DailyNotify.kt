package com.mounsokdara.khmercalendar

import android.content.Context

/** Compatibility entry. The daily recap lives in DailyDigestNotify. */
object DailyNotify {
    fun arm(context: Context, showNow: Boolean) {
        if (!WidgetStore.dailyOn(context)) {
            DailyDigestNotify.cancel(context)
            return
        }
        DailyDigestNotify.schedule(context)
        if (showNow) DailyDigestNotify.show(context)
    }

    fun cancel(context: Context) {
        DailyDigestNotify.cancel(context)
    }

    fun show(context: Context) {
        DailyDigestNotify.show(context)
    }

    fun schedule(context: Context) {
        DailyDigestNotify.schedule(context)
    }
}
