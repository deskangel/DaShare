import 'package:dashare/share_file_op.dart';
import 'package:dashare/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SharingPage extends StatefulWidget {
  SharingPage() : super(key: UniqueKey());

  @override
  _SharingPageState createState() => _SharingPageState();
}

class _SharingPageState extends State<SharingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DaFileShare'),
      ),
      body: buildBodyWidget(),
      persistentFooterButtons: buildPersistentButtons(),
    );
  }

  List<Widget> buildPersistentButtons() {
    if (SharedFileOp.instance.isFileServerRunning()) {
      return [
        Builder(
          builder: (context) => FlatButton.icon(
            icon: Icon(Icons.content_copy),
            label: Text('Copy link'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: SharedFileOp.instance.sharingFileUrl));
              Utils.instance.snackMsg(context, 'The url copied to clipboard');
            },
          ),
        ),
        FlatButton.icon(
          icon: Icon(Icons.stop_screen_share),
          label: Text('Stop sharing'),
          onPressed: () async {
            await SharedFileOp.instance.stopFileServer();
            setState(() {});
          },
        )
      ];
    } else {
      return [
        FlatButton.icon(
          icon: Icon(Icons.queue_play_next),
          label: Text('Start sharing'),
          onPressed: () async {
            await SharedFileOp.instance.startSharingFile();
            setState(() {});
          },
        ),
      ];
    }
  }

  Widget buildBodyWidget() {
    if (SharedFileOp.instance.isFileServerRunning()) {
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
    return Center(
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

  Widget buildSharingWidget(BuildContext context, String _url) {
    return Center(
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: QrImage(
                backgroundColor: Colors.white,
                data: _url,
                size: MediaQuery.of(context).size.width / 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _url,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sharing...',
                    style: TextStyle(fontSize: 36),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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
      ),
    );
  }

  Widget buildReadyWidget(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'File is ready for sharing...',
                  style: TextStyle(fontSize: 30),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Tap "Start sharing" button below to start.',
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
}
