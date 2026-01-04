package de.unituebingen.wearable_sensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class WearableSensorsPlugin : FlutterPlugin {

        lateinit var sensorManager: SensorManager

        // handles basic setup
        override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
                val context = flutterPluginBinding.applicationContext
                val messenger = flutterPluginBinding.binaryMessenger

                sensorManager = context.getSystemService(Context.SENSOR_SERVICE)

                // helper function to register all channels for all the sensors
                // each channel has a dedicated handler class derived from a base handler
                fun registerSensorChannel(
                        channelName: String,
                        handler: EventChannel.StreamHandler
                ) {
                        EventChannel(messenger, "wearable_sensors/$channelName")
                                .setStreamHandler(handler)
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

        // enlists all available sensors on device
        // included information about id, name, type, vendor, version
        private fun logAvailableSensors(): List<Map<String, String>> {
                val deviceSensors: List<Sensor> = sensorManager.getSensorList(Sensor.TYPE_ALL)

                // log sensor information
                Log.i("SensorList", "Available sensors:")
                deviceSensors.forEach { sensor ->
                        Log.i(
                                "SensorList",
                                "Name: ${sensor.name}, ID: ${sensor.id}, Type: ${sensor.type}, Vendor: ${sensor.vendor}, Version: ${sensor.version}"
                        )
                }

                // return sensor information
                return deviceSensors.map { sensor ->
                        mapOf(
                                "name" to sensor.name.toString(),
                                "id" to sensor.id.toString(),
                                "type" to sensor.type.toString(),
                                "vendor" to sensor.vendor.toString(),
                                "version" to sensor.version.toString()
                        )
                }
        }

        override fun onMethodCall(call: MethodCall, result: Result) {
                if (call.method == "getAllSensors") {
                        result.success(logAvailableSensors())
                } else {
                        result.notImplemented()
                }
        }

        override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}

}

// concrete classes to handle each sensor stream
// only difference is the sensor type passed to each of them
class AccelerometerStreamHandler(sm: SensorManager) : BaseSensorStreamHandler(sm, Sensor.TYPE_ACCELEROMETER)

//int 4 corresponds to Sensor.TYPE_GYROSCOPE
//we can use them interchangably, which is why calling the eda sensor by its number works
//class GyroscopeStreamHandler(sm: SensorManager) : BaseSensorStreamHandler(sm, Sensor.TYPE_GYROSCOPE)
class GyroscopeStreamHandler(sm: SensorManager) : BaseSensorStreamHandler(sm, 4)

// int 65554 is the id of the gsr sensor on the target device Google Pixel Watch 3
class GalvanicSkinResponseStreamHandler(sm: SensorManager) : BaseSensorStreamHandler(sm, 65554)

class MagnetometerStreamHandler(sm: SensorManager) : BaseSensorStreamHandler(sm, Sensor.TYPE_MAGNETIC_FIELD)

class HeartRateStreamHandler(sm: SensorManager) :
        BaseSensorStreamHandler(sm, Sensor.TYPE_HEART_RATE)

