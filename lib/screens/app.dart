import 'dart:io';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/csv/load_csv_data_screen.dart';
import 'package:geo_ligtmeter/models/models.dart';
import 'package:geo_ligtmeter/models/providers.dart';
import 'package:geo_ligtmeter/screens/location.dart';
import 'package:geo_ligtmeter/screens/maps.dart';
import 'package:geo_ligtmeter/screens/lux_light.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ApplicationGeoLightmeter extends StatefulWidget {
  const ApplicationGeoLightmeter({Key? key}) : super(key: key);

  @override
  State<ApplicationGeoLightmeter> createState() => _ApplicationGeoLightmeterState();
}

class _ApplicationGeoLightmeterState extends State<ApplicationGeoLightmeter> {
  @override
  Widget build(BuildContext context) {
    var luxProvider = Provider.of<LuxProvider>(context);
    List<MyLuxCSV> flspots = luxProvider.fflSpot;
    bool isRecording = luxProvider.isRecording;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Geo Lightmeter'),
          actions: [
            GestureDetector(
              onTap: () {
                Provider.of<LuxProvider>(context, listen: false).changedRecord();
              },
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(isRecording ? Icons.pause : Icons.play_arrow_rounded),
                ),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ),
            if (flspots.isNotEmpty && !isRecording)
              GestureDetector(
                onTap: () {
                  generateCsv(flspots);
                },
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(Icons.save),
                  ),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    '${flspots.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
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
              //   PolylinePage(),
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

  generateCsv(List<MyLuxCSV> list) async {
    List<List<dynamic>> data = [
      ["Time", "Lux", "Latitude.", "Longitude", "Altitude", "Accuracy", "Heading", "Speed"],
      ...List.generate(
        list.length,
        (index) {
          var listItem = list[index];
          return [
            listItem.dateTime.toString(),
            listItem.lux.toString(),
            listItem.localizationData.latitude.toString(),
            listItem.localizationData.longitude.toString(),
            listItem.localizationData.altitude.toString(),
            listItem.localizationData.accuracy.toString(),
            listItem.localizationData.heading.toString(),
            listItem.localizationData.speed.toString(),
          ];
        },
      ),
    ];
    String csvData = const ListToCsvConverter().convert(data);
    final String directory = (await getApplicationDocumentsDirectory()).path;
    final path = "$directory/csv-${DateTime.now()}.csv";
    consoleLog(text: path);
    final File file = File(path);
    await file.writeAsString(csvData);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return LoadCsvDataScreen(path: path);
        },
      ),
    );
  }
}
