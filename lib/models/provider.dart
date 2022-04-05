import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/models/models.dart';

class LocationProvider extends ChangeNotifier {
  LocalizationData localizationData;
  LocationProvider({required this.localizationData});
  void changedLocation({required LocalizationData chngeLoc}) {
    localizationData = chngeLoc;
    notifyListeners();
  }
}
