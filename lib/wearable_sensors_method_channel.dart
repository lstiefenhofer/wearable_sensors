import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wearable_sensors_platform_interface.dart';

/// An implementation of [WearableSensorsPlatform] that uses method channels.
class MethodChannelWearableSensors extends WearableSensorsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wearable_sensors');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
