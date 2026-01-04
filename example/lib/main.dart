import 'package:flutter/material.dart';
import 'dart:async';

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
  Stream<List<double>> _magnetStream = Stream.empty();

  @override
  void initState() {
    super.initState();
    initStreams();
  }


  void initStreams() async {
    final gyroStream =  _wearableSensorsPlugin.createSensorStream("gyroscope");
    final acceStream =  _wearableSensorsPlugin.createSensorStream("accelerometer");
    final galvStream =  _wearableSensorsPlugin.createSensorStream("galvanicSkinResponse");
    final heartStream =  _wearableSensorsPlugin.createSensorStream("heartRate");
    final magnetStream =  _wearableSensorsPlugin.createSensorStream("magnetometer");


    if (!mounted) return;

    setState(() {
      _gyroStream = gyroStream;
      _acceStream = acceStream;
      _galvStream = galvStream;
      _heartStream = heartStream;
      _magnetStream = magnetStream;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ListView(
            children: [
              SizedBox(height: 30,),
              Center(child: Text('SENSORS:')),
              SensorStreamBuilder(
                  stream: _gyroStream, streamTitle: "gyroscope"),
              SensorStreamBuilder(
                  stream: _acceStream, streamTitle: "accelerometer"),
              SensorStreamBuilder(
                  stream: _galvStream, streamTitle: "galv skin response"),
              SensorStreamBuilder(
                  stream: _heartStream, streamTitle: "heart rate"),
              SensorStreamBuilder(
                  stream: _magnetStream, streamTitle: "magnetometer"),      
              SizedBox(height: 30,),           
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
    return Center(
      child: StreamBuilder<List<double>>(
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
      ),
    );
  }
}