import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wearable_sensors/wearable_sensors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final _wearableSensorsPlugin = WearableSensors();

  Stream<Map<String, double>> _gyroStream = Stream.empty();
  Stream<Map<String, double>> _acceStream = Stream.empty();
  Stream<Map<String, double>> _galvStream = Stream.empty();


  @override
  void initState() {
    super.initState();
    initPlatformState();
    initStreams();
  }


  void initStreams() async {
    final gyroStream = await _wearableSensorsPlugin.createSensorStream("gyroscope");
    final acceStream = await _wearableSensorsPlugin.createSensorStream("accelerometer");
    final galvStream = await _wearableSensorsPlugin.createSensorStream("galvanicSkinResponse");

    if (! mounted) return;

    setState(() {
      _gyroStream = gyroStream;
      _acceStream = acceStream;
      _galvStream = galvStream;
    });
  }

  String _platformVersion = 'Unknown';

  
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion =
          await _wearableSensorsPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ListView(
            children: [
              Center(child: Text('hi: $_platformVersion')),
              Center(child: SensorStreamBuilder(stream: _gyroStream, streamTitle: "gyroscope",)),
              Center(child: SensorStreamBuilder(stream: _acceStream, streamTitle: "accelerometer",)),
              Center(child: SensorStreamBuilder(stream: _galvStream, streamTitle: "galv skin response",)),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorStreamBuilder extends StatelessWidget {
  const SensorStreamBuilder({
    super.key,
    required Stream<Map<String, double>> stream,
    required String streamTitle
  }) : _myStream = stream, _streamTitle = streamTitle; 

  final Stream<Map<String, double>> _myStream;
  final String _streamTitle;


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, double>>(
      stream: _myStream,
      builder: (BuildContext context, AsyncSnapshot<Map<String, double>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the first value.
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Display an error message if the stream fails.
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          // When data is available, display it in a Text widget.
          var x = snapshot.data?["x"]?.toStringAsFixed(9);
          var y = snapshot.data?["y"]?.toStringAsFixed(9);
          var z = snapshot.data?["z"]?.toStringAsFixed(9);
          return Text(
            '$_streamTitle: \n  x: $x \n  y: $y \n  z: $z',
            //style: Theme.of(context).textTheme.headlineMedium,
          );
        } else {
          // Fallback for any other state.
          return const Text('Waiting for stream...');
        }
      },
    );
  }
}