import 'package:dashare/no_sharing_page.dart';
import 'package:dashare/share_file_op.dart';
import 'package:dashare/sharing_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DaFileShare());
}

class DaFileShare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DaFileShare',
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
              return CircularProgressIndicator();
            case ConnectionState.done:
              if (snapshot.data) {
                return SharingPage();
              } else {
                return NoSharingPage();
              }
          }
          return Container();
        },
      ),
    );
  }

  Future<bool> _hasSharingFileReady() async {
    await SharedFileOp.instance.getIpAddresses();
    var fileInfo = await SharedFileOp.instance.retrieveFileInfo();
    return (fileInfo != null);
  }
}


