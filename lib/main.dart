import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/screens/lux_light.dart';
import 'package:geo_ligtmeter/models/models.dart';
import 'package:geo_ligtmeter/models/providers.dart';
import 'package:geo_ligtmeter/screens/location.dart';
import 'package:geo_ligtmeter/screens/maps.dart';
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

class ApplicationGeoLightmeter extends StatelessWidget {
  const ApplicationGeoLightmeter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FlSpot> flspots = Provider.of<LuxProvider>(context).fflSpot;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Geo Lightmeter'),
          actions: [
            Text('${flspots.length}'),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: const [
              LuxBanner(),
              LocationScreen(),
              PhysicalModel(
                elevation: 16,
                color: Colors.white70,
                child: MapsFlutter(),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: PhysicalModel(
                  elevation: 16,
                  color: Color.fromARGB(255, 231, 231, 231),
                  /* child: SensorsPlusPage(), */
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
