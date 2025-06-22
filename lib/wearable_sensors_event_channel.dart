import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wearable_sensors/wearable_sensors.dart';

import 'wearable_sensors_platform_interface.dart';

/// An implementation of [WearableSensorsPlatform] that uses event channels.
class EventChannelWearableSensors extends WearableSensorsPlatform {
  /// The event channel used to interact with the native platform.
  //@visibleForTesting
  final eventChannel = const EventChannel('wearable_sensors');

  @override
  Future<String?> getPlatformVersion() async {
    final version = "hello this is a version";
    return version;
  }

  @override
  Future<Stream<Map<String, double>>> getSensorStream(MySensorType mySensorType) async {
    //final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    var gyroscopeStream = eventChannel
            .receiveBroadcastStream(mySensorType.name)
            .map((dynamic event) => Map<String, double>.from(event));
    return gyroscopeStream;
  }

    Stream<Map<String, double>> createSensorStream(String channelName) {
    return EventChannel('wearable_sensors/$channelName')
        .receiveBroadcastStream()
        .map((dynamic event) => Map<String, double>.from(event));
  }
}
