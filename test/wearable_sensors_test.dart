import 'package:flutter_test/flutter_test.dart';
import 'package:wearable_sensors/wearable_sensors.dart';
import 'package:wearable_sensors/wearable_sensors_platform_interface.dart';
import 'package:wearable_sensors/wearable_sensors_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWearableSensorsPlatform
    with MockPlatformInterfaceMixin
    implements WearableSensorsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WearableSensorsPlatform initialPlatform = WearableSensorsPlatform.instance;

  test('$MethodChannelWearableSensors is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWearableSensors>());
  });

  test('getPlatformVersion', () async {
    WearableSensors wearableSensorsPlugin = WearableSensors();
    MockWearableSensorsPlatform fakePlatform = MockWearableSensorsPlatform();
    WearableSensorsPlatform.instance = fakePlatform;

    expect(await wearableSensorsPlugin.getPlatformVersion(), '42');
  });
}
