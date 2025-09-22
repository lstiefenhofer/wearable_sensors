package de.unituebingen.wearable_sensors

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel

// generic stream handler will be used to create stream handler for specific sensor type 
abstract class BaseSensorStreamHandler(
    private val sensorManager: SensorManager,
    private val sensorType: Int
) : EventChannel.StreamHandler, SensorEventListener {

    private var eventSink: EventChannel.EventSink? = null
    private val sensor: Sensor? = sensorManager.getDefaultSensor(sensorType)

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
        if (sensor == null) {
            sink?.error("UNAVAILABLE", "Sensor not available on this device", null)
            return
        }
        this.eventSink = sink
        //sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_NORMAL)
        sensorManager.registerListener(this, sensor, 20000)
    }

    override fun onCancel(arguments: Any?) { 
        sensorManager.unregisterListener(this)
        this.eventSink = null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == sensorType) {
            val sensorValues = event.values.map { it.toDouble() }.toDoubleArray()
            eventSink?.success(sensorValues)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
