import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/models/models.dart';
import 'package:geo_ligtmeter/models/providers.dart';
import 'package:geo_ligtmeter/screens/app.dart';
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
            localizationsData: [],
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LuxProvider(fflSpot: []),
        ),
      ],
      child: const MaterialApp(
        home: ApplicationGeoLightmeter(),
      ),
    );
  }
}

// git add . && git commit -m "message" && git push -u origin main