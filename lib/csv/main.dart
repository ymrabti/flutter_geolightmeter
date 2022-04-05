import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/csv/all_csv.dart';
import 'package:geo_ligtmeter/csv/load_csv_data_screen.dart';
import 'package:geo_ligtmeter/location.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:random_string/random_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Csv Demo',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const MyHomePage(title: 'Flutter Csv Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AllCsvFilesScreen(),
                  ),
                );
              },
              child: const Text("Load all csv form phone storage"),
            ),
            ElevatedButton(
              onPressed: () {
                loadCsvFromStorage();
              },
              child: const Text("Load csv form phone storage"),
            ),
            ElevatedButton(
              onPressed: () {
                generateCsv();
              },
              child: const Text("Load Created csv"),
            ),
          ],
        ),
      ),
    );
  }

  generateCsv() async {
    List<List<dynamic>> data = [
      ["No.", "Name", "Nickname No.", "Back No.", "Back No.", "Award"],
      ...List.generate(
        50,
        (index) => [
          index + 1,
          randomAlpha(8),
          randomAlpha(5),
          randomNumeric(3),
          randomNumeric(3),
          randomAlpha(11),
        ],
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

  loadCsvFromStorage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['csv'],
      type: FileType.custom,
      //   allowMultiple: true,
    );
    if (result != null) {
      String path = result.files.first.path!;
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
