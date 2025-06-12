
import 'wearable_sensors_platform_interface.dart';

class WearableSensors {
  Future<String?> getPlatformVersion() {
    return WearableSensorsPlatform.instance.getPlatformVersion();
  }

  Future<Stream<Map<String, double>>?> getGyroscope() {
    return WearableSensorsPlatform.instance.getGyroscope();
  }
}
