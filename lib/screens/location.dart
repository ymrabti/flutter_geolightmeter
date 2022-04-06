import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/models/models.dart';
import 'package:geo_ligtmeter/models/providers.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final Location location = Location();
  @override
  Widget build(BuildContext context) {
    location.onLocationChanged.listen(
      (LocationData currentLocation) {
        Provider.of<LocationProvider>(
          context,
          listen: false,
        ).changedLocation(
          chngeLoc: LocalizationData(
              latitude: currentLocation.latitude ?? 0,
              longitude: currentLocation.longitude ?? 0,
              altitude: currentLocation.altitude ?? 0,
              accuracy: currentLocation.accuracy ?? 0,
              heading: currentLocation.heading ?? 0,
              speed: currentLocation.speed ?? 0),
        );
      },
    );
    // location.enableBackgroundMode(enable: true);
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: PhysicalModel(
        color: Colors.green,
        elevation: 5,
        child: LocationBanner(),
      ),
    );
  }

  localisation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
}

void consoleLog({required text, int color = 37}) {
  if (kDebugMode) {
    print('\x1B[${color}m $text\x1B[0m');
  }
}

class LocationBanner extends StatefulWidget {
  const LocationBanner({Key? key}) : super(key: key);

  @override
  State<LocationBanner> createState() => _LocationBannerState();
}

class _LocationBannerState extends State<LocationBanner> {
  @override
  Widget build(BuildContext context) {
    LocalizationData locationData = Provider.of<LocationProvider>(context).localizationData;
    return Theme(
      data: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF1C055A),
          onPrimary: Color.fromARGB(255, 32, 3, 114),
          secondary: Color(0xFF3206AC),
          onSecondary: Color(0xFF5422DF),
          error: Color(0xFFA30D02),
          onError: Colors.redAccent,
          background: Colors.white,
          onBackground: Color(0xFFBEC4A8),
          surface: Colors.white,
          onSurface: Color(0xFFBBBBBB),
        ),
      ),
      child: Builder(builder: (context) {
        var screenSize = MediaQuery.of(context).size;
        var textHead = TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: screenSize.width * 0.05,
          color: Color(0xFFFFFFFF),
          wordSpacing: 1.5,
          height: 1.2,
          shadows: const [
            Shadow(
              color: Color(0xFFFFFFFF),
              blurRadius: 6,
            ),
          ],
        );
        var textValue = TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontSize: screenSize.width * 0.04,
          wordSpacing: 1.5,
          height: 1.2,
          shadows: const [
            Shadow(
              color: Color(0xFFFFFFFF),
              blurRadius: 1,
            ),
          ],
        );
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Latitude', style: textHead),
                      ),
                      Text(locationData.latitude.toStringAsFixed(6), style: textValue)
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Longitude', style: textHead),
                      ),
                      Text(locationData.longitude.toStringAsFixed(6), style: textValue)
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Accuracy', style: textHead),
                      ),
                      Text(locationData.accuracy.toStringAsFixed(6), style: textValue)
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Altitude', style: textHead),
                      ),
                      Text(locationData.altitude.toStringAsFixed(6), style: textValue)
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Heading', style: textHead),
                      ),
                      Text(locationData.heading.toStringAsFixed(6), style: textValue)
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Speed', style: textHead),
                      ),
                      Text(locationData.speed.toStringAsFixed(6), style: textValue)
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
