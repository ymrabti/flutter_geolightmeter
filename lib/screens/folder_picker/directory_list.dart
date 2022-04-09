/*
 * Copyright (c) 2020. Kapil. All Rights Reserved
 *  This file is protected by copyright and distributed under
 *  licenses restricting copying, distribution and decompilation.
 */
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'folder_picker.dart';

/// Internal widget used for rendering directory list
class DirectoryList extends StatefulWidget {
  const DirectoryList({Key? key}) : super(key: key);

  @override
  _DirectoryListState createState() => _DirectoryListState();
}

class _DirectoryListState extends State<DirectoryList> {
  static const double spacing = 8;

  Directory? rootDirectory;
  Directory? currentDirectory;
  List<Directory?>? directoryList;

  @override
  void initState() {
    super.initState();

    // To make context available when init runs
    Future.delayed(Duration.zero).then(
      (_) => _init(),
    );
  }

  Widget _buildBackNav(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      leading: Icon(Icons.folder, color: theme.primaryColor),
      title: const Text('..'),
      onTap: () => _setDirectory(currentDirectory!.parent),
    );
  }

  List<Widget> _buildDirectories(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (directoryList == null) {
      return [
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
      ];
    } else if (directoryList!.isEmpty) {
      return [
        _buildBackNav(context),
        const Expanded(
          child: Center(
            child: Text('Directory is empty!', textAlign: TextAlign.center),
          ),
        )
      ];
    } else {
      return [
        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              _buildBackNav(context),
              ...directoryList!.map((directory) {
                return ListTile(
                  leading: Icon(Icons.folder, color: theme.colorScheme.secondary),
                  title: Text(
                    _getDirectoryName(directory!),
                  ),
                  onTap: () => _setDirectory(directory),
                );
              })
            ],
          ),
        )
      ];
    }
  }

  Widget _buildHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    var path = (currentDirectory != null)
        ? currentDirectory?.path.replaceAll(FolderPicker.rOOTPATH, "") ?? ''
        : "";

    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: [
                Text('Selected directory', style: theme.textTheme.subtitle2),
                const SizedBox(height: spacing / 2),
                Text(path, style: theme.textTheme.caption)
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
          data!.allowFolderCreation!
              ? Padding(
                  child: IconButton(
                    color: theme.primaryColor,
                    icon: const Icon(Icons.create_new_folder),
                    onPressed: _createNewFolder,
                  ),
                  padding: const EdgeInsets.only(left: spacing / 2),
                )
              : const SizedBox(height: 0, width: 0),
          Padding(
            padding: const EdgeInsets.only(left: spacing / 2),
            child: IconButton(
              color: theme.primaryColor,
              icon: const Icon(Icons.check),
              onPressed: () => Navigator.pop(context, currentDirectory),
            ),
          )
        ],
        mainAxisSize: MainAxisSize.max,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
      padding: const EdgeInsets.all(spacing),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildHeader(context),
        Expanded(
          child: Column(
            children: _buildDirectories(context),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
          ),
        ),
      ],
      mainAxisSize: MainAxisSize.max,
    );
  }

  Future<void> _init() async {
    rootDirectory = data!.rootDirectory;
    _setDirectory(rootDirectory);
  }

  Future<void> _createNewFolder() async {
    final newDirectory = await showDialog<Directory>(
        builder: (_) => _NewFolderDialog(data: data, parent: currentDirectory), context: context);

    if (newDirectory != null) {
      _setDirectory(newDirectory);
    }
  }

  Future<void> _setDirectory(Directory? directory) async {
    setState(() {
      try {
        directoryList = directory!
            .listSync()
            .map<Directory?>(
              (fse) => (fse is Directory ? fse : null),
            )
            .toList()
          ..removeWhere((fse) => fse == null);
        currentDirectory = directory;
      } catch (e) {
        // Ignore when tried navigating to directory that does not exist
        // or to which user does not have permission to read
        debugPrint('$e');
      }
    });
  }

  String _getDirectoryName(Directory directory) {
    return directory.path.split('/').last;
  }

  DirectoryPickerData? get data => DirectoryPickerData.of(context);
}

class _NewFolderDialog extends StatefulWidget {
  final DirectoryPickerData? data;
  final Directory? parent;

  const _NewFolderDialog({this.data, this.parent});

  @override
  _NewFolderDialogState createState() => _NewFolderDialogState();
}

class _NewFolderDialogState extends State<_NewFolderDialog> {
  String? name;
  bool isSubmitting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _createDirectory() async {
    if (name == null || name!.trim() == '') {
      setState(() => errorMessage = 'Enter a valid folder name');
      return;
    }

    try {
      setState(() => isSubmitting = true);
      Directory newDirectory = await Directory(
        path.join(widget.parent!.path, name),
      ).create();
      Navigator.pop(context, newDirectory);
    } catch (e) {
      setState(() => errorMessage = 'Failed to create folder');
    }
    setState(() => isSubmitting = false);
  }

  void _onNameChanged(String value) {
    setState(() {
      name = value;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.data!.backgroundColor,
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(errorText: errorMessage),
        onChanged: _onNameChanged,
      ),
      actions: <Widget>[
        MaterialButton(
          child: const Text('Cancel'),
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
        ),
        MaterialButton(
          child: const Text('Create Folder'),
          onPressed: isSubmitting ? null : _createDirectory,
        )
      ],
      shape: widget.data!.shape,
      title: const Text('Create New Folder'),
    );
  }
}
