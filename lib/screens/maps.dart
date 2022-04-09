import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
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
//   late List<LatLng> points;

  late List<Polyline> polyLines;
  late List<Polygon> polygons;
  late MapController _mapControlleur;

  @override
  void initState() {
    super.initState();
    _mapControlleur = MapController();

    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      /* setState(() {
        points.add(
          LatLng(
            34.928605854017 + random,
            -2.3147196356671724 + random,
          ),
        );
      }); */
    });
    polygons = [
      Polygon(
        points: List.generate(
          1,
          (index) => LatLng(
            34.928605854017 + random,
            -2.3147196356671724 + random,
          ),
        ),
        borderStrokeWidth: 2.0,
        color: const Color(0xFF7A69AE).withAlpha(64),
      ),
    ];
    polyLines = [
      Polyline(
        points: [],
        strokeWidth: 4.0,
        color: Colors.red,
      ),
    ];
  }

  double get random => (Random().nextDouble() * 2.0 - 1) * 0.05;

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
              children: const [
                Icon(Icons.location_searching),
              ],
              key: const Key("MapFlutterKey"),
              mapController: _mapControlleur,
              options: MapOptions(
                onPositionChanged: (position, hasGesture) {
                  //
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
                        return Transform.scale(
                          scale: 1.2,
                          child: SvgPicture.string(
                            """
<svg viewBox="-197.855 0 791.42 791.42">
            <g>
                <path d="M197.849,0C122.131,0,60.531,61.609,60.531,137.329c0,72.887,124.591,243.177,129.896,250.388l4.951,6.738
    		c0.579,0.792,1.501,1.255,2.471,1.255c0.985,0,1.901-0.463,2.486-1.255l4.948-6.738c5.308-7.211,129.896-177.501,129.896-250.388
    		C335.179,61.609,273.569,0,197.849,0z M197.849,88.138c27.13,0,49.191,22.062,49.191,49.191c0,27.115-22.062,49.191-49.191,49.191
    		c-27.114,0-49.191-22.076-49.191-49.191C148.658,110.2,170.734,88.138,197.849,88.138z" transform="rotate(${locationData.heading} 197.855 395.71)" fill="green" />
            </g>
        </svg>
""",
                            width: 100,
                            color: Colors.red,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                PolylineLayerOptions(
                  polylines: [
                    Polyline(
                      points: Provider.of<LocationProvider>(
                        context,
                      )
                          .localizationsData
                          .map(
                            (e) => LatLng(e.latitude, e.longitude),
                          )
                          .toList(),
                      strokeWidth: 4.0,
                      gradientColors: [
                        const Color(0xffE40203),
                        const Color(0xffE40203),
                        const Color(0xffE40203),
                      ],
                    ),
                  ],
                ),
                PolygonLayerOptions(
                  polygons: polygons,
                ),
                /* PolylineLayerOptions(
                  polylines: polyLines,
                ),
                PolylineLayerOptions(
                  polylines: polyLines,
                  //polylineCulling: true,
                ), */
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
        _mapControlleur.move /* AndRotate */ (currentPosition, _mapControlleur.zoom /* , 0 */);
      }
      /* pointsGradient = [
        ...pointsGradient,
        LatLng(locationData.latitude + Random().nextDouble(),
            locationData.longitude + Random().nextDouble())
      ]; */
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

class PolylinePage extends StatefulWidget {
  const PolylinePage({Key? key}) : super(key: key);

  @override
  State<PolylinePage> createState() => _PolylinePageState();
}

class _PolylinePageState extends State<PolylinePage> {
  late List<Polyline> polylines;

  late Timer timer;
  double get random => (Random().nextDouble() * 2.0 - 1) * 0.05;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      setState(() {
        points.add(
          LatLng(
            34.928605854017 + random,
            -2.3147196356671724 + random,
          ),
        );
      });
    });
    polylines = [
      Polyline(
        points: points,
        strokeWidth: 4.0,
        color: Colors.red,
      ),
    ];
  }

  List<LatLng> points = [];

  @override
  Widget build(BuildContext context) {
    /* var points = <LatLng>[
      LatLng(51.5, -0.09),
      LatLng(53.3498, -6.2603),
      LatLng(48.8566, 2.3522),
    ];

    var pointsGradient = <LatLng>[
      LatLng(55.5, -0.09),
      LatLng(54.3498, -6.2603),
      LatLng(52.8566, 2.3522),
    ]; */

    return SizedBox(
      height: 400,
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(34.928605854017, -2.3147196356671724),
          zoom: 15.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayerOptions(
            polylines: polylines,
            polylineCulling: true,
          ),
          /* PolylineLayerOptions(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 4.0,
                color: Colors.purple,
              ),
            ],
          ),
          PolylineLayerOptions(
            polylines: [
              Polyline(
                points: pointsGradient,
                strokeWidth: 4.0,
                gradientColors: [
                  const Color(0xffE40203),
                  const Color(0xffFEED00),
                  const Color(0xff007E2D),
                ],
              ),
            ],
          ), */
        ],
      ),
    );
  }
}
