import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/csv/load_csv_data_screen.dart';
import 'package:geo_ligtmeter/screens/app.dart';
import 'package:geo_ligtmeter/screens/location.dart';
import 'dart:io';
import 'load_csv_data_screen.dart';

class AllCsvFilesScreen extends StatelessWidget {
  const AllCsvFilesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Enregistrements"),
      ),
      body: FutureBuilder(
        future: _getAllCsvFiles(context),
        builder: (context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Aucune enregistrement",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No Csv File found.'),
            );
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              var substring = snapshot.data![index].path.split("/").last;
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoadCsvDataScreen(path: snapshot.data![index].path),
                      ),
                    );
                  },
                  title: Text(
                    substring,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            itemCount: snapshot.data!.length,
          );
        },
      ),
    );
  }

  Future<List<FileSystemEntity>> _getAllCsvFiles(BuildContext context) async {
    final Directory directory = await getDir();
    final path = "${directory.path}/";
    final myDir = Directory(path);
    List<FileSystemEntity> _csvFiles;
    _csvFiles = myDir.listSync(recursive: true, followLinks: false);
    _csvFiles.sort((a, b) {
      return b.path.compareTo(a.path);
    });
    return _csvFiles.where((element) {
      var pathLength = element.path.length;
      var substring = element.path.substring(pathLength - 4);
      return substring == ".csv" || substring == ".CSV";
    }).toList();
  }
}
