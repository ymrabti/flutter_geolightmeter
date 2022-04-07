import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/screens/location.dart';

class LoadCsvDataScreen extends StatefulWidget {
  final String path;
  const LoadCsvDataScreen({Key? key, required this.path}) : super(key: key);

  @override
  State<LoadCsvDataScreen> createState() => _LoadCsvDataScreenState();
}

class _LoadCsvDataScreenState extends State<LoadCsvDataScreen> {
  bool isAscending = false;

  int sortColumnIndex = 0;

  List users = [];

  List selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CSV DATA"),
      ),
      body: FutureBuilder(
        future: loadingCsvData(widget.path),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          consoleLog(text: snapshot.data.toString(), color: 32);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return cupert();
          } else if (snapshot.connectionState == ConnectionState.active) {
            return cupert(color: Colors.red);
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      sortAscending: isAscending,
                      sortColumnIndex: sortColumnIndex,
                      onSelectAll: (isSelectedAll) {
                        setState(
                          () => selectedUsers = isSelectedAll! ? users : [],
                        );
                      },
                      columns: (snapshot.data![0] as List)
                          .map(
                            (e) => DataColumn(
                              label: Text(e),
                            ),
                          )
                          .toList(),
                      rows: snapshot.data!
                          .sublist(1)
                          .map(
                            (e) => DataRow(
                              cells: (e as List)
                                  .map(
                                    (ee) => DataCell(
                                      Text(
                                        (ee is int || ee is double) ? ee.toString() : ee,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return err(color: Colors.red);
            } else {
              return err();
            }
          } else if (snapshot.connectionState == ConnectionState.active) {
            return cupert(color: Colors.red);
          } else {
            return err();
          }
        },
      ),
    );
  }

  Center cupert({Color color = Colors.green}) {
    return Center(
      child: CupertinoActivityIndicator(
        color: color,
      ),
    );
  }

  Center err({Color color = const Color(0xFF570E09)}) {
    return Center(
      child: Icon(
        Icons.error,
        color: color,
      ),
    );
  }

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;

      final input = File(file.path!).openRead();
      final fields =
          await input.transform(utf8.decoder).transform(const CsvToListConverter()).toList();

      consoleLog(text: '$fields', color: 33);
    }
  }

  Future<List<List<dynamic>>> loadingCsvData(String path) async {
    // await Future.delayed(const Duration(seconds: 2));
    final csvFile = File(path).openRead();
    return await csvFile
        .transform(utf8.decoder)
        .transform(
          const CsvToListConverter(),
        )
        .toList();
  }
}

/* child: Column(
children: snapshot.data!
    .map(
        (data) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
            Text(
                data[0].toString(),
            ),
            Text(
                data[1].toString(),
            ),
            Text(
                data[2].toString(),
            ),
            Text(
                data[2].toString(),
            ),
            ],
        ),
        ),
    )
    .toList(),
), */