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
}
