import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/lux_light.dart';
import 'package:geo_ligtmeter/models.dart';
import 'package:geo_ligtmeter/provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationProvider(
            localizationData: LocalizationData(
              latitude: 0.0,
              longitude: 0.0,
              altitude: 0.0,
              accuracy: 0.0,
              heading: 0.0,
              speed: 0.0,
            ),
          ),
        )
      ],
      child: const MaterialApp(
        home: LuxBanner(),
      ),
    );
  }
}
