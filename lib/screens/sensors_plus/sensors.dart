import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'snake.dart';

class SensorsPlusPage extends StatefulWidget {
  const SensorsPlusPage({Key? key}) : super(key: key);

  @override
  _SensorsPlusPageState createState() => _SensorsPlusPageState();
}

class _SensorsPlusPageState extends State<SensorsPlusPage> {
  static const int _snakeRows = 20;
  static const int _snakeColumns = 20;
  static const double _snakeCellSize = 10.0;

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final accelerometer = _accelerometerValues?.map((double v) => v.toStringAsFixed(3)).toList();
    final gyroscope = _gyroscopeValues?.map((double v) => v.toStringAsFixed(3)).toList();
    final userAccelerometer =
        _userAccelerometerValues?.map((double v) => v.toStringAsFixed(3)).toList();
    final magnetometer = _magnetometerValues?.map((double v) => v.toStringAsFixed(3)).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: PhysicalModel(
        elevation: 16,
        color: const Color.fromARGB(255, 231, 231, 231),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: Colors.black38),
                ),
                child: const SizedBox(
                  height: _snakeRows * _snakeCellSize,
                  width: _snakeColumns * _snakeCellSize,
                  child: Snake(
                    rows: _snakeRows,
                    columns: _snakeColumns,
                    cellSize: _snakeCellSize,
                  ),
                ),
              ),
            ),
            StreamBuilder(
              stream: gyroscopeEvents.asBroadcastStream(),
              builder: ((BuildContext buildContext, snapshot) {
                // consoleLog(text: snapshot.data);
                if (snapshot.hasData) {
                  return Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: RotationTransition(
                            turns: AlwaysStoppedAnimation(50),
                            // child: Image.asset("assets/compass.png"),
                            child: Icon(Icons.compass_calibration),
                          ),
                        ),
                      ),
                      Text("SensorType: ${snapshot.data}"),
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
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Accelerometer: $accelerometer'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('UserAccelerometer: $userAccelerometer'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Gyroscope: $gyroscope'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Magnetometer: $magnetometer'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );

    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          setState(() {
            _magnetometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }
}
