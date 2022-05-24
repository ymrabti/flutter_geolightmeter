import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:geo_ligtmeter/screens/app.dart';
import 'package:geo_ligtmeter/screens/location.dart';

class LoadCsvDataScreen extends StatefulWidget {
  final String path;
  const LoadCsvDataScreen({Key? key, required this.path}) : super(key: key);

  @override
  State<LoadCsvDataScreen> createState() => _LoadCsvDataScreenState();
}

class _LoadCsvDataScreenState extends State<LoadCsvDataScreen> {
  bool isAscending = false;
  bool dataProcessing = false;

  int sortColumnIndex = 0;

  List users = [];

  List selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.path.split('/').last),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: !dataProcessing
            ? FutureBuilder(
                key: ValueKey<bool>(dataProcessing),
                future: loadingCsvData(widget.path),
                builder: builderFuture,
              )
            : cupert(),
      ),
    );
  }

  Widget builderFuture(context, AsyncSnapshot<List<dynamic>> snapshot) {
    var filename = widget.path.split("/").last;
    if (snapshot.connectionState == ConnectionState.waiting) {
      return cupert();
    } else if (snapshot.connectionState == ConnectionState.active) {
      return cupert(color: Colors.red);
    } else if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        var columns2 = getColumns(snapshot);
        var rows2 = getRows(snapshot);
        var string = snapshot.data!.sublist(1).toString();
        String substring = getFileName(filename);
        // substring.insert(17, ".");
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Padding>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Visibility(
                          visible: !widget.path.contains('$emulatd/files'),
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                dataProcessing = !dataProcessing;
                              });
                              Directory to = (await getExternalDir())[0];
                              String toPath = '${to.path}/$filename';
                              try {
                                await File(widget.path).copy(toPath);
                                await File(widget.path).delete();
                                Navigator.of(context).pop();
                              } on Exception catch (e) {
                                consoleLog(text: e);
                              }
                              setState(() {
                                dataProcessing = !dataProcessing;
                              });
                            },
                            child: const Text("Migrer"),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              dataProcessing = !dataProcessing;
                            });
                            try {
                              Directory to = (await getExternalDir())[0];
                              String toPath = '${to.path}/$substring.txt';
                              final File file = File(toPath);
                              await file.writeAsString(string);
                              await Future.delayed(const Duration(seconds: 2));
                              Navigator.pop(context);
                            } on Exception catch (e) {
                              consoleLog(text: e);
                            }
                            setState(() {
                              dataProcessing = !dataProcessing;
                            });
                          },
                          child: const Text("Text File"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await FlutterShare.shareFile(
                              title: 'Partager',
                              text: 'Partager Fichier',
                              filePath: widget.path,
                            );
                          },
                          child: Row(
                            children: const [
                              Text("Fichier"),
                              Icon(Icons.share),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await FlutterShare.share(
                              title: 'Partager',
                              text: string,
                              //   chooserTitle: filename,
                              //   linkUrl: string,
                            );
                          },
                          child: Row(
                            children: const [
                              Text("Text"),
                              Icon(Icons.share),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  DataTable(
                    sortAscending: isAscending,
                    sortColumnIndex: sortColumnIndex,
                    onSelectAll: onSelectAll,
                    columns: columns2,
                    rows: rows2,
                  ),
                ],
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
  }

  void onSelectAll(isSelectedAll) {
    setState(
      () => selectedUsers = isSelectedAll! ? users : [],
    );
  }

  List<DataColumn> getColumns(AsyncSnapshot<List<dynamic>> snapshot) {
    return (snapshot.data![0] as List)
        .map(
          (e) => DataColumn(
            label: Text(e),
          ),
        )
        .toList();
  }

  List<DataRow> getRows(AsyncSnapshot<List<dynamic>> snapshot) {
    return snapshot.data!
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
        .toList();
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

  /* pickFile() async {
    var initialDirectory2 = await getDocumentsDir();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: initialDirectory2.path,
      dialogTitle: 'Save to folder',
      allowedExtensions: ['csv'],
      type: FileType.custom,
      onFileLoading: (filePickerStatus) {
        consoleLog(text: filePickerStatus);
      },
      /* context: buildContext,
      rootDirectory: rootPath,
      pickText: 'Save file to this folder',
      folderIconColor: Colors.teal,
      requestPermission: () async {
        var request = Permission.storage.request();
        var bool = await request.isGranted;
        return bool;
      }, */
    );
    if (result != null) {
      PlatformFile file = result.files.first;

      var file2 = File(file.path!);
      /* final input = file2.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(
            const CsvToListConverter(),
          )
          .toList();

      consoleLog(text: '$fields', color: 33); */
    }
  } */

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