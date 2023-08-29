import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class NoSharingPage extends StatefulWidget {
  const NoSharingPage(this.appTitle, this.appBarActions, {super.key});

  final Widget appTitle;
  final List<Widget> appBarActions;

  @override
  State<NoSharingPage> createState() => _NoSharingPageState();
}

class _NoSharingPageState extends State<NoSharingPage> {
  bool scan = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: this.widget.appTitle,
        actions: this.widget.appBarActions,
      ),
      body: scan? MobileScanner(
        // fit: BoxFit.contain,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
          for (final barcode in barcodes) {
            debugPrint('Barcode found! ${barcode.rawValue}');
          }
        },
      ):  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'No sharing file found!',
            style: TextStyle(fontSize: 30),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'You should select and share a file in other App to DaFileShare.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
      persistentFooterButtons: buildPersistentButtons(),
    );
  }

  List<Widget> buildPersistentButtons() {
    return [
      TextButton.icon(
        icon: const Icon(Icons.queue_play_next),
        label: const Text('Scane'),
        onPressed: () async {
          setState(() {
            scan = true;
          });
        },
      ),
    ];
  }
}
