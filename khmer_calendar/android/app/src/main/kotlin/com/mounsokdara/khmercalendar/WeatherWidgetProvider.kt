package com.mounsokdara.khmercalendar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject

class WeatherWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) appWidgetManager.updateAppWidget(id, build(context, id))
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action ?: return
        if (action == ACTION_SHIFT) {
            val widgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            val dir = intent.getIntExtra(EXTRA_DIR, 0)
            shift(context, widgetId, dir)
            if (widgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                AppWidgetManager.getInstance(context).updateAppWidget(widgetId, build(context, widgetId))
            } else {
                refreshAll(context)
            }
            return
        }
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
        const val ACTION_SHIFT = "com.mounsokdara.khmercalendar.WEATHER_SHIFT"
        const val EXTRA_DIR = "dir"

        fun refreshAll(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, WeatherWidgetProvider::class.java))
            for (id in ids) mgr.updateAppWidget(id, build(context, id))
        }

        private fun list(context: Context): JSONArray {
            val raw = WidgetStore.prefs(context).getString("wx_list", null) ?: return JSONArray()
            return try {
                JSONArray(raw)
            } catch (_: Exception) {
                JSONArray()
            }
        }

        private fun shownIndex(context: Context, widgetId: Int, size: Int): Int {
            if (size <= 0) return 0
            val p = WidgetStore.prefs(context)
            val i = p.getInt("wx_i_$widgetId", p.getInt("wx_index", 0))
            return ((i % size) + size) % size
        }

        private fun shift(context: Context, widgetId: Int, dir: Int) {
            if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return
            val n = list(context).length()
            if (n <= 0) return
            val next = shownIndex(context, widgetId, n) + dir
            WidgetStore.prefs(context).edit().putInt("wx_i_$widgetId", ((next % n) + n) % n).apply()
        }

        private fun shiftPi(context: Context, widgetId: Int, dir: Int, req: Int): PendingIntent {
            val intent =
                Intent(context, WeatherWidgetProvider::class.java)
                    .setAction(ACTION_SHIFT)
                    .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                    .putExtra(EXTRA_DIR, dir)
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            return PendingIntent.getBroadcast(context, req + widgetId * 10, intent, flags)
        }

        private fun bmp(path: String?, max: Int): Bitmap? {
            if (path.isNullOrEmpty()) return null
            return try {
                val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
                BitmapFactory.decodeFile(path, bounds)
                var sample = 1
                val w = bounds.outWidth.coerceAtLeast(1)
                while (w / sample > max) sample *= 2
                BitmapFactory.decodeFile(path, BitmapFactory.Options().apply { inSampleSize = sample })
            } catch (_: Exception) {
                null
            }
        }

        private fun build(context: Context, widgetId: Int): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.khmer_weather_widget)
            val lang = WidgetStore.lang(context)
            val cities = list(context)
            val n = cities.length()
            val open = WidgetStore.launch(context, "weather")
            views.setOnClickPendingIntent(R.id.wx_root, open)
            views.setOnClickPendingIntent(R.id.wx_city, open)
            if (n <= 0) {
                views.setTextViewText(R.id.wx_city, WidgetStore.title(context))
                views.setTextViewText(R.id.wx_temp, "--")
                views.setTextViewText(
                    R.id.wx_label,
                    if (lang == "en") "Open the app for weather" else "បើកកម្មវិធីសម្រាប់អាកាសធាតុ",
                )
                views.setViewVisibility(R.id.wx_range, View.GONE)
                views.setViewVisibility(R.id.wx_count, View.GONE)
                views.setViewVisibility(R.id.wx_prev, View.GONE)
                views.setViewVisibility(R.id.wx_next, View.GONE)
                views.setViewVisibility(R.id.wx_icon, View.GONE)
                return views
            }
            val i = shownIndex(context, widgetId, n)
            val item = cities.optJSONObject(i) ?: JSONObject()
            val city = if (lang == "en") item.optString("nameEn") else item.optString("name")
            val temp = item.optString("temp")
            val high = item.optString("high")
            val low = item.optString("low")
            val label = if (lang == "en") item.optString("labelEn") else item.optString("label")
            views.setTextViewText(R.id.wx_city, city.ifEmpty { WidgetStore.title(context) })
            views.setTextViewText(R.id.wx_temp, if (temp.isEmpty()) "--" else "$temp°")
            views.setTextViewText(R.id.wx_label, label)
            if (high.isEmpty()) {
                views.setViewVisibility(R.id.wx_range, View.GONE)
            } else {
                views.setViewVisibility(R.id.wx_range, View.VISIBLE)
                views.setTextViewText(R.id.wx_range, "H $high°   L $low°")
            }
            views.setTextViewText(R.id.wx_count, "${i + 1}/$n")
            views.setViewVisibility(R.id.wx_count, if (n > 1) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.wx_prev, if (n > 1) View.VISIBLE else View.GONE)
            views.setViewVisibility(R.id.wx_next, if (n > 1) View.VISIBLE else View.GONE)
            val icon = bmp(item.optString("icon"), 128)
            if (icon != null) {
                views.setViewVisibility(R.id.wx_icon, View.VISIBLE)
                views.setImageViewBitmap(R.id.wx_icon, icon)
            } else {
                views.setViewVisibility(R.id.wx_icon, View.GONE)
            }
            val photo = bmp(item.optString("photo"), 480)
            if (photo != null) views.setImageViewBitmap(R.id.wx_photo, photo)
            views.setOnClickPendingIntent(R.id.wx_prev, shiftPi(context, widgetId, -1, 1))
            views.setOnClickPendingIntent(R.id.wx_next, shiftPi(context, widgetId, 1, 2))
            return views
        }
    }
}
