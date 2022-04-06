import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/models/models.dart';
import 'package:geo_ligtmeter/screens/location.dart';

class LocationProvider extends ChangeNotifier {
  LocalizationData localizationData;
  LocationProvider({required this.localizationData});
  void changedLocation({required LocalizationData chngeLoc}) {
    localizationData = chngeLoc;
    notifyListeners();
  }
}

class LuxProvider extends ChangeNotifier {
  List<FlSpot> fflSpot;
  LuxProvider({required this.fflSpot});
  void changedAddLux({required FlSpot flSpot}) {
    consoleLog(text: flSpot);
    fflSpot.add(flSpot);
    notifyListeners();
  }
}
