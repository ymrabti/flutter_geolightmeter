import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geo_ligtmeter/csv/load_csv_data_screen.dart';
import 'package:geo_ligtmeter/screens/app.dart';
import 'package:path_provider/path_provider.dart';
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
          const center = Center(child: CupertinoActivityIndicator());
          if (snapshot.connectionState == ConnectionState.done) {
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
                var path2 = snapshot.data![index].path;
                var substring = path2.split("/").last;
                Color color2 = path2.contains('$emulatd/files')
                    ? Colors.white
                    : path2.contains('$emulatd/cache')
                        ? Colors.blue
                        : Colors.red;
                Icon icon = path2.contains('$emulatd/files')
                    ? const Icon(Icons.file_copy_rounded)
                    : path2.contains('$emulatd/cache')
                        ? const Icon(Icons.cached)
                        : const Icon(Icons.dock);
                Widget trail = path2.contains('$emulatd/files')
                    ? const Text('Files')
                    : path2.contains('$emulatd/cache')
                        ? const Text('Cache')
                        : const Text('Hidden');
                return Card(
                  color: color2,
                  elevation: 4,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: ListTile(
                    leading: icon,
                    trailing: trail,
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => LoadCsvDataScreen(path: path2),
                          ), (Route<dynamic> route) {
                        return route.isFirst;
                      });
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
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return center;
          } else {
            return center;
          }
        },
      ),
    );
  }

  Future<List<FileSystemEntity>> _getAllCsvFiles(BuildContext context) async {
    // await Future.delayed(Duration(seconds: 1));
    final List<Directory> cache = await getExternalCacheDirectories() ?? [];
    final List<Directory> extr = await getExternalDir();
    final Directory docs = await getDocumentsDir();
    List<FileSystemEntity> _lstCaches = getListFilesFromDirs(cache);
    List<FileSystemEntity> _docsFiles = getListFilesFromDirs(extr);
    List<FileSystemEntity> _suppFiles = getListFilesFromDirs([docs]);
    List<FileSystemEntity> list = [..._suppFiles, ..._docsFiles, ..._lstCaches];
    List<FileSystemEntity> allFiles = list.where(
      (element) {
        var pathLength = element.path.length;
        var substring = element.path.substring(pathLength - 4);
        return substring == ".csv" || substring == ".CSV";
      },
    ).toList();

    allFiles.sort((a, b) {
      var aFn = a.path.split("/").last;
      var bFn = b.path.split("/").last;
      return bFn.compareTo(aFn);
    });

    return allFiles;
  }

  List<FileSystemEntity> getListFilesFromDirs(List<Directory> directories) {
    return directories.fold<List<FileSystemEntity>>(
      [],
      (e, dir) => [
        ...dir.listSync(
          recursive: true,
          followLinks: false,
        ),
        ...e
      ],
    ).toList();
  }
}
