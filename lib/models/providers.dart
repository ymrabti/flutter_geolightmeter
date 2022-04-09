import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/models/models.dart';

class LocationProvider extends ChangeNotifier {
  LocalizationData localizationData;
  List<LocalizationData> localizationsData;

  LocationProvider({required this.localizationData, required this.localizationsData});
// // //
  LocalizationData getLocalizationData() {
    return localizationData;
  }

  void changedLocation({required LocalizationData chngeLoc}) {
    localizationData = chngeLoc;
    notifyListeners();
  }

  void adddLocation({required LocalizationData chngeLoc}) {
    localizationsData.add(chngeLoc);
    notifyListeners();
  }
}

class LuxProvider extends ChangeNotifier {
  List<MyLuxCSV> fflSpot;
  bool isRecording;

  LuxProvider({required this.fflSpot, this.isRecording = false});
  void changedAddLux({required MyLuxCSV geoLux}) {
    if (isRecording) fflSpot.add(geoLux);
    notifyListeners();
  }

  void clearRecords() {
    fflSpot.clear();
    notifyListeners();
  }

  void changedRecord() {
    isRecording = !isRecording;
    notifyListeners();
  }
}
