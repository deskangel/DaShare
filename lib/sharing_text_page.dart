import 'package:dashare/settings.dart';
import 'package:dashare/share_file_op.dart';
import 'package:dashare/sharing_page.dart';
import 'package:dashare/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SharingTextPage extends StatefulWidget {
  const SharingTextPage({super.key});

  @override
  State<SharingTextPage> createState() => SharingTextPageState();
}

class SharingTextPageState extends State<SharingTextPage> {
  late TextEditingController controller;

  bool qrSharing = false;

  @override
  void initState() {
    super.initState();

    this.controller = TextEditingController(text: SharedFileOp.instance.textContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text'),
      ),
      body: buildBodyWidget(),
      persistentFooterButtons: buildPersistentButtons(),
    );
  }

  List<Widget> buildPersistentButtons() {
    if (this.qrSharing) {
      return [
        TextButton.icon(
          icon: const Icon(Icons.stop_screen_share),
          label: const Text('Stop'),
          onPressed: () {
            setState(() {
              this.qrSharing = false;
            });
          },
        ),
      ];
    }
    return [
      TextButton.icon(
        icon: const Icon(Icons.content_copy),
        label: const Text('Copy'),
        onPressed: () {
          if (this.controller.text.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: this.controller.text));
            Utils.instance.snackMsg(context, 'The content copied to clipboard');
          } else {
            Utils.instance.snackMsg(context, 'No content to copy');
          }
        },
      ),
      TextButton.icon(
        icon: const Icon(Icons.qr_code_2_outlined),
        label: const Text('QR Code'),
        onPressed: () {
          if (this.controller.text.isEmpty) {
            Utils.instance.snackMsg(context, 'No content to share');
            return;
          }

          if (this.controller.text.length >= Settings.MAX_SIZE_FOR_QR_CODE) {
            Utils.instance.snackMsg(
                context,
                '''The text content exceeds ${Settings.MAX_SIZE_FOR_QR_CODE} characters, and QR codes may not be suitable.

Please consider using 'Share' button to share it.''',
                seconds: 8,
                action: SnackBarAction(
                  label: 'Continue',
                  onPressed: () {
                    setState(() {
                      this.qrSharing = true;
                    });
                  },
                ));
          } else {
            setState(() {
              this.qrSharing = true;
            });
          }
        },
      ),
      TextButton.icon(
        icon: const Icon(Icons.share),
        label: const Text('Share'),
        onPressed: () {
          if (this.controller.text.isEmpty) {
            Utils.instance.snackMsg(context, 'No content to share');
            return;
          }

          SharedFileOp.instance.setSharedText(this.controller.text);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SharingPage(
                Utils.instance.appTitle,
                Utils.instance.getAppBarActions(context),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget buildBodyWidget() {
    if (this.qrSharing) {
      return Center(
        child: QrImageView(
          backgroundColor: Colors.white,
          data: this.controller.text,
          size: MediaQuery.of(context).size.width / 2,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: this.controller,
          textAlignVertical: TextAlignVertical.top,
          autofocus: false,
          expands: true,
          maxLines: null,
          minLines: null,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            labelText: 'Content...',
            labelStyle: const TextStyle(fontSize: 13),
            hintText: 'Sharing content...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(style: BorderStyle.solid, width: 0),
            ),
          ),
        ),
      );
    }
  }
}
