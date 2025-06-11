
import 'wearable_sensors_platform_interface.dart';

class WearableSensors {
  Future<String?> getPlatformVersion() {
    return WearableSensorsPlatform.instance.getPlatformVersion();
  }
}
