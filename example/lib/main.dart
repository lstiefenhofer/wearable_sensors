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
  Stream<List<double>> _heartStream = Stream.empty();

  @override
  void initState() {
    super.initState();
    requestPermissionsAndInitStreams();
  }

  Future<void> requestPermissionsAndInitStreams() async {

    // Body sensors will not work until permissions have been requested
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sensors,
      Permission.activityRecognition,
    ].request();

    // Check if both permissions are granted.
    if (statuses[Permission.sensors] == PermissionStatus.granted &&
        statuses[Permission.activityRecognition] == PermissionStatus.granted) {
      // Permissions were granted
      initStreams();
    } else {
      // Permissions were denied 
      // Give out error message
    }
  }

  void initStreams() async {
    final gyroStream = await _wearableSensorsPlugin.createSensorStream("gyroscope");
    final acceStream = await _wearableSensorsPlugin.createSensorStream("accelerometer");
    final galvStream = await _wearableSensorsPlugin.createSensorStream("galvanicSkinResponse");
    final heartStream = await _wearableSensorsPlugin.createSensorStream("heartRate");

    if (!mounted) return;

    setState(() {
      _gyroStream = gyroStream;
      _acceStream = acceStream;
      _galvStream = galvStream;
      _heartStream = heartStream;
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
              Center(child: Text('hello')),
              Center(
                  child: SensorStreamBuilder(
                      stream: _gyroStream, streamTitle: "gyroscope")),
              Center(
                  child: SensorStreamBuilder(
                      stream: _acceStream, streamTitle: "accelerometer")),
              Center(
                  child: SensorStreamBuilder(
                      stream: _galvStream, streamTitle: "galv skin response")),
              Center(
                  child: SensorStreamBuilder(
                      stream: _heartStream, streamTitle: "heart rate")),
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
  final values = snapshot.data!;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Text('$_streamTitle:',),
      // Use the spread operator '...' to add each Text widget from the list
      ...values.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value.toStringAsFixed(5);
        return Padding( 
          padding: const EdgeInsets.only(left: 8.0),
          child: Text('[$index]: $value',),
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