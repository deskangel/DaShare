import 'dart:math';

import 'package:dashare/settings.dart';
import 'package:dashare/utils.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

class SharedFileOp {
  factory SharedFileOp() => _getInstance();
  static SharedFileOp get instance => _getInstance();
  static SharedFileOp? _instance;

  SharedFileOp._internal();

  static SharedFileOp _getInstance() {
    _instance ??= SharedFileOp._internal();

    return _instance!;
  }

  static const _platform = MethodChannel('com.deskangel.dashare/sharingserver');

  bool _bSharing = false;

  String? _url;
  String? _fileSize;
  String? _fileName;

  String? _error;

  String selectedIp = '';
  List<String> ipAddresses = [''];

  int port = 0;

  bool isServerRunning() {
    return _bSharing;
  }

  String? get error {
    return _error;
  }

  String? get sharingFileUrl {
    return _url;
  }

  String get sharingFileSize {
    return _fileSize ?? '-1';
  }

  String get sharingFileName {
    return _fileName ?? 'unkonwn';
  }

  String? _textContent;
  String? get textContent {
    return _textContent;
  }

  void setSharedText(String text) {
    _textContent = text;
  }

  Future<String?> getSharedText() async {
    try {
      _textContent = await _platform.invokeMethod('getSharedText');
      return _textContent;
    } on PlatformException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  Future<String?> getSharedFileUriScheme() async {
    try {
      var result = await _platform.invokeMethod('getSharedFileUriScheme');
      if (result == 'file') {
        await Utils.instance.requestStoragePermission();
      }
      return result;
    } on PlatformException catch (e) {
      debugPrint(e.message);
      return null;
    }
  }

  Future<Map<String, String>?> retrieveFileInfo() async {
    var fileInfo = <String, String>{};
    try {
      var result = await _platform.invokeMethod('retrieveFileInfo');
      fileInfo['fileName'] = result['fileName'];

      var size = result['fileSize'];
      fileInfo['fileSize'] = (size == -1) ? '-1' : filesize(result['fileSize']);

      _fileName = fileInfo["fileName"];
      _fileSize = fileInfo["fileSize"];
      _error = result['code'];

      return fileInfo;
    } on PlatformException catch (e) {
      debugPrint(e.message);
      if (e.code == '1') {
        return null;
      } else if (e.code == '2') {
        _error = e.message;
        return {'code': e.message ?? 'Cannot find the sharing file'};
      } else if (e.code == '3') {
        _error = e.message;
        return {'code': e.message ?? 'Failed to retrieve the sharing file information'};
      }
    }
    return null;
  }

  Future stopFileServer() async {
    if (!_bSharing) {
      return;
    }

    try {
      await _platform.invokeMethod('stopFileService');
      _bSharing = false;
    } on PlatformException catch (e) {
      debugPrint(e.message);
    }
  }

  ///
  /// return host:port
  Future<String?> _startFileServer(
    String shortName, {
    String? fileName,
    String? host,
    int port = 0,
  }) async {
    if (_bSharing) {
      debugPrint('Server is already running!');
      return null;
    }

    try {
      var hostPort = await _platform.invokeMethod('startFileService', {
        'shortName': shortName,
        'fileName': fileName,
        'host': host,
        'port': port,
      });
      _bSharing = true;
      return hostPort.toString();
    } on PlatformException catch (e) {
      debugPrint('Failed to start file server: ${e.message}');
    }

    return null;
  }

  Future<String?> _startTextServer(
    String shortName, {
    required String sharedText,
    String? host,
    int port = 0,
  }) async {
    if (_bSharing) {
      debugPrint('Server is already running!');
      return null;
    }

    try {
      var hostPort = await _platform.invokeMethod('startTextService', {
        'shortName': shortName,
        'sharedText': sharedText,
        'host': host,
        'port': port,
      });
      _bSharing = true;
      return hostPort.toString();
    } on PlatformException catch (e) {
      debugPrint('Failed to start file server: ${e.message}');
    }

    return null;
  }

  Future<List<String>> getIpAddresses() async {
    if (selectedIp.isEmpty) {
      ipAddresses = await Utils.instance.retrieveServerIps();
      if (ipAddresses.isNotEmpty) {
        selectedIp = ipAddresses[0];
      }
    }
    return ipAddresses;
  }

  ///
  /// @return the url for sharing
  ///
  Future<String?> startSharingFile() async {
    if (SharedFileOp.instance.isServerRunning()) {
      debugPrint('file server is running');
      return _url;
    }

    if (null == _fileName) {
      var fileInfo = await SharedFileOp.instance.retrieveFileInfo();
      if (null == fileInfo) {
        debugPrint('Failed to retrieve the file info. Sharing does not support!');

        return null;
      }
    }

    if (selectedIp.isEmpty) {
      return null;
    }

    if (Settings.instance.useRandomPort) {
      port = 0;
    } else {
      port = Settings.DEFAULT_PORT;
    }

    List<int> rands = [];
    for (var i = 0; i < 6; i++) {
      rands.add(Random.secure().nextInt(10));
    }

    var fileId = rands.join() + p.extension(_fileName!);
    var hostPort = await _startFileServer(fileId, fileName: _fileName, host: this.selectedIp, port: this.port);
    if (null == hostPort) {
      debugPrint('Failed to start file server!');
      return null;
    }

    _url = 'http://$hostPort/$fileId';

    return _url;
  }

  ///
  /// @return the url for sharing
  ///
  Future<String?> startSharingText() async {
    if (SharedFileOp.instance.isServerRunning()) {
      debugPrint('text server is running');
      return _url;
    }

    var text = SharedFileOp.instance.textContent;
    if (null == text) {
      debugPrint('No shared text found!');

      return null;
    }

    if (selectedIp.isEmpty) {
      return null;
    }

    if (Settings.instance.useRandomPort) {
      port = 0;
    } else {
      port = Settings.DEFAULT_PORT;
    }

    List<int> rands = [];
    for (var i = 0; i < 4; i++) {
      rands.add(Random.secure().nextInt(10));
    }

    var fileId = '${rands.join()}.html';
    var hostPort = await _startTextServer(fileId, sharedText: text, host: this.selectedIp, port: this.port);
    if (null == hostPort) {
      debugPrint('Failed to start text server!');
      return null;
    }

    _url = 'http://$hostPort/$fileId';

    return _url;
  }
}
