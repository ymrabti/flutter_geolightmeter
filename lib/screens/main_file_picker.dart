import 'dart:io';
import 'package:flutter/material.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const FilePickerApp());

class FilePickerApp extends StatefulWidget {
  const FilePickerApp({Key? key}) : super(key: key);

  @override
  _FilePickerAppState createState() => _FilePickerAppState();

  static _FilePickerAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_FilePickerAppState>();
  }
}

class _FilePickerAppState extends State<FilePickerApp> {
  Brightness _brightness = Brightness.light;

  Brightness get brightness => _brightness;

  void setThemeBrightness(Brightness brightness) {
    setState(() {
      _brightness = brightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FileSystem Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: Colors.white,
          brightness: _brightness,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.teal,
          textTheme: ButtonTextTheme.accent,
        ),
        toggleableActiveColor: Colors.teal,
        brightness: _brightness,
      ),
      home: const FilePickerDemoPage(),
    );
  }
}

class FilePickerDemoPage extends StatefulWidget {
  const FilePickerDemoPage({Key? key}) : super(key: key);

  @override
  _FilePickerDemoPageState createState() => _FilePickerDemoPageState();
}

class _FilePickerDemoPageState extends State<FilePickerDemoPage> {
  Directory? rootPath;

  String? filePath;
  String? dirPath;

  FileTileSelectMode filePickerSelectMode = FileTileSelectMode.checkButton;

  @override
  void initState() {
    _prepareStorage();
    super.initState();
  }

  Future<void> _prepareStorage() async {
    rootPath = await getTemporaryDirectory();

    // Create sample directory if not exists
    Directory sampleFolder = Directory('${rootPath!.path}/Sample folder');
    if (!sampleFolder.existsSync()) {
      sampleFolder.createSync();
    }

    // Create sample file if not exists
    File sampleFile = File('${sampleFolder.path}/Sample.txt');
    if (!sampleFile.existsSync()) {
      sampleFile.writeAsStringSync('FileSystem Picker sample file.');
    }

    setState(() {});
  }

  Future<void> _openFile(BuildContext context) async {
    String? path = await FilesystemPicker.open(
      title: 'Open file',
      context: context,
      rootDirectory: rootPath!,
      fsType: FilesystemType.file,
      folderIconColor: Colors.teal,
      //   allowedExtensions: ['.txt'],
      fileTileSelectMode: filePickerSelectMode,
      requestPermission: () async => await Permission.storage.request().isGranted,
    );

    if (path != null) {
      File file = File(path);
      String contents = await file.readAsString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(contents),
        ),
      );
    }

    setState(() {
      filePath = path;
    });
  }

  Future<void> _pickDir(BuildContext context) async {
    String? path = await FilesystemPicker.open(
      title: 'Save to folder',
      context: context,
      rootDirectory: rootPath!,
      fsType: FilesystemType.folder,
      pickText: 'Save file to this folder',
      folderIconColor: Colors.teal,
      requestPermission: () async => await Permission.storage.request().isGranted,
    );

    setState(() {
      dirPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = FilePickerApp.of(context);

    return Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Theme Brightness Switch Button
                ElevatedButton(
                  child: Text((appState!.brightness == Brightness.light)
                      ? 'Switch to Dark theme'
                      : 'Switch to Light theme'),
                  onPressed: () {
                    appState.setThemeBrightness(
                      appState.brightness == Brightness.light ? Brightness.dark : Brightness.light,
                    );
                  },
                ),

                const Divider(height: 60),

                // Directory picker section

                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Directory Picker',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),

                if (dirPath != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('$dirPath'),
                  ),

                ElevatedButton(
                  child: const Text('Save File'),
                  onPressed: (rootPath != null) ? () => _pickDir(context) : null,
                ),

                const Divider(height: 60),

                // File picker section

                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'File Picker',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),

                if (filePath != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('$filePath'),
                  ),

                ElevatedButton(
                  child: const Text('Open File'),
                  onPressed: (rootPath != null) ? () => _openFile(context) : null,
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CheckboxListTile(
                    title: const Text('Whole item selection mode'),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: filePickerSelectMode == FileTileSelectMode.wholeTile,
                    onChanged: (bool? newValue) => {
                      setState(() {
                        filePickerSelectMode = newValue!
                            ? FileTileSelectMode.wholeTile
                            : FileTileSelectMode.checkButton;
                      })
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
