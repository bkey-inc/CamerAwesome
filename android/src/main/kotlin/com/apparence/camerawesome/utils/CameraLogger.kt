package com.apparence.camerawesome.utils

import android.util.Log
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

object CameraLogger {
    private const val TAG = "CameraAwesome"
    private const val SEPARATOR = "========"
    
    fun log(message: String) {
        Log.d(TAG, "\n$SEPARATOR\n$message\n$SEPARATOR")
    }
    
    fun error(message: String, throwable: Throwable? = null) {
        Log.e(TAG, "\n$SEPARATOR\nERROR: $message\n$SEPARATOR", throwable)
    }
    
    fun debug(message: String, functionName: String = "") {
        val prefix = if (functionName.isNotEmpty()) "[$functionName] " else ""
        Log.d(TAG, "\n$SEPARATOR\n$prefix$message\n$SEPARATOR")
    }
}
