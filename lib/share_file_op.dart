import 'package:dashare/utils.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SharedFileOp {
  factory SharedFileOp() => _getInstance();
  static SharedFileOp get instance => _getInstance();
  static SharedFileOp _instance;

  SharedFileOp._internal();

  static SharedFileOp _getInstance() {
    if (_instance == null) {
      _instance = SharedFileOp._internal();
    }

    return _instance;
  }

  static const _platform = const MethodChannel('com.deskangel.dashare/fileserver');

  bool _bSharing = false;

  String _url;
  String _fileSize;
  String _fileName;

  String selectedIp = '';
  List<String> ipAddresses = [''];

  bool isFileServerRunning() {
    return _bSharing;
  }

  String get sharingFileUrl {
    return _url;
  }

  String get sharingFileSize {
    return _fileSize ?? '-1';
  }

  String get sharingFileName {
    return _fileName ?? 'unkonwn';
  }

  Future<Map<String, String>> retrieveFileInfo() async {
    var fileInfo = Map<String, String>();
    try {
      var result = await _platform.invokeMethod('retrieveFileInfo');
      fileInfo['fileName'] = result['fileName'];
      fileInfo['fileSize'] = filesize(result['fileSize']);

      _fileName = fileInfo["fileName"];
      _fileSize = fileInfo["fileSize"];

      return fileInfo;
    } on PlatformException catch (e) {
      debugPrint(e.message);
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

  Future<String> _startFileServer(String fileName) async {
    try {
      var port = await _platform.invokeMethod('startFileService', {"fileName": fileName});
      _bSharing = true;
      return port.toString();
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
  Future<String> startSharingFile() async {
    if (SharedFileOp.instance.isFileServerRunning()) {
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

    // var ips = await Utils.instance.retrieveServerIps();
    // if (ips.isEmpty) {
    //   debugPrint('Failed to retrieve ip');
    //   return null;
    // }

    var port = await _startFileServer(_fileName);
    if (null == port) {
      debugPrint('Failed to start file server!');
      return null;
    }

    _url = 'http://$selectedIp:$port/$_fileName';

    return _url;
  }
}
