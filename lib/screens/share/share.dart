import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:geo_ligtmeter/screens/location.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:screenshot/screenshot.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final _controller = ScreenshotController();

  MyApp({Key? key}) : super(key: key);

  Future<void> share() async {
    await FlutterShare.share(
      title: 'Example share',
      text: 'Example share text',
      linkUrl: 'https://flutter.dev/',
      chooserTitle: 'Example Chooser Title',
    );
  }

  Future<void> shareFile() async {
    // var externalDir = await getExternalDir();
    final result = await FilePicker.platform.pickFiles(
        /* allowMultiple: false,
      dialogTitle: "Selectt file(1)",
      initialDirectory: externalDir.path,
      onFileLoading: (status) {
        consoleLog(text: status);
      }, */
        );
    if (result == null || result.files.isEmpty) return;
    var files = result.files.map((e) => e.path).toList();
    consoleLog(text: files, color: 32);
    /* try { */
    await FlutterShare.shareFile(
      title: 'Example share',
      text: 'Example share text',
      filePath: files[0] ?? "",
    );
    /* } catch (e) {
      consoleLog(text: e, color: 31);
    } */
  }

  Future<void> shareScreenshot() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await path_provider.getExternalStorageDirectory();
    } else {
      directory = await path_provider.getApplicationDocumentsDirectory();
    }
    final String localPath = '${directory!.path}/${DateTime.now().toIso8601String()}.png';

    await _controller.captureAndSave(localPath);

    await Future.delayed(const Duration(seconds: 1));

    await FlutterShare.shareFile(
      title: 'Compartilhar comprovante',
      filePath: localPath,
      fileType: 'image/png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Screenshot(
            controller: _controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  child: const Text('Share text and link'),
                  onPressed: share,
                ),
                TextButton(
                  child: const Text('Share local file'),
                  onPressed: shareFile,
                ),
                TextButton(
                  child: const Text('Share screenshot'),
                  onPressed: shareScreenshot,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
