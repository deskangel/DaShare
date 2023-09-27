import 'package:dashare/settings.dart';
import 'package:dashare/share_file_op.dart';
import 'package:dashare/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SharingPage extends StatefulWidget {
  const SharingPage(this.appTitle, this.appBarActions, {super.key});

  final Widget appTitle;
  final List<Widget> appBarActions;

  @override
  SharingPageState createState() => SharingPageState();
}

class SharingPageState extends State<SharingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: this.widget.appTitle,
        actions: this.widget.appBarActions,
      ),
      body: buildBodyWidget(),
      persistentFooterButtons: buildPersistentButtons(),
    );
  }

  List<Widget> buildPersistentButtons() {
    if (SharedFileOp.instance.isServerRunning()) {
      return [
        Builder(
          builder: (context) {
            return TextButton.icon(
              icon: const Icon(Icons.content_copy),
              label: const Text('Copy link'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: SharedFileOp.instance.sharingFileUrl ?? ''));
                Utils.instance.snackMsg(context, 'The url copied to clipboard');
              },
            );
          },
        ),
        TextButton.icon(
          icon: const Icon(Icons.stop_screen_share),
          label: const Text('Stop sharing'),
          onPressed: () async {
            await SharedFileOp.instance.stopFileServer();
            setState(() {});
          },
        )
      ];
    } else {
      return [
        TextButton.icon(
          icon: const Icon(Icons.queue_play_next),
          label: const Text('Start sharing'),
          onPressed: () async {
            await SharedFileOp.instance.startSharingFile();
            setState(() {});
          },
        ),
      ];
    }
  }

  Widget buildBodyWidget() {
    if (SharedFileOp.instance.isServerRunning()) {
      var sharingUrl = SharedFileOp.instance.sharingFileUrl;
      if (null == sharingUrl) {
        return buildFailedWidget();
      } else {
        return buildSharingWidget(context, sharingUrl);
      }
    } else {
      return buildReadyWidget(context);
    }
  }

  Widget buildFailedWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sorry... 😥',
            style: TextStyle(fontSize: 30),
          ),
          Text(
            'Failed to start server for the file.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildSharingWidget(BuildContext context, String url) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: QrImageView(
              backgroundColor: Colors.white,
              data: url,
              size: MediaQuery.of(context).size.width / 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              url,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sharing...',
                  style: TextStyle(fontSize: 36),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Please keep this app in front while sharing.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(SharedFileOp.instance.sharingFileName),
              trailing: Text(SharedFileOp.instance.sharingFileSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReadyWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'File name:\n',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: SharedFileOp.instance.sharingFileName,
                    style: TextStyle(color: Colors.amber[900]),
                  ),
                ],
              ),
            ),
            trailing: Text(
              SharedFileOp.instance.sharingFileSize,
              style: TextStyle(
                color: SharedFileOp.instance.error == null ? null : Colors.red,
              ),
            ),
          ),
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'File is ready for sharing...',
              style: TextStyle(fontSize: 30),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tap "Start sharing" button below to start.',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                visualDensity: VisualDensity.compact,
                title: const Text('Ip address: '),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton(
                      value: SharedFileOp.instance.selectedIp,
                      items: SharedFileOp.instance.ipAddresses
                          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          SharedFileOp.instance.selectedIp = value ?? '';
                        });
                      }),
                ),
              ),
              const ListTile(
                visualDensity: VisualDensity.compact,
                title: Text('Port: '),
                trailing: Text('${Settings.DEFAULT_PORT}'),
              ),
              SwitchListTile(
                visualDensity: VisualDensity.compact,
                value: Settings.instance.useRandomPort,
                onChanged: (value) {
                  setState(() {
                    Settings.instance.useRandomPort = value;
                  });
                },
                title: const Text('Use random port'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
