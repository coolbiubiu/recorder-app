package com.example.recoder_app

import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.content.pm.ServiceInfo
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.nio.ByteBuffer
import java.nio.ByteOrder

class SystemAudioService : Service() {
    companion object {
        private const val TAG = "SystemAudioService"
        private const val NOTIFICATION_ID = 1002
        private const val CHANNEL_ID = "system_audio_channel"
    }

    private val binder = LocalBinder()
    private var mediaProjection: MediaProjection? = null
    private var audioRecord: AudioRecord? = null
    private var isRecording = false
    private var outputFilePath: String? = null
    private var recordingThread: Thread? = null

    inner class LocalBinder : Binder() {
        fun getService(): SystemAudioService = this@SystemAudioService
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(NOTIFICATION_ID, createNotification(),
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION)
        } else {
            startForeground(NOTIFICATION_ID, createNotification())
        }
        return START_NOT_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        stopSystemAudioCapture()
        stopSelf()
        super.onTaskRemoved(rootIntent)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "系统音频录制",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "系统音频录制服务"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("音频录制中")
            .setContentText("正在录制系统声音")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .build()
    }

    fun startSystemAudioCapture(projectionData: Intent, outputPath: String, callback: (Boolean, String?) -> Unit) {
        // Clean up any stale state from a previous session
        if (isRecording) {
            stopSystemAudioCapture()
        }

        try {
            val projectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            mediaProjection = projectionManager.getMediaProjection(
                Activity.RESULT_OK, projectionData
            )

            if (mediaProjection == null) {
                callback(false, "无法获取媒体投影权限")
                return
            }

            outputFilePath = outputPath

            val config = AudioPlaybackCaptureConfiguration.Builder(mediaProjection!!)
                .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
                .addMatchingUsage(AudioAttributes.USAGE_GAME)
                .addMatchingUsage(AudioAttributes.USAGE_UNKNOWN)
                .build()

            val audioFormat = AudioFormat.Builder()
                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                .setSampleRate(44100)
                .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
                .build()

            val bufferSize = AudioRecord.getMinBufferSize(
                audioFormat.sampleRate,
                audioFormat.channelMask,
                audioFormat.encoding
            )

            if (bufferSize == AudioRecord.ERROR || bufferSize == AudioRecord.ERROR_BAD_VALUE) {
                outputFilePath = null
                callback(false, "音频缓冲区大小无效")
                return
            }

            audioRecord = AudioRecord.Builder()
                .setAudioFormat(audioFormat)
                .setAudioPlaybackCaptureConfig(config)
                .setBufferSizeInBytes(bufferSize)
                .build()

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                audioRecord?.release()
                audioRecord = null
                outputFilePath = null
                callback(false, "AudioRecord初始化失败")
                return
            }

            isRecording = true
            audioRecord?.startRecording()

            recordingThread = Thread {
                writeAudioDataToFile(bufferSize)
            }
            recordingThread?.start()

            callback(true, null)

        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException: ${e.message}")
            outputFilePath = null
            callback(false, "缺少系统音频录制权限（需要系统签名）")
        } catch (e: Exception) {
            Log.e(TAG, "Error starting system audio capture: ${e.message}")
            outputFilePath = null
            callback(false, "启动失败: ${e.message}")
        }
    }

    private fun writeAudioDataToFile(bufferSize: Int) {
        val buffer = ShortArray(bufferSize)
        var outputStream: FileOutputStream? = null

        try {
            val file = File(outputFilePath!!)
            outputStream = FileOutputStream(file)

            // Write WAV header placeholder
            val header = ByteArray(44)
            // RIFF header
            header[0] = 'R'.code.toByte()
            header[1] = 'I'.code.toByte()
            header[2] = 'F'.code.toByte()
            header[3] = 'F'.code.toByte()
            // File size (will be updated)
            header[4] = 0
            header[5] = 0
            header[6] = 0
            header[7] = 0
            // WAVE
            header[8] = 'W'.code.toByte()
            header[9] = 'A'.code.toByte()
            header[10] = 'V'.code.toByte()
            header[11] = 'E'.code.toByte()
            // fmt
            header[12] = 'f'.code.toByte()
            header[13] = 'm'.code.toByte()
            header[14] = 't'.code.toByte()
            header[15] = ' '.code.toByte()
            // Subchunk1Size (16 for PCM)
            header[16] = 16
            header[17] = 0
            header[18] = 0
            header[19] = 0
            // AudioFormat (1 for PCM)
            header[20] = 1
            header[21] = 0
            // NumChannels (1 for mono)
            header[22] = 1
            header[23] = 0
            // SampleRate
            header[24] = (44100 and 0xff).toByte()
            header[25] = ((44100 shr 8) and 0xff).toByte()
            header[26] = ((44100 shr 16) and 0xff).toByte()
            header[27] = ((44100 shr 24) and 0xff).toByte()
            // ByteRate (SampleRate * NumChannels * BitsPerSample/8)
            val byteRate = 44100 * 1 * 2
            header[28] = (byteRate and 0xff).toByte()
            header[29] = ((byteRate shr 8) and 0xff).toByte()
            header[30] = ((byteRate shr 16) and 0xff).toByte()
            header[31] = ((byteRate shr 24) and 0xff).toByte()
            // BlockAlign (NumChannels * BitsPerSample/8)
            header[32] = 2
            header[33] = 0
            // BitsPerSample
            header[34] = 16
            header[35] = 0
            // data
            header[36] = 'd'.code.toByte()
            header[37] = 'a'.code.toByte()
            header[38] = 't'.code.toByte()
            header[39] = 'a'.code.toByte()
            // Data size (will be updated)
            header[40] = 0
            header[41] = 0
            header[42] = 0
            header[43] = 0

            outputStream.write(header)

            while (isRecording) {
                val read = audioRecord?.read(buffer, 0, bufferSize) ?: 0
                if (read > 0) {
                    val byteBuffer = ByteBuffer.allocate(read * 2)
                    byteBuffer.order(ByteOrder.LITTLE_ENDIAN)
                    for (i in 0 until read) {
                        byteBuffer.putShort(buffer[i])
                    }
                    outputStream.write(byteBuffer.array())
                }
            }

            outputStream.close()

            // Update WAV header with correct file size
            val fileSize = file.length()
            val randomAccessFile = java.io.RandomAccessFile(file, "rw")
            randomAccessFile.seek(4)
            randomAccessFile.write((fileSize - 8).toInt() and 0xff)
            randomAccessFile.write(((fileSize - 8).toInt() shr 8) and 0xff)
            randomAccessFile.write(((fileSize - 8).toInt() shr 16) and 0xff)
            randomAccessFile.write(((fileSize - 8).toInt() shr 24) and 0xff)
            randomAccessFile.seek(40)
            randomAccessFile.write((fileSize - 44).toInt() and 0xff)
            randomAccessFile.write(((fileSize - 44).toInt() shr 8) and 0xff)
            randomAccessFile.write(((fileSize - 44).toInt() shr 16) and 0xff)
            randomAccessFile.write(((fileSize - 44).toInt() shr 24) and 0xff)
            randomAccessFile.close()

        } catch (e: IOException) {
            Log.e(TAG, "Error writing audio data: ${e.message}")
        } finally {
            outputStream?.close()
        }
    }

    fun stopSystemAudioCapture(): String? {
        isRecording = false
        recordingThread?.join(2000)

        audioRecord?.stop()
        audioRecord?.release()
        audioRecord = null

        mediaProjection?.stop()
        mediaProjection = null

        recordingThread = null

        return outputFilePath
    }

    fun isCapturing(): Boolean = isRecording

    override fun onDestroy() {
        stopSystemAudioCapture()
        super.onDestroy()
    }
}