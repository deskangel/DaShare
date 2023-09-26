import 'package:dashare/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SharingTextPage extends StatefulWidget {
  const SharingTextPage({super.key});

  @override
  State<SharingTextPage> createState() => SharingTextPageState();
}

class SharingTextPageState extends State<SharingTextPage> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    this.controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Text'),
        ),
        body: TextField(
          controller: this.controller,
          textAlignVertical: TextAlignVertical.top,
          autofocus: false,
          maxLines: 3,
          maxLength: 120,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            labelText: 'Content...',
            labelStyle: const TextStyle(fontSize: 13),
            hintText: 'Sharing content...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(style: BorderStyle.solid, width: 0),
            ),
          ),
        ),
        persistentFooterButtons: [
          TextButton.icon(
            icon: const Icon(Icons.content_copy),
            label: const Text('Copy'),
            onPressed: () {
              if (this.controller.text.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: this.controller.text));
                Utils.instance.snackMsg(context, 'The content copied to clipboard');
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.qr_code_2_outlined),
            label: const Text('QR Code'),
            onPressed: () {},
          ),
          TextButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            onPressed: () {
              // share via temp file
            },
          ),
        ]);
  }
}
