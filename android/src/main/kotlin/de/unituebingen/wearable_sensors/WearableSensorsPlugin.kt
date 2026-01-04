package de.unituebingen.wearable_sensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class WearableSensorsPlugin : FlutterPlugin {

    // handles basic setup
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val context = flutterPluginBinding.applicationContext
        val messenger = flutterPluginBinding.binaryMessenger
        val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        // helper function to register all channels for all the sensors
        // each channel has a dedicated handler class derived from a base handler
        fun registerSensorChannel(channelName: String, handler: EventChannel.StreamHandler) {
            EventChannel(messenger, "wearable_sensors/$channelName").setStreamHandler(handler)
        }

        // we create a seperate event channel for each sensor
        // name must match the name passed in plugin.createSensorStream()
        registerSensorChannel("accelerometer", AccelerometerStreamHandler(sensorManager))
        registerSensorChannel("gyroscope", GyroscopeStreamHandler(sensorManager))
        registerSensorChannel(
                "galvanicSkinResponse",
                GalvanicSkinResponseStreamHandler(sensorManager)
        )
        registerSensorChannel("heartRate", HeartRateStreamHandler(sensorManager))
        registerSensorChannel("magnetometer", MagnetometerStreamHandler(sensorManager))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}

// concrete classes to handle each sensor stream
// only difference is the sensor type passed to each of them
class AccelerometerStreamHandler(sm: SensorManager) :
        BaseSensorStreamHandler(sm, Sensor.TYPE_ACCELEROMETER)

class GyroscopeStreamHandler(sm: SensorManager) : BaseSensorStreamHandler(sm, 4)

class GalvanicSkinResponseStreamHandler(sm: SensorManager) : BaseSensorStreamHandler(sm, 65554)

class HeartRateStreamHandler(sm: SensorManager) :
        BaseSensorStreamHandler(sm, Sensor.TYPE_HEART_RATE)

class MagnetometerStreamHandler(sm: SensorManager) :
        BaseSensorStreamHandler(sm, Sensor.TYPE_MAGNETIC_FIELD)
