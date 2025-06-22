
package de.unituebingen.wearable_sensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

/** WearableSensorsPlugin */
class WearableSensorsPlugin: FlutterPlugin, EventChannel.StreamHandler, SensorEventListener {

    // Define the channel name, must match the one in Dart
    private val EVENT_CHANNEL_NAME = "wearable_sensors"

    private lateinit var gyroscopeChannel: EventChannel

    // Android Sensor-related variables
    private lateinit var sensorManager: SensorManager
    private var gyroscope: Sensor? = null

    // The EventSink is the key to sending events to Flutter
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        // Get the application context
        val context = flutterPluginBinding.applicationContext
        
        // Setup sensor manager
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        gyroscope = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE)

        // Setup the EventChannel
        gyroscopeChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME)
        gyroscopeChannel.setStreamHandler(this)
    }

    // EventChannel.StreamHandler methods
    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        // When Flutter starts listening, start the sensor
        eventSink = sink
        gyroscope?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
    }

    override fun onCancel(arguments: Any?) {
        // When Flutter stops listening, stop the sensor
        sensorManager.unregisterListener(this)
        eventSink = null
    }

    // SensorEventListener methods
    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_GYROSCOPE) {
            // Create a map to send to Flutter
            val sensorValues = mapOf(
                "x" to event.values[0].toDouble(),
                "y" to event.values[1].toDouble(),
                "z" to event.values[2].toDouble()
            )
            // Send the data to Flutter
            eventSink?.success(sensorValues)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Not used in this example
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Clean up the channel when the plugin is detached
        gyroscopeChannel.setStreamHandler(null)
    }
}