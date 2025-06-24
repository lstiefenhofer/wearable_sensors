import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Stream<List<double>> _gyroStream = Stream.empty();
  Stream<List<double>> _acceStream = Stream.empty();
  Stream<List<double>> _galvStream = Stream.empty();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    requestPermissionsAndInitStreams();
  }
  // <<< CHANGED: This method now uses permission_handler
  Future<void> requestPermissionsAndInitStreams() async {
    // Request the specific permissions.
    // Permission.sensors maps to BODY_SENSORS.
    // Permission.activityRecognition is for motion sensors like accelerometer.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sensors,
      Permission.activityRecognition,
    ].request();

    // Check if both permissions are granted.
    if (statuses[Permission.sensors] == PermissionStatus.granted &&
        statuses[Permission.activityRecognition] == PermissionStatus.granted) {
      // If permissions were granted, initialize the sensor streams.
      print("All necessary permissions granted. Initializing streams...");
      initStreams();
    } else {
      // If permissions were denied, handle it here.
      print("Permissions not granted. Streams will not be initialized.");
      // You could show a dialog to the user explaining why the permissions are needed.
    }
  }

  void initStreams() async {
    final gyroStream = await _wearableSensorsPlugin.createSensorStream("gyroscope");
    final acceStream = await _wearableSensorsPlugin.createSensorStream("accelerometer");
    final galvStream = await _wearableSensorsPlugin.createSensorStream("galvanicSkinResponse");

    if (!mounted) return;

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
              Center(
                  child: SensorStreamBuilder(
                      stream: _gyroStream, streamTitle: "gyroscope")),
              Center(
                  child: SensorStreamBuilder(
                      stream: _acceStream, streamTitle: "accelerometer")),
              Center(
                  child: SensorStreamBuilder(
                      stream: _galvStream, streamTitle: "galv skin response")),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorStreamBuilder extends StatelessWidget {
  const SensorStreamBuilder(
      {super.key,
      required Stream<List<double>> stream,
      required String streamTitle})
      : _myStream = stream,
        _streamTitle = streamTitle;

  final Stream<List<double>> _myStream;
  final String _streamTitle;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<double>>(
      stream: _myStream,
      builder: (BuildContext context,
          AsyncSnapshot<List<double>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the first value.
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Display an error message if the stream fails.
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
  // snapshot.data is now a List<double>
  final values = snapshot.data!;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left
    children: [
      Text(
        '$_streamTitle:',
        // style: Theme.of(context).textTheme.headlineSmall, // Style for the title
      ),
      // Use the spread operator '...' to add each Text widget from the list
      ...values.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value.toStringAsFixed(5);
        return Padding( // Add some padding for better layout
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            '[$index]: $value',
            // style: Theme.of(context).textTheme.bodyMedium, // Style for each value
          ),
        );
      }),
    ],
  );

        } else {
          // Fallback for any other state.
          return const Text('Waiting for stream...');
        }
      },
    );
  }
}