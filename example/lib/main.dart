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
  String _platformVersion = 'Unknown';
  final _wearableSensorsPlugin = WearableSensors();

  // 1. Add a stream that emits an integer every second, starting with 1.
  final Stream<int> numberGenerator =
      Stream.periodic(const Duration(seconds: 1), (computationCount) => computationCount + 1);

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _wearableSensorsPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            children: [
              Text('Hello: $_platformVersion\n'),
              // 2. Use a StreamBuilder to listen to the stream and display the number.
              StreamBuilder<int>(
                stream: numberGenerator,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while waiting for the first value.
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // Display an error message if the stream fails.
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    // When data is available, display it in a Text widget.
                    return Text(
                      'Counting: ${snapshot.data}',
                      //style: Theme.of(context).textTheme.headlineMedium,
                    );
                  } else {
                    // Fallback for any other state.
                    return const Text('Waiting for numbers...');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}