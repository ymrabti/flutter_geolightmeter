import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/models/models.dart';
import 'package:geo_ligtmeter/models/providers.dart';
import 'package:geo_ligtmeter/screens/location.dart';
import 'package:light/light.dart';
import 'package:provider/provider.dart';

class LuxBanner extends StatefulWidget {
  const LuxBanner({Key? key}) : super(key: key);

  @override
  State<LuxBanner> createState() => _LuxBannerState();
}

class _LuxBannerState extends State<LuxBanner> {
  int _luxString = 0;
  late Light _light;
  late StreamSubscription _subscription;

  final Color graphColor = Colors.blueAccent;

  final limitCount = 50;
  final luxPoints = <FlSpot>[];
  get subList {
    int length = luxPoints.length;
    return luxPoints.sublist(
      length < 50 ? 0 : length - 50,
    );
  }

  double xValue = 0;
  double step = 0.1;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      while (luxPoints.length > limitCount) {
        luxPoints.removeAt(0);
      }
      double luxStr = _luxString.toDouble();
      var flSpot = FlSpot(
        xValue,
        luxStr,
      );
      setState(() {
        xValue += step;
        luxPoints.add(
          flSpot,
        );
      });
      var luxProv = Provider.of<LuxProvider>(context, listen: false);
      final localization2 =
          Provider.of<LocationProvider>(context, listen: false).getLocalizationData();
      /* var localization1 = LocalizationData(
        accuracy: 0,
        altitude: 0,
        heading: 0,
        latitude: 0,
        longitude: 0,
        speed: 0,
      ); */
      var localization = localization2;
      MyLuxCSV myLuxCSV = MyLuxCSV(
        lux: luxStr,
        dateTime: DateTime.now(),
        localizationData: localization,
      );
      luxProv.changedAddLux(geoLux: myLuxCSV);
    });
    startListening();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return luxPoints.isNotEmpty ? colon() : Container();
  }

  void onData(int luxValue) async {
    setState(() {
      _luxString = luxValue;
    });
  }

  void stopListening() {
    _subscription.cancel();
  }

  void startListening() {
    _light = Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      consoleLog(text: exception.cause);
    }
  }

  Column colon() {
    var screenSize = MediaQuery.of(context).size;
    var labelTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: screenSize.width * 0.05,
      wordSpacing: 1.5,
      shadows: const [
        Shadow(
          color: Color(0xFFFFFFFF),
          blurRadius: 6,
        ),
      ],
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Time: ${xValue.toStringAsFixed(1)}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Lux: ${luxPoints.last.y.toStringAsFixed(1)}',
          style: TextStyle(
            color: graphColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Container(
          color: Colors.amber,
          width: screenSize.width,
          height: 300,
          child: LineChart(
            LineChartData(
              minY: getMinMax()[0],
              maxY: getMinMax()[1],
              minX: luxPoints.first.x,
              maxX: luxPoints.last.x,
              lineTouchData: LineTouchData(enabled: false),
              clipData: FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
              ),
              baselineX: 0,
              baselineY: 165,
              axisTitleData: FlAxisTitleData(
                bottomTitle: AxisTitle(
                  margin: 2,
                  showTitle: true,
                  titleText: "temps",
                  textStyle: labelTextStyle,
                ),
                leftTitle: AxisTitle(
                  margin: 2,
                  showTitle: true,
                  titleText: "Lux",
                  textStyle: labelTextStyle,
                ),
              ),
              lineBarsData: [
                luxData(luxPoints),
              ],
              titlesData: FlTitlesData(
                show: true,
                topTitles: SideTitles(
                  showTitles: true,
                  rotateAngle: 90,
                ),
                rightTitles: SideTitles(
                  showTitles: false,
                ),
                bottomTitles: SideTitles(
                  showTitles: false,
                ),
              ),
            ),
            swapAnimationCurve: Curves.bounceIn,
          ),
        )
      ],
    );
  }

  List<double> getMinMax() {
    var map = luxPoints.map((e) => e.y).toList();
    map.sort();
    double mn = map.first;
    double mx = map.last;
    var lstRtrn = [
      mn - 0.1 * (mx - mn),
      max(mx + 0.1 * (mx - mn), mn + 20),
    ];
    return lstRtrn;
  }

  LineChartBarData luxData(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      colors: [/* cosColor.withOpacity(0), */ graphColor],
      //   colorStops: [0.1, 1.0],
      barWidth: 4,
      isCurved: true,
    );
  }
}
