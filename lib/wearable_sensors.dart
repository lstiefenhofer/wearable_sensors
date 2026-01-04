import 'wearable_sensors_platform_interface.dart';

class WearableSensors {
  Stream<List<double>> createSensorStream(String channelName) {
    return WearableSensorsPlatform.instance.createSensorStream(channelName);
  }
}
