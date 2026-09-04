package io.github.marcelositr.daymark

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val SYSTEM_LOCK_CHANNEL =
            "io.github.marcelositr.daymark/system_lock"
        private const val SYSTEM_LOCK_METHOD = "locked"
    }

    private var systemLockChannel: MethodChannel? = null
    private var screenOffReceiverRegistered = false

    private val screenOffReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == Intent.ACTION_SCREEN_OFF) {
                systemLockChannel?.invokeMethod(SYSTEM_LOCK_METHOD, null)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        systemLockChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SYSTEM_LOCK_CHANNEL,
        )

        val filter = IntentFilter(Intent.ACTION_SCREEN_OFF)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(
                screenOffReceiver,
                filter,
                Context.RECEIVER_NOT_EXPORTED,
            )
        } else {
            @Suppress("DEPRECATION")
            registerReceiver(screenOffReceiver, filter)
        }
        screenOffReceiverRegistered = true
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        if (screenOffReceiverRegistered) {
            unregisterReceiver(screenOffReceiver)
            screenOffReceiverRegistered = false
        }
        systemLockChannel = null

        super.cleanUpFlutterEngine(flutterEngine)
    }
}
