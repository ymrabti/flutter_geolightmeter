import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geo_ligtmeter/location.dart';
import 'package:geo_ligtmeter/models.dart';
import 'package:geo_ligtmeter/provider.dart';
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
    LocalizationData locationData = Provider.of<LocationProvider>(context).localizationData;
    double lat = locationData.latitude;
    double lng = locationData.longitude;
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
  }

  /* Stream<LocalizationData> _location(LocalizationData locationData) async* {
    setState(() {
      currentPosition = LatLng(locationData.latitude, locationData.longitude);
      /* if (currentPosition.latitude > 0.01) { } */
      _mapControlleur.moveAndRotate(currentPosition, 15, locationData.heading);
    });
    yield locationData;
  } */

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

class MarkerAnchorPage extends StatefulWidget {
  static const String route = '/marker_anchors';

  const MarkerAnchorPage({Key? key}) : super(key: key);
  @override
  MarkerAnchorPageState createState() {
    return MarkerAnchorPageState();
  }
}

class MarkerAnchorPageState extends State<MarkerAnchorPage> {
  late AnchorPos anchorPos;

  @override
  void initState() {
    super.initState();
    anchorPos = AnchorPos.align(AnchorAlign.center);
  }

  void _setAnchorAlignPos(AnchorAlign alignOpt) {
    setState(() {
      anchorPos = AnchorPos.align(alignOpt);
    });
  }

  void _setAnchorExactlyPos(Anchor anchor) {
    setState(() {
      anchorPos = AnchorPos.exactly(anchor);
    });
  }

  @override
  Widget build(BuildContext context) {
    var markers = <Marker>[
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(51.5, -0.09),
        builder: (ctx) => const FlutterLogo(),
        anchorPos: anchorPos,
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(53.3498, -6.2603),
        builder: (ctx) => const FlutterLogo(
          textColor: Colors.green,
        ),
        anchorPos: anchorPos,
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(48.8566, 2.3522),
        builder: (ctx) => const FlutterLogo(textColor: Colors.purple),
        anchorPos: anchorPos,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Marker Anchor Points')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text('Markers can be anchored to the top, bottom, left or right.'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Wrap(
                children: <Widget>[
                  MaterialButton(
                    onPressed: () => _setAnchorAlignPos(AnchorAlign.left),
                    child: const Text('Left'),
                  ),
                  MaterialButton(
                    onPressed: () => _setAnchorAlignPos(AnchorAlign.right),
                    child: const Text('Right'),
                  ),
                  MaterialButton(
                    onPressed: () => _setAnchorAlignPos(AnchorAlign.top),
                    child: const Text('Top'),
                  ),
                  MaterialButton(
                    onPressed: () => _setAnchorAlignPos(AnchorAlign.bottom),
                    child: const Text('Bottom'),
                  ),
                  MaterialButton(
                    onPressed: () => _setAnchorAlignPos(AnchorAlign.center),
                    child: const Text('Center'),
                  ),
                  MaterialButton(
                    onPressed: () => _setAnchorExactlyPos(Anchor(80.0, 80.0)),
                    child: const Text('Custom'),
                  ),
                ],
              ),
            ),
            Flexible(
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(51.5, -0.09),
                  zoom: 5.0,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(markers: markers)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
