import 'dart:io';

import 'package:flutter/material.dart';

class Utils {
  factory Utils() => _getInstance();
  static Utils get instance => _getInstance();
  static Utils _instance;

  Utils._internal();

  static Utils _getInstance() {
    if (_instance == null) {
      _instance = Utils._internal();
    }

    return _instance;
  }

  Future<String> retrieveServerIp() async {
    var list = await NetworkInterface.list(type: InternetAddressType.IPv4);
    if (list.length > 0 && list.elementAt(0).addresses.length > 0) {
      return list.elementAt(0).addresses.elementAt(0).address;
    }

    return null;
  }

  void snackMsg(BuildContext context, String message, {int seconds: 1, SnackBarAction action}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.grey,
        duration: Duration(seconds: seconds),
        content: Text(message, style: TextStyle(color: Colors.black),),
        action: action,
      ));
    });
  }
}
