import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
  Future<Stream<Map<String, double>>> getGyroscope() async {
    //final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    var gyroscopeStream = eventChannel
            .receiveBroadcastStream()
            .map((dynamic event) => Map<String, double>.from(event));

  //   Stream<Map<String, double>> get accelerometerEvents {
  //   _accelerometerStream ??= _accelerometerChannel
  //       .receiveBroadcastStream()
  //       .map((dynamic event) => Map<String, double>.from(event));
  //   return _accelerometerStream!;
  // }

    return gyroscopeStream;
  }
}
