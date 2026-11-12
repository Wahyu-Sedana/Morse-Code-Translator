package com.codebasedigital.morsecode

import android.content.Context
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.os.Handler
import android.os.Looper
import android.os.SystemClock

/**
 * Blinks the camera flashlight in a Morse pattern.
 *
 * Uses CameraManager.setTorchMode, which does not require the CAMERA
 * permission. The whole pattern is scheduled against an absolute clock so
 * blink timing does not drift, even at high WPM.
 */
class TorchController(context: Context) {
    private val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    private val cameraId: String? = findTorchCamera()
    private val handler = Handler(Looper.getMainLooper())
    private val token = Any()

    fun isAvailable(): Boolean = cameraId != null

    /** [pattern] alternates wait and on durations in ms, starting with a wait. */
    fun play(pattern: List<Long>) {
        stop()
        val id = cameraId ?: return
        var at = SystemClock.uptimeMillis()
        pattern.forEachIndexed { index, duration ->
            val on = index % 2 == 1
            handler.postAtTime({ setTorch(id, on) }, token, at)
            at += duration
        }
        handler.postAtTime({ setTorch(id, false) }, token, at)
    }

    fun stop() {
        handler.removeCallbacksAndMessages(token)
        cameraId?.let { setTorch(it, false) }
    }

    private fun setTorch(id: String, on: Boolean) {
        try {
            cameraManager.setTorchMode(id, on)
        } catch (_: CameraAccessException) {
            // Camera in use by another app; skip this blink.
        } catch (_: IllegalArgumentException) {
            // Camera disappeared; nothing to do.
        }
    }

    private fun findTorchCamera(): String? = try {
        val ids = cameraManager.cameraIdList
        fun hasFlash(id: String) =
            cameraManager.getCameraCharacteristics(id).get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
        fun facesBack(id: String) =
            cameraManager.getCameraCharacteristics(id).get(CameraCharacteristics.LENS_FACING) ==
                CameraCharacteristics.LENS_FACING_BACK
        ids.firstOrNull { hasFlash(it) && facesBack(it) } ?: ids.firstOrNull { hasFlash(it) }
    } catch (_: Exception) {
        null
    }
}
