import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wearable_sensors/wearable_sensors.dart';

import 'wearable_sensors_method_channel.dart';
import 'wearable_sensors_event_channel.dart';

abstract class WearableSensorsPlatform extends PlatformInterface {
  /// Constructs a WearableSensorsPlatform.
  WearableSensorsPlatform() : super(token: _token);

  static final Object _token = Object();

  //static WearableSensorsPlatform _instance = MethodChannelWearableSensors();
  static WearableSensorsPlatform _instance = EventChannelWearableSensors();


  /// The default instance of [WearableSensorsPlatform] to use.
  ///
  /// Defaults to [MethodChannelWearableSensors].
  static WearableSensorsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WearableSensorsPlatform] when
  /// they register themselves.
  static set instance(WearableSensorsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Stream<Map<String, double>>> getSensorStream(MySensorType mySensorType){
    throw UnimplementedError('getSensorStream(MySensorType mySensorType) has not been implemented');
  }
  
}
