import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geo_ligtmeter/screens/location.dart';
import 'package:geo_ligtmeter/models/models.dart';
import 'package:geo_ligtmeter/models/providers.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapsFlutter extends StatefulWidget {
  const MapsFlutter({Key? key}) : super(key: key);

  @override
  State<MapsFlutter> createState() => _MapsFlutterState();
}

class _MapsFlutterState extends State<MapsFlutter> {
  LatLng currentPosition = LatLng(0, 0);
  late MapController _mapControlleur;

  @override
  void initState() {
    _mapControlleur = MapController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LocalizationData locationData = Provider.of<LocationProvider>(
      context,
    ).localizationData;
    return StreamBuilder<LocalizationData>(
      stream: _location(locationData),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          double lat = 34.927891, lng = -2.329926;
          lat = snapshot.data!.latitude;
          lng = snapshot.data!.longitude;

          return SizedBox(
            height: 300,
            child: FlutterMap(
              key: const Key("MapFlutterKey"),
              mapController: _mapControlleur,
              options: MapOptions(
                onPositionChanged: (position, hasGesture) {
                  //   consoleLog(text: position.center);
                },
                onTap: (tapPosition, point) {
                  consoleLog(text: _mapControlleur.center, color: 33);
                  consoleLog(text: tapPosition.toString(), color: 34);
                  consoleLog(text: currentPosition);
                  _mapControlleur.move(LatLng(lat, lng), 15);
                },
                center: currentPosition,
                zoom: 14.0,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      // rotateOrigin: Offset(1220, 1220),
                      rotateAlignment: const Alignment(90, 150), //anchorPos: AnchorPos<LatLng>(),
                      point: LatLng(lat, lng),
                      builder: (ctx) {
                        return const Icon(
                          Icons.location_searching_sharp,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return const CupertinoActivityIndicator(
            radius: 100,
          );
        }
      },
    );
  }

  Stream<LocalizationData> _location(LocalizationData locationData) async* {
    setState(() {
      currentPosition = LatLng(locationData.latitude, locationData.longitude);
      if (currentPosition.latitude > 0.01) {
        _mapControlleur.moveAndRotate(currentPosition, 15, locationData.heading);
      }
      //   _mapControlleur.move(LatLng(locationData.latitude, locationData.longitude), 12);
    });
    yield locationData;
  }

  /* @override
  void dispose() {
    _MapsFlutterState().dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _MapsFlutterState().didChangeDependencies();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant MapsFlutter oldWidget) {
    _MapsFlutterState().didUpdateWidget(oldWidget);
    super.didUpdateWidget(oldWidget);
  } */
}
