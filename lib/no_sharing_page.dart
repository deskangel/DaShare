import 'package:dashare/sharing_text_page.dart';
import 'package:dashare/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NoSharingPage extends StatefulWidget {
  const NoSharingPage(this.appTitle, this.appBarActions, {super.key});

  final Widget appTitle;
  final List<Widget> appBarActions;

  @override
  State<NoSharingPage> createState() => _NoSharingPageState();
}

class _NoSharingPageState extends State<NoSharingPage> {
  bool scan = false;

  String? content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: this.widget.appTitle,
        actions: this.widget.appBarActions,
      ),
      body: scan
          ? LayoutBuilder(builder: (context, constraints) {
              var qrWindowWidth = constraints.biggest.width * 0.7;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Please scan the QR code',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: qrWindowWidth,
                      height: qrWindowWidth,
                      child: MobileScanner(
                        // fit: BoxFit.contain,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          // final Uint8List? image = capture.image;
                          for (final barcode in barcodes) {
                            this.content = barcode.rawValue;
                            break;
                          }
                          setState(() {
                            scan = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            })
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: this.content == null
                  ? [
                      const Text(
                        'No sharing file found!',
                        style: TextStyle(fontSize: 30),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'You should select and share a file in other App to DaFileShare.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Or scan a QR code to get the shared url.',
                          style: TextStyle(fontSize: 30),
                          // softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]
                  : [
                      Center(child: Text(this.content!)),
                    ],
            ),
      persistentFooterButtons: buildPersistentButtons(),
    );
  }

  List<Widget> buildPersistentButtons() {
    if (scan) {
      return [
        TextButton.icon(
          icon: const Icon(Icons.keyboard_return_outlined),
          label: const Text('Return'),
          onPressed: () async {
            setState(() {
              scan = false;
            });
          },
        ),
      ];
    } else {
      var btnScan = TextButton.icon(
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Scane'),
        onPressed: () async {
          setState(() {
            scan = true;
          });
        },
      );

      if (this.content != null) {
        return [
          TextButton.icon(
            icon: const Icon(Icons.content_copy),
            label: const Text('Copy link'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: this.content!));
              Utils.instance.snackMsg(context, 'The url copied to clipboard');
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.open_in_browser_outlined),
            label: const Text('Open'),
            onPressed: () {
              launchUrlString(this.content!, mode: LaunchMode.externalApplication);
            },
          ),
          btnScan,
        ];
      }
      return [
        TextButton.icon(
          icon: const Icon(Icons.text_snippet_outlined),
          label: const Text('Text'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SharingTextPage(),
              ),
            );
          }
        ),
        btnScan,
      ];
    }
  }
}
