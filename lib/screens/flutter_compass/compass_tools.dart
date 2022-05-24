import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:geo_ligtmeter/screens/location.dart';

class Compasstools {
  static const MethodChannel _channel = MethodChannel('checkDeviceSensors');

  static const EventChannel _eventChannel = EventChannel('azimuthStream');

  static Future<int> get checkSensors async {
    final int haveSensor = await _channel.invokeMethod('getSensors');
    return haveSensor;
  }

  static Stream<int>? azimuthStream() async* {
    Stream<int>? _azimuthValue = _eventChannel.receiveBroadcastStream().map<int>((value) => value);
    consoleLog(text: await _azimuthValue.toList());
    yield await _azimuthValue.last;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String sensorType;

  @override
  void initState() {
    super.initState();
    sensorType = "";
    checkDeviceSensors();
  }

  Future<void> checkDeviceSensors() async {
    late int haveSensor;

    try {
      haveSensor = await Compasstools.checkSensors;

      switch (haveSensor) {
        case 0:
          {
            // statements;
            sensorType = "No sensors for Compass";
          }
          break;

        case 1:
          {
            //statements;
            sensorType = "Accelerometer + Magnetoneter";
          }
          break;

        case 2:
          {
            //statements;
            sensorType = "Gyroscope";
          }
          break;

        default:
          {
            //statements;
            sensorType = "Error!";
          }
          break;
      }
    } on Exception {
      //
    }

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: StreamBuilder(
          stream: Compasstools.azimuthStream(),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                var data = snapshot.data;
                double value = data != null ? (-data / 360).toDouble() : 0.0;
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation(value),
                          // child: Image.asset("assets/compass.png"),
                          child: const Icon(Icons.compass_calibration),
                        ),
                      ),
                    ),
                    Text("SensorType: " + sensorType),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Text("Error in stream");
              } else {
                return const Text(
                  "Error",
                  style: TextStyle(color: Colors.red),
                );
              }
            } else {
              return const Center(child: Icon(Icons.error));
            }
          },
        ),
      ),
    );
  }
}
