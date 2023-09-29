import 'package:dashare/no_sharing_page.dart';
import 'package:dashare/share_file_op.dart';
import 'package:dashare/sharing_page.dart';
import 'package:dashare/utils.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _hasSharingFileReady(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasData && snapshot.data!) {
              return SharingPage(Utils.instance.appTitle, Utils.instance.getAppBarActions(context));
            } else {
              return NoSharingPage(Utils.instance.appTitle, Utils.instance.getAppBarActions(context));
            }
        }
      },
    );
  }


  Future<bool> _hasSharingFileReady() async {
    await SharedFileOp.instance.getIpAddresses();

    if (await SharedFileOp.instance.getSharedText() != null) {
      return true;
    }

    if (await SharedFileOp.instance.getSharedFileUriScheme() == null) {
      return false;
    }

    var fileInfo = await SharedFileOp.instance.retrieveFileInfo();
    return (fileInfo != null);
  }
}
