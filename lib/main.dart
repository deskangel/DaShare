import 'dart:async';

import 'package:dashare/no_sharing_page.dart';
import 'package:dashare/settings.dart';
import 'package:dashare/share_file_op.dart';
import 'package:dashare/sharing_page.dart';
import 'package:flutter/material.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Settings.instance.init();

  runApp(const DaFileShare());
}

class DaFileShare extends StatelessWidget {
  const DaFileShare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DaShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: _hasSharingFileReady(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasData && snapshot.data!) {
                return SharingPage();
              } else {
                return const NoSharingPage();
              }
          }
        },
      ),
    );
  }

  Future<bool> _hasSharingFileReady() async {
    await SharedFileOp.instance.getIpAddresses();

    if (await SharedFileOp.instance.getSharedFileUriScheme() == null) {
      return false;
    }

    var fileInfo = await SharedFileOp.instance.retrieveFileInfo();
    return (fileInfo != null);
  }
}
