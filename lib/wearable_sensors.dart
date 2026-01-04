import 'wearable_sensors_platform_interface.dart';

class WearableSensors {
  Stream<List<double>> createSensorStream(String channelName) {
    return WearableSensorsPlatform.instance.createSensorStream(channelName);
  }

  Future<List<Map<String, String>>> getAllSensors() {
    return WearableSensorsPlatform.instance.getAllSensors();
  }
}
