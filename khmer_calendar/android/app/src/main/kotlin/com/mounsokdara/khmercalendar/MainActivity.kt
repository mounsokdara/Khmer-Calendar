package com.mounsokdara.khmercalendar

import android.app.AlarmManager
import android.app.AppOpsManager
import android.app.NotificationManager
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private var pendingCode = 0
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        NotifyKit.ensureChannels(this)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "setFlags" -> {
                    val bg = call.argument<Boolean>("background") ?: false
                    val auto = call.argument<Boolean>("autoLaunch") ?: false
                    getSharedPreferences(BootReceiver.PREFS, Context.MODE_PRIVATE)
                        .edit()
                        .putBoolean("background", bg)
                        .putBoolean("autoLaunch", auto)
                        .apply()
                    result.success(true)
                }
                "checkStatus" -> result.success(statusMap())
                "isIgnoringBattery" -> result.success(isIgnoringBattery())
                "requestBatteryExemption" -> requestBatteryExemption(result)
                "openBatterySettings" ->
                    startOrFail(result, REQ_BATTERY_LIST, Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                "requestExactAlarm" -> requestExactAlarm(result)
                "openAutoStart" -> openAutoStart(result)
                "openAppSettings" ->
                    startOrFail(
                        result,
                        REQ_SETTINGS,
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(Uri.parse("package:$packageName")),
                    )
                "openLocationSettings" ->
                    startOrFail(result, REQ_LOCATION, Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS))
                "startKeepAlive" -> {
                    stopKeepAlive()
                    result.success(true)
                }
                "stopKeepAlive" -> {
                    stopKeepAlive()
                    result.success(true)
                }
                "updateWidget" -> {
                    saveWidget(call.arguments)
                    TodayWidgetProvider.refreshAll(this)
                    MonthWidgetProvider.refreshAll(this)
                    WeatherWidgetProvider.refreshAll(this)
                    result.success(true)
                }
                "pinWidget" -> result.success(pinWidget(call.argument<String>("kind")))
                "armDaily" -> {
                    DailyNotify.arm(this, call.argument<Boolean>("showNow") ?: false)
                    result.success(true)
                }
                "cancelDaily" -> {
                    DailyNotify.cancel(this)
                    result.success(true)
                }
                "armSil" -> {
                    SilNotify.arm(this, call.argument<Boolean>("showNow") ?: false)
                    result.success(true)
                }
                "cancelSil" -> {
                    SilNotify.cancel(this)
                    result.success(true)
                }
                "getLaunch" -> result.success(launchMap(intent))
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        channel?.invokeMethod("open", launchMap(intent))
    }

    private fun launchMap(src: Intent?): HashMap<String, String> {
        val tab = src?.getStringExtra("tab") ?: ""
        val date = src?.getStringExtra("date") ?: ""
        return hashMapOf("tab" to tab, "date" to date)
    }

    private fun saveWidget(args: Any?) {
        val map = args as? Map<*, *> ?: return
        val ed = getSharedPreferences(WidgetStore.PREFS, Context.MODE_PRIVATE).edit()
        fun putStr(key: String) {
            val v = map[key]
            if (v is String) ed.putString(key, v)
        }
        listOf(
            "iso", "day", "weekday", "lunar", "holiday", "title", "days", "marks", "names", "lang",
            "wx_city", "wx_city_en", "wx_temp", "wx_high", "wx_low", "wx_label", "wx_label_en", "wx_list",
            "sil_days", "public_hols", "religious_hols",
        ).forEach { putStr(it) }
        (map["weekStartsOn"] as? Number)?.let { ed.putInt("weekStartsOn", it.toInt()) }
        (map["wx_index"] as? Number)?.let { ed.putInt("wx_index", it.toInt()) }
        (map["notifyOn"] as? Boolean)?.let { ed.putBoolean("notifyOn", it) }
        (map["notifyDaily"] as? Boolean)?.let { ed.putBoolean("notifyDaily", it) }
        (map["notifySil"] as? Boolean)?.let { ed.putBoolean("notifySil", it) }
        (map["notifyPublic"] as? Boolean)?.let { ed.putBoolean("notifyPublic", it) }
        (map["notifyReligious"] as? Boolean)?.let { ed.putBoolean("notifyReligious", it) }
        ed.apply()
        NotifyKit.sync(this)
    }

    private fun pinWidget(kind: String?): Boolean {
        if (Build.VERSION.SDK_INT < 26) return false
        val mgr = getSystemService(AppWidgetManager::class.java) ?: return false
        if (!mgr.isRequestPinAppWidgetSupported) return false
        val cls =
            when (kind) {
                "month" -> MonthWidgetProvider::class.java
                "weather" -> WeatherWidgetProvider::class.java
                else -> TodayWidgetProvider::class.java
            }
        return try {
            mgr.requestPinAppWidget(ComponentName(this, cls), null, null)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun stopKeepAlive() {
        try {
            stopService(Intent(this, KeepAliveService::class.java))
        } catch (_: Exception) {
        }
        try {
            getSystemService(NotificationManager::class.java)?.cancel(KeepAliveService.ID)
        } catch (_: Exception) {
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != pendingCode) return
        val r = pending ?: return
        pending = null
        pendingCode = 0
        when (requestCode) {
            REQ_BATTERY -> r.success(isIgnoringBattery())
            REQ_EXACT -> r.success(canExactAlarms())
            REQ_AUTOSTART -> r.success(isAutoStartEnabled() || !autoStartQueryable())
            else -> r.success(true)
        }
    }

    private fun statusMap(): HashMap<String, Boolean> {
        val auto = autoStartOp()
        return hashMapOf(
            "notify" to notificationsEnabled(),
            "battery" to isIgnoringBattery(),
            "exactAlarm" to canExactAlarms(),
            "autoStart" to auto.second,
            "autoStartQueryable" to auto.first,
            "stock" to isStockAndroid(),
            "keepAlive" to KeepAliveService.running,
        )
    }

    private fun notificationsEnabled(): Boolean {
        if (Build.VERSION.SDK_INT >= 33) {
            val granted =
                ContextCompat.checkSelfPermission(this, android.Manifest.permission.POST_NOTIFICATIONS) ==
                    PackageManager.PERMISSION_GRANTED
            if (!granted) return false
        }
        if (Build.VERSION.SDK_INT >= 24) {
            val nm = getSystemService(NotificationManager::class.java) ?: return false
            return nm.areNotificationsEnabled()
        }
        return true
    }

    private fun isIgnoringBattery(): Boolean {
        if (Build.VERSION.SDK_INT < 23) return true
        val pm = getSystemService(PowerManager::class.java) ?: return true
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    private fun canExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT < 31) return true
        val am = getSystemService(AlarmManager::class.java) ?: return false
        return am.canScheduleExactAlarms()
    }

    private fun isStockAndroid(): Boolean {
        val maker = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        return listOf("google", "pixel", "aosp").any { maker.contains(it) || brand.contains(it) }
    }

    /** First = OEM exposes an auto-start op we can read. Second = that op is allowed. */
    private fun autoStartOp(): Pair<Boolean, Boolean> {
        val maker = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        val known =
            listOf("xiaomi", "redmi", "poco", "blackshark", "vivo", "iqoo", "oppo", "realme", "oneplus")
                .any { maker.contains(it) || brand.contains(it) }
        if (!known) return false to false
        return try {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val checkOp =
                appOps.javaClass.getMethod(
                    "checkOpNoThrow",
                    Integer.TYPE,
                    Integer.TYPE,
                    String::class.java,
                )
            val uid = Process.myUid()
            var queryable = false
            for (op in intArrayOf(10008, 10020, 10021, 10025)) {
                try {
                    val mode = checkOp.invoke(appOps, op, uid, packageName) as Int
                    queryable = true
                    if (mode == AppOpsManager.MODE_ALLOWED) return true to true
                } catch (_: Exception) {
                }
            }
            queryable to false
        } catch (_: Exception) {
            false to false
        }
    }

    private fun autoStartQueryable(): Boolean = autoStartOp().first

    private fun isAutoStartEnabled(): Boolean = autoStartOp().second

    private fun requestBatteryExemption(result: MethodChannel.Result) {
        if (isIgnoringBattery()) {
            result.success(true)
            return
        }
        val ask =
            Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                .setData(Uri.parse("package:$packageName"))
        if (tryStart(result, REQ_BATTERY, ask)) return
        startOrFail(result, REQ_BATTERY, Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
    }

    private fun requestExactAlarm(result: MethodChannel.Result) {
        if (canExactAlarms()) {
            result.success(true)
            return
        }
        if (Build.VERSION.SDK_INT < 31) {
            result.success(true)
            return
        }
        val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).setData(Uri.parse("package:$packageName"))
        startOrFail(result, REQ_EXACT, intent)
    }

    private fun openAutoStart(result: MethodChannel.Result) {
        val tries =
            listOf(
                ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
                ComponentName("com.miui.securitycenter", "com.miui.powercenter.PowerSettings"),
                ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
                ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"),
                ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity"),
                ComponentName("com.hihonor.systemmanager", "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
                ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
                ComponentName("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity"),
                ComponentName("com.coloros.oppoguardelf", "com.coloros.powermanager.fuelgaue.PowerUsageModelActivity"),
                ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity"),
                ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"),
                ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager"),
                ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"),
                ComponentName("com.samsung.android.lool", "com.samsung.android.sm.battery.ui.BatteryActivity"),
                ComponentName("com.samsung.android.sm", "com.samsung.android.sm.ui.battery.BatteryActivity"),
                ComponentName("com.oneplus.security", "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity"),
                ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.AutobootManageActivity"),
                ComponentName("com.asus.mobilemanager", "com.asus.mobilemanager.autostart.AutoStartActivity"),
                ComponentName("com.transsion.phonemanager", "com.transsion.phonemanager.startup.StartupAppListActivity"),
                ComponentName("com.transsion.phonemaster", "com.cyin.himgr.autostart.AutoStartActivity"),
                ComponentName("com.evenwell.powersaving.g3", "com.evenwell.powersaving.g3.exception.PowerSaverExceptionActivity"),
            )
        for (c in tries) {
            if (tryStart(result, REQ_AUTOSTART, Intent().setComponent(c))) return
        }
        startOrFail(
            result,
            REQ_AUTOSTART,
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).setData(Uri.parse("package:$packageName")),
        )
    }

    private fun startOrFail(result: MethodChannel.Result, code: Int, intent: Intent) {
        if (!tryStart(result, code, intent)) result.success(false)
    }

    /** Returns true if the activity was started and [result] will complete later. */
    private fun tryStart(result: MethodChannel.Result, code: Int, intent: Intent): Boolean {
        return try {
            pending?.success(false)
            pending = result
            pendingCode = code
            @Suppress("DEPRECATION")
            startActivityForResult(intent, code)
            true
        } catch (_: Exception) {
            pending = null
            pendingCode = 0
            false
        }
    }

    companion object {
        const val CHANNEL = "khmer.permissions"
        private const val REQ_BATTERY = 7101
        private const val REQ_BATTERY_LIST = 7102
        private const val REQ_EXACT = 7103
        private const val REQ_AUTOSTART = 7104
        private const val REQ_SETTINGS = 7105
        private const val REQ_LOCATION = 7106
    }
}
