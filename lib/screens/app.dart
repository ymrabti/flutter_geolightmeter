import 'dart:io';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/csv/all_csv.dart';
import 'package:geo_ligtmeter/csv/load_csv_data_screen.dart';
import 'package:geo_ligtmeter/models/models.dart';
import 'package:geo_ligtmeter/models/providers.dart';
import 'package:geo_ligtmeter/screens/compass.dart';
import 'package:geo_ligtmeter/screens/folder_picker/folder_picker.dart';
import 'package:geo_ligtmeter/screens/location.dart';
import 'package:geo_ligtmeter/screens/maps.dart';
import 'package:geo_ligtmeter/screens/lux_light.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
          leading: GestureDetector(
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return const AllCsvFilesScreen();
                  },
                ),
              );
            },
            child: Container(
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(Icons.storage_outlined),
              ),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
            ),
          ),
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
            if (flspots.isNotEmpty && !isRecording) saveCSV(flspots),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return const CompassApp();
                    },
                  ),
                );
              },
              child: Container(
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

  GestureDetector saveCSV(List<MyLuxCSV> flspots) {
    return GestureDetector(
      onTap: () async {
        await generateCsv(flspots);
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
    );
  }

  Future<void> generateCsv(List<MyLuxCSV> list) async {
    List<List<dynamic>> data = [
      ["Time", "Lux", "Latitude.", "Longitude", "Altitude", "Accuracy", "Heading", "Speed"],
      ...List.generate(
        list.length,
        (index) {
          var listItem = list[index];
          return [
            listItem.dateTime.toString(),
            listItem.lux.toString(),
            listItem.localizationData.latitude.toStringAsFixed(6),
            listItem.localizationData.longitude.toStringAsFixed(6),
            listItem.localizationData.altitude.toStringAsFixed(4),
            listItem.localizationData.accuracy.toStringAsFixed(2),
            listItem.localizationData.heading.toStringAsFixed(0),
            listItem.localizationData.speed.toStringAsFixed(0),
          ];
        },
      ),
    ];
    String csvData = const ListToCsvConverter().convert(data);
    final String directory = await getSaveDir(context);
    final path = "$directory/csv-${DateTime.now()}.csv";
    final File file = File(path);
    var status = await Permission.manageExternalStorage.status;
    consoleLog(text: {status, directory});
    await Permission.storage.request();
    if (status.isRestricted) {
      status = await Permission.manageExternalStorage.request();
    } else if (status.isDenied) {
      status = await Permission.manageExternalStorage.request();
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Please add permission for app to manage external storage'),
        ),
      );
    } else {
      file.writeAsStringSync(csvData);
      Provider.of<LuxProvider>(context, listen: false).clearRecords();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) {
            return LoadCsvDataScreen(path: path);
          },
        ),
      );
    }
  }
}

Future<Directory> getDir() async {
  var externalStorageDirectories = await getExternalStorageDirectories();
  return externalStorageDirectories![0];
}

Future<String> getSaveDir(BuildContext context) async {
  Directory? directory = Directory(FolderPicker.rOOTPATH);
  Directory? newDirectory = await FolderPicker.pick(
    allowFolderCreation: true,
    context: context,
    rootDirectory: directory,
  );
  return newDirectory!.path;
}

Future<String> _selectDirectory(BuildContext buildContext) async {
  Directory? rootPath = await getDir();
  String? path = await FilesystemPicker.open(
    title: 'Save to folder',
    context: buildContext,
    rootDirectory: rootPath,
    fsType: FilesystemType.folder,
    pickText: 'Save file to this folder',
    folderIconColor: Colors.teal,
    requestPermission: () async {
      var request = Permission.storage.request();
      var bool = await request.isGranted;
      return bool;
    },
  );
  return path ?? "";
}
