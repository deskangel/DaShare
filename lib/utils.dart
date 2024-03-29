import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  factory Utils() => _getInstance();
  static Utils get instance => _getInstance();
  static Utils? _instance;

  Utils._internal();

  static Utils _getInstance() {
    _instance ??= Utils._internal();

    return _instance!;
  }

  Future<List<String>> retrieveServerIps() async {
    List<String> ips = [];
    var list = await NetworkInterface.list(type: InternetAddressType.IPv4);

    for (NetworkInterface interface in list) {
      for (var ip in interface.addresses) {
        ips.add(ip.address);
      }
    }

    return ips;
  }

  void snackMsg(BuildContext context, String message, {int seconds = 1, SnackBarAction? action}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.grey,
        duration: Duration(seconds: seconds),
        content: Text(message, style: const TextStyle(color: Colors.black)),
        action: action,
      ));
    });
  }

    Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isPermanentlyDenied) {
      return false;
    }

    if (!status.isGranted) {
      status = await Permission.storage.request();
      return (status == PermissionStatus.granted);
    } else {
      return true;
    }
  }
}
