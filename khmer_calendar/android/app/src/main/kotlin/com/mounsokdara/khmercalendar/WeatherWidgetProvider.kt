package com.mounsokdara.khmercalendar

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

class WeatherWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val views = build(context)
        for (id in appWidgetIds) appWidgetManager.updateAppWidget(id, views)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action ?: return
        if (action == Intent.ACTION_DATE_CHANGED ||
            action == Intent.ACTION_TIMEZONE_CHANGED ||
            action == Intent.ACTION_TIME_CHANGED ||
            action == Intent.ACTION_BOOT_COMPLETED ||
            action == AppWidgetManager.ACTION_APPWIDGET_UPDATE
        ) {
            refreshAll(context)
        }
    }

    companion object {
        fun refreshAll(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, WeatherWidgetProvider::class.java))
            if (ids.isEmpty()) return
            val views = build(context)
            for (id in ids) mgr.updateAppWidget(id, views)
        }

        private fun build(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.khmer_weather_widget)
            val p = WidgetStore.prefs(context)
            val lang = WidgetStore.lang(context)
            val city = if (lang == "en") p.getString("wx_city_en", "") else p.getString("wx_city", "")
            val temp = p.getString("wx_temp", "") ?: ""
            val high = p.getString("wx_high", "") ?: ""
            val low = p.getString("wx_low", "") ?: ""
            val label = if (lang == "en") p.getString("wx_label_en", "") else p.getString("wx_label", "")
            val empty = temp.isEmpty()
            views.setTextViewText(R.id.wx_city, if (city.isNullOrEmpty()) WidgetStore.title(context) else city)
            if (empty) {
                views.setTextViewText(R.id.wx_temp, "--")
                views.setTextViewText(R.id.wx_label, if (lang == "en") "Open the app for weather" else "បើកកម្មវិធីសម្រាប់អាកាសធាតុ")
                views.setViewVisibility(R.id.wx_range, View.GONE)
            } else {
                views.setTextViewText(R.id.wx_temp, "$temp°")
                views.setTextViewText(R.id.wx_label, label ?: "")
                views.setViewVisibility(R.id.wx_range, View.VISIBLE)
                views.setTextViewText(R.id.wx_range, "H $high°   L $low°")
            }
            views.setOnClickPendingIntent(R.id.wx_root, WidgetStore.launch(context, "weather"))
            return views
        }
    }
}
