import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/csv/all_csv.dart';
import 'package:geo_ligtmeter/csv/load_csv_data_screen.dart';
import 'package:geo_ligtmeter/models/models.dart';
import 'package:geo_ligtmeter/models/providers.dart';
import 'package:geo_ligtmeter/screens/folder_picker/folder_picker.dart';
import 'package:geo_ligtmeter/screens/location.dart';
import 'package:geo_ligtmeter/screens/maps.dart';
import 'package:geo_ligtmeter/screens/lux_light.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class ApplicationGeoLightmeter extends StatefulWidget {
  const ApplicationGeoLightmeter({Key? key}) : super(key: key);

  @override
  State<ApplicationGeoLightmeter> createState() => _ApplicationGeoLightmeterState();
}

class _ApplicationGeoLightmeterState extends State<ApplicationGeoLightmeter> {
  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
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
              /* CompassApp(),
              SensorsPlusPage(), */
              LuxBanner(),
              LocationScreen(),
              MapsFlutter(),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector saveCSV(List<MyLuxCSV> flspots) {
    return GestureDetector(
      onTap: () async {
        final String directory = await getSaveDir(context);
        await generateCsv(flspots, directory);
      },
      onLongPress: () async {
        // final Directory directory = await getDocumentsDir();
        final Directory? dir = await showCupertinoDialog<Directory>(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text(
                "Enregisrer sous",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text("choisir un dossier"),
              actions: [
                CupertinoButton(
                  child: const Text("Application Support"),
                  onPressed: () async {
                    final Directory directory = await getDocumentsDir();
                    consoleLog(text: directory.path, color: 31);
                    Navigator.pop(context, directory);
                  },
                ),
                CupertinoButton(
                  child: const Text("Dossier d'application"),
                  onPressed: () async {
                    final Directory directory = (await getExternalDir())[0];
                    consoleLog(text: directory.path, color: 32);
                    Navigator.pop(context, directory);
                  },
                ),
                CupertinoButton(
                  child: const Text("Dossier cache"),
                  onPressed: () async {
                    final Directory directory =
                        (await path_provider.getExternalCacheDirectories())![0];
                    consoleLog(text: directory.path, color: 33);
                    Navigator.pop(context, directory);
                  },
                ),
                /* CupertinoButton(
                  child: const Text("Library"),
                  onPressed: () async {
                    final Directory directory = (await path_provider.getLibraryDirectory());
                    consoleLog(text: directory.path, color: 33);
                    Navigator.pop(context, directory);
                  },
                ),
                CupertinoButton(
                  child: const Text("Temperary"),
                  onPressed: () async {
                    final Directory directory = (await path_provider.getTemporaryDirectory());
                    consoleLog(text: directory.path, color: 39);
                    Navigator.pop(context, directory);
                  },
                ), */
              ],
            );
          },
        );
        if (dir != null) {
          await generateCsv(flspots, dir.path);
        }
      },
      onDoubleTap: () async {
        final Directory directory = (await path_provider.getExternalStorageDirectories())![0];
        await generateCsv(flspots, directory.path);
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

  Future<void> generateCsv(List<MyLuxCSV> list, String directory) async {
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
    final path = "$directory/csv-${DateTime.now()}.csv";
    final File file = File(path);
    var status = await Permission.manageExternalStorage.status;
    // consoleLog(text: {status, directory});
    await Permission.storage.request();
    if (status.isRestricted || status.isDenied) {
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

Future<List<Directory>> getExternalDir() async {
  var externalStorageDirectories = await path_provider.getExternalStorageDirectories();
  return externalStorageDirectories ?? [];
}

Future<Directory> getDocumentsDir() async => await path_provider.getApplicationDocumentsDirectory();

Future<String> getSaveDir(BuildContext buildContext) async => (await getExternalDir())[0].path;

Future<String> selectDirectory(BuildContext context) async {
  Directory? directory = Directory(FolderPicker.rOOTPATH);
  Directory? newDirectory = await FolderPicker.pick(
    allowFolderCreation: true,
    context: context,
    rootDirectory: directory,
  );
  return newDirectory!.path;
}

const String emulatd = "/storage/emulated/0/Android/data/com.ymrabtiapps.geoligtmeter";

String getFileName(String filename) {
  var substring = filename.replaceAll(RegExp(r'[\:|\- \.csv]'), "").substring(0, 12).split("");
  substring.insert(4, ".");
  substring.insert(7, ".");
  substring.insert(10, ".");
  substring.insert(13, ".");
  return substring.join("");
}

// Future<Directory> getSupportDir() async => await getApplicationSupportDirectory();

/* String? path = await FilesystemPicker.open(
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
  return path ?? ""; */
