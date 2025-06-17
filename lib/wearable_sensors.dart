
import 'wearable_sensors_platform_interface.dart';

enum MySensorType {gyroscope, accelerometer}

class WearableSensors {
  Future<String?> getPlatformVersion() {
    return WearableSensorsPlatform.instance.getPlatformVersion();
  }

  Future<Stream<Map<String, double>>?> getSensorStream(MySensorType mySensorType) {
    return WearableSensorsPlatform.instance.getSensorStream(mySensorType);
  }
}
