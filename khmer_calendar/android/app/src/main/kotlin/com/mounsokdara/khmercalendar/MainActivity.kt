package com.mounsokdara.khmercalendar

import android.app.AlarmManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private var pendingCode = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
                    try {
                        ContextCompat.startForegroundService(this, Intent(this, KeepAliveService::class.java))
                        result.success(true)
                    } catch (_: Exception) {
                        result.success(false)
                    }
                }
                "stopKeepAlive" -> {
                    stopService(Intent(this, KeepAliveService::class.java))
                    result.success(true)
                }
                else -> result.notImplemented()
            }
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
            else -> r.success(true)
        }
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
