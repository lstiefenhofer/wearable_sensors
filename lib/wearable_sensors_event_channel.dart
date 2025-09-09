import 'package:flutter/services.dart';

import 'wearable_sensors_platform_interface.dart';

/// An implementation of [WearableSensorsPlatform] that uses event channels.
class EventChannelWearableSensors extends WearableSensorsPlatform {
  /// The event channel used to interact with the native platform.
  //@visibleForTesting
  final eventChannel = const EventChannel('wearable_sensors');

  @override
  Stream<List<double>> createSensorStream(String channelName) {
    return EventChannel('wearable_sensors/$channelName')
        .receiveBroadcastStream()
        .map((dynamic event) => List<double>.from(event));
  }

  EventChannel getSensorEventChannel(String channelName) {
    return EventChannel('wearable_sensors/$channelName');
  }
}
