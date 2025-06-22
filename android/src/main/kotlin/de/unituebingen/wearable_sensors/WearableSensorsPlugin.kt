// android/src/main/kotlin/de/unituebingen/wearable_sensors/WearableSensorsPlugin.kt

package de.unituebingen.wearable_sensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class WearableSensorsPlugin : FlutterPlugin {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val context = flutterPluginBinding.applicationContext
        val messenger = flutterPluginBinding.binaryMessenger
        val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        // --- Register all Event Channels ---

        // Helper function to reduce registration boilerplate
        fun registerSensorChannel(channelName: String, handler: EventChannel.StreamHandler) {
            EventChannel(messenger, "wearable_sensors/$channelName").setStreamHandler(handler)
        }

        registerSensorChannel("accelerometer", AccelerometerStreamHandler(sensorManager))
        registerSensorChannel("gyroscope", GyroscopeStreamHandler(sensorManager))
        registerSensorChannel("magnetometer", MagnetometerStreamHandler(sensorManager))
        // ... repeat for all 20 sensors ...
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // It's good practice to null out handlers on detach, though the OS cleans up.
        // For this pattern, there isn't a single channel to nullify.
    }
}

// --- Base and Concrete Stream Handlers ---
// (Can be in the same file or separated for organization)

// THE GENERIC BASE CLASS
abstract class BaseSensorStreamHandler(
    private val sensorManager: SensorManager,
    private val sensorType: Int
) : EventChannel.StreamHandler, SensorEventListener {
    // ... (This is the full BaseSensorStreamHandler code from the previous answer)
    // It contains the onListen, onCancel, onSensorChanged, and onAccuracyChanged methods.
    private var eventSink: EventChannel.EventSink? = null
    private val sensor: Sensor? = sensorManager.getDefaultSensor(sensorType)

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        if (sensor == null) {
            sink?.error("UNAVAILABLE", "Sensor not available on this device", null)
            return
        }
        this.eventSink = sink
        sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        this.eventSink = null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == sensorType) {
            // Note: This needs to be adapted for sensors that don't return 3 values.
            val sensorValues = mapOf(
                "x" to event.values.getOrElse(0) { 0.0f }.toDouble(),
                "y" to event.values.getOrElse(1) { 0.0f }.toDouble(),
                "z" to event.values.getOrElse(2) { 0.0f }.toDouble()
            )
            eventSink?.success(sensorValues)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}

// THE TINY CONCRETE CLASSES
class AccelerometerStreamHandler(sm: SensorManager) : BaseSensorStreamHandler(sm, Sensor.TYPE_ACCELEROMETER)
class GyroscopeStreamHandler(sm: SensorManager) : BaseSensorStreamHandler(sm, Sensor.TYPE_GYROSCOPE)
class MagnetometerStreamHandler(sm: SensorManager) : BaseSensorStreamHandler(sm, Sensor.TYPE_MAGNETIC_FIELD)
// ... and so on for all 20 sensors ...