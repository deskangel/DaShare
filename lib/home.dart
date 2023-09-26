import 'package:dashare/no_sharing_page.dart';
import 'package:dashare/settings.dart';
import 'package:dashare/share_file_op.dart';
import 'package:dashare/sharing_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
              return SharingPage(this.appTitle, this.getAppBarActions(context));
            } else {
              return NoSharingPage(this.appTitle, this.getAppBarActions(context));
            }
        }
      },
    );
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
