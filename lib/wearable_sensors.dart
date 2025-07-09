
import 'package:flutter/services.dart';

import 'wearable_sensors_platform_interface.dart';

enum MySensorType {gyroscope, accelerometer}

class WearableSensors {

  Stream<List<double>> createSensorStream(String channelName) {
    return WearableSensorsPlatform.instance.createSensorStream(channelName);
  }

  EventChannel getSensorEventChannel(String channelName) {
    return WearableSensorsPlatform.instance.getSensorEventChannel(channelName);
  }

}
