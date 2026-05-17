package com.example.recoder_app

import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.media.projection.MediaProjectionManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import android.view.Gravity
import android.view.WindowManager
import android.widget.TextView
import android.widget.ImageButton
import android.view.WindowManager.LayoutParams
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.recoder_app/system_audio"
    private val FLOATING_CHANNEL = "com.example.recoder_app/floating_window"
    private val FLOATING_EVENT_CHANNEL = "com.example.recoder_app/floating_window_events"
    private val MEDIA_PROJECTION_REQUEST_CODE = 1001
    private val OVERLAY_REQUEST_CODE = 1002

    private var pendingResult: MethodChannel.Result? = null
    private var floatingWindow: android.view.View? = null
    private var floatingParams: LayoutParams? = null
    private var pendingFloatingResult: MethodChannel.Result? = null
    private var floatingEventSink: EventChannel.EventSink? = null

    private var mediaProjectionData: Intent? = null
    private var systemAudioStartTime: Long = 0
    private var hasSystemAudioPermission = false

    private var systemAudioService: SystemAudioService? = null
    private var serviceBound = false
    private var pendingStartResult: MethodChannel.Result? = null
    private var pendingStartOutputPath: String? = null

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as SystemAudioService.LocalBinder
            systemAudioService = binder.getService()
            serviceBound = true

            val result = pendingStartResult ?: return
            val path = pendingStartOutputPath ?: return
            val projectionData = mediaProjectionData
            if (projectionData == null) {
                result.error("NO_PERMISSION", "MediaProjection permission not granted", null)
                pendingStartResult = null
                pendingStartOutputPath = null
                return
            }

            systemAudioService?.startSystemAudioCapture(projectionData, path) { success, errorMsg ->
                if (success) {
                    systemAudioStartTime = System.currentTimeMillis()
                    Log.d(TAG, "System audio capture started via service: $path")
                    result.success(true)
                } else {
                    Log.e(TAG, "Service startSystemAudioCapture failed: $errorMsg")
                    result.error("START_ERROR", errorMsg ?: "Failed to start capture", null)
                }
            }
            pendingStartResult = null
            pendingStartOutputPath = null
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            systemAudioService = null
            serviceBound = false
        }
    }

    companion object {
        private const val TAG = "SystemAudioMainActivity"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createNotificationChannel()

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, FLOATING_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    floatingEventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    floatingEventSink = null
                }
            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestSystemAudioPermission" -> {
                    pendingResult = result
                    requestScreenCapture()
                }
                "checkSystemAudioPermission" -> {
                    result.success(hasSystemAudioPermission)
                }
                "isMediaProjectionAvailable" -> {
                    result.success(mediaProjectionData != null)
                }
                "startSystemAudioCapture" -> {
                    val outputPath = call.argument<String>("outputPath")
                    if (outputPath != null) {
                        startSystemAudioCapture(outputPath, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "outputPath is required", null)
                    }
                }
                "stopSystemAudioCapture" -> {
                    val captureResult = stopSystemAudioCapture()
                    result.success(captureResult)
                }
                "getSystemAudioDuration" -> {
                    if (systemAudioService?.isCapturing() == true && systemAudioStartTime > 0) {
                        result.success((System.currentTimeMillis() - systemAudioStartTime).toInt())
                    } else {
                        result.success(0)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FLOATING_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestOverlayPermission" -> {
                    requestOverlayPermission(result)
                }
                "checkOverlayPermission" -> {
                    result.success(checkOverlayPermission())
                }
                "showFloatingWindow" -> {
                    val duration = call.argument<Int>("duration") ?: 0
                    val isRecording = call.argument<Boolean>("isRecording") ?: true
                    val isPaused = call.argument<Boolean>("isPaused") ?: false
                    showFloatingWindow(duration, isRecording, isPaused)
                    result.success(true)
                }
                "updateFloatingWindow" -> {
                    val duration = call.argument<Int>("duration")
                    val isRecording = call.argument<Boolean>("isRecording")
                    val isPaused = call.argument<Boolean>("isPaused")
                    updateFloatingWindow(duration, isRecording, isPaused)
                    result.success(true)
                }
                "hideFloatingWindow" -> {
                    hideFloatingWindow()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (Settings.canDrawOverlays(this)) {
                result.success(true)
            } else {
                pendingFloatingResult = result
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                startActivityForResult(intent, OVERLAY_REQUEST_CODE)
            }
        } else {
            result.success(true)
        }
    }

    private fun showFloatingWindow(duration: Int, isRecording: Boolean, isPaused: Boolean) {
        if (!checkOverlayPermission()) return

        runOnUiThread {
            if (floatingWindow != null) {
                updateFloatingWindow(duration, isRecording, isPaused)
                return@runOnUiThread
            }

            val view = layoutInflater.inflate(R.layout.floating_window, null)
            updateFloatingView(view, duration, isRecording, isPaused)

            val closeBtn = view.findViewById<ImageButton>(R.id.floating_close)
            closeBtn.setOnClickListener {
                floatingEventSink?.success("stop")
                hideFloatingWindow()
            }

            floatingParams = LayoutParams().apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    type = WindowManager.LayoutParams.TYPE_PHONE
                }
                format = android.graphics.PixelFormat.TRANSLUCENT
                flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                width = LayoutParams.WRAP_CONTENT
                height = LayoutParams.WRAP_CONTENT
                gravity = Gravity.TOP or Gravity.START
                x = 50
                y = 200
            }

            val windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
            windowManager.addView(view, floatingParams)
            floatingWindow = view
        }
    }

    private fun updateFloatingWindow(duration: Int?, isRecording: Boolean?, isPaused: Boolean?) {
        runOnUiThread {
            val view = floatingWindow ?: return@runOnUiThread
            updateFloatingView(view, duration ?: 0, isRecording ?: true, isPaused ?: false)
        }
    }

    private fun updateFloatingView(view: android.view.View, duration: Int, isRecording: Boolean, isPaused: Boolean) {
        val timeText = view.findViewById<TextView>(R.id.floating_time)
        val recordIcon = view.findViewById<ImageButton>(R.id.floating_record)

        val hours = duration / 3600
        val minutes = (duration % 3600) / 60
        val seconds = duration % 60
        timeText.text = String.format("%02d:%02d:%02d", hours, minutes, seconds)

        recordIcon.setImageResource(
            if (isRecording && !isPaused) android.R.drawable.presence_audio_online
            else android.R.drawable.presence_audio_busy
        )
    }

    private fun hideFloatingWindow() {
        runOnUiThread {
            floatingWindow?.let {
                val windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
                try {
                    windowManager.removeView(it)
                } catch (e: Exception) {}
                floatingWindow = null
            }
        }
    }

    private fun requestScreenCapture() {
        val projectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val intent = projectionManager.createScreenCaptureIntent()
        startActivityForResult(intent, MEDIA_PROJECTION_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == MEDIA_PROJECTION_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                mediaProjectionData = data
                hasSystemAudioPermission = true
                pendingResult?.success(true)
            } else {
                pendingResult?.success(false)
            }
            pendingResult = null
        }

        if (requestCode == OVERLAY_REQUEST_CODE) {
            val granted = checkOverlayPermission()
            pendingFloatingResult?.success(granted)
            pendingFloatingResult = null
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "system_audio_channel",
                "系统音频录制",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "系统音频录制"
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun startSystemAudioCapture(outputPath: String, result: MethodChannel.Result) {
        if (mediaProjectionData == null) {
            result.error("NO_PERMISSION", "MediaProjection permission not granted", null)
            return
        }

        if (systemAudioService?.isCapturing() == true) {
            result.error("ALREADY_RECORDING", "系统音频已在录制中", null)
            return
        }

        try {
            // Start the foreground service first for Android 14+ requirement
            val serviceIntent = Intent(this, SystemAudioService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }

            if (serviceBound && systemAudioService != null) {
                // Service already bound, call directly
                systemAudioService?.startSystemAudioCapture(mediaProjectionData!!, outputPath) { success, errorMsg ->
                    if (success) {
                        systemAudioStartTime = System.currentTimeMillis()
                        Log.d(TAG, "System audio capture started via service: $outputPath")
                        result.success(true)
                    } else {
                        Log.e(TAG, "Service startSystemAudioCapture failed: $errorMsg")
                        result.error("START_ERROR", errorMsg ?: "Failed to start capture", null)
                    }
                }
            } else {
                // Bind to service; capture starts in onServiceConnected
                if (pendingStartResult != null) {
                    result.error("BUSY", "正在启动系统音频，请稍候", null)
                    return
                }
                pendingStartResult = result
                pendingStartOutputPath = outputPath
                bindService(Intent(this, SystemAudioService::class.java), serviceConnection, Context.BIND_AUTO_CREATE)
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException: ${e.message}")
            result.error("SECURITY_ERROR", "Permission denied: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Error starting system audio capture: ${e.message}")
            result.error("START_ERROR", "Failed to start: ${e.message}", null)
        }
    }

    private fun stopSystemAudioCapture(): Map<String, Any?> {
        val duration = if (systemAudioStartTime > 0) {
            (System.currentTimeMillis() - systemAudioStartTime).toInt()
        } else {
            0
        }

        val path = systemAudioService?.stopSystemAudioCapture()

        // Unbind and stop service
        if (serviceBound) {
            unbindService(serviceConnection)
            serviceBound = false
            systemAudioService = null
        }
        stopService(Intent(this, SystemAudioService::class.java))

        val captureResult = mapOf(
            "path" to path,
            "duration" to duration
        )

        systemAudioStartTime = 0
        pendingStartResult = null
        pendingStartOutputPath = null

        Log.d(TAG, "System audio capture stopped, path: $path, duration: $duration")
        return captureResult
    }

    override fun onDestroy() {
        if (serviceBound) {
            unbindService(serviceConnection)
            serviceBound = false
        }
        super.onDestroy()
    }
}