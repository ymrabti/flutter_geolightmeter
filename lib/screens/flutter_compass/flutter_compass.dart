import 'dart:async';

import 'package:flutter/services.dart';

class CompassEvent {
  final double? heading;

  final double? headingForCameraMode;

  final double? accuracy;

  CompassEvent.fromList(List<double>? data)
      : heading = data?[0],
        headingForCameraMode = data?[1],
        accuracy = (data == null) || (data[2] == -1) ? null : data[2];

  @override
  String toString() {
    return 'heading: $heading\nheadingForCameraMode: $headingForCameraMode\naccuracy: $accuracy';
  }
}

class FlutterCompass {
  static final FlutterCompass _instance = FlutterCompass._();

  factory FlutterCompass() {
    return _instance;
  }

  FlutterCompass._();

  static const EventChannel _compassChannel = EventChannel('hemanthraj/flutter_compass');
  static Stream<CompassEvent>? _stream;

  static Stream<CompassEvent>? get events {
    _stream ??= _compassChannel.receiveBroadcastStream().map(
          (dynamic data) => CompassEvent.fromList(
            data?.cast<double>(),
          ),
        );
    return _stream;
  }
}
