import 'dart:io';

import 'package:dashare/settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.grey,
      duration: Duration(seconds: seconds),
      content: Text(message, style: const TextStyle(color: Colors.black)),
      action: action,
    ));
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

  Widget get appTitle {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.fitHeight,
          width: 24,
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        const Text('DaShare'),
      ],
    );
  }

  List<Widget> getAppBarActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.info_outline_rounded),
        onPressed: () async {
          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          var socialContact = [
            IconButton(
              onPressed: () {
                final uri = Uri(
                  scheme: 'mailto',
                  path: 'admin@deskangel.com',
                  query: 'subject=[DASHARE v${packageInfo.version}]',
                );
                launchUrlString(
                  uri.toString(),
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const FaIcon(FontAwesomeIcons.envelope, color: Colors.red),
            ),
            IconButton(
              onPressed: () {
                launchUrlString(
                  'https://twitter.com/ideskangel',
                  mode: LaunchMode.externalApplication,
                );
              },
              icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.blue),
            ),
          ];

          if (context.mounted) {
            showAboutDialog(
              context: context,
              applicationIcon: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.fitHeight,
                width: 32,
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: socialContact,
                ),
              ],
              applicationVersion: 'Version ${packageInfo.version}\nbuild number: ${packageInfo.buildNumber}',
              applicationLegalese: 'Copyright © 2003-${Settings.COPYRIGHT_DATE} DeskAngel',
            );
          }
        },
      ),
    ];
  }
}
