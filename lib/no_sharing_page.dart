import 'package:dashare/settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';


import 'package:url_launcher/url_launcher_string.dart';

class NoSharingPage extends StatelessWidget {
  const NoSharingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DaFileShare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              var packageInfo = await PackageInfo.fromPlatform();
              var socialContact = [
                IconButton(
                  onPressed: () {
                    final uri = Uri(
                      scheme: 'mailto',
                      path: 'admin@deskangel.com',
                      query: 'subject=[DASHARE]',
                    );
                    launchUrlString(uri.toString());
                  },
                  icon: const FaIcon(FontAwesomeIcons.solidEnvelope, color: Colors.green),
                ),
                IconButton(
                  onPressed: () {
                    launchUrlString('https://twitter.com/ideskangel');
                  },
                  icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.blue),
                ),
              ];

              showAboutDialog(
                context: context,
                applicationIcon: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.fitHeight,
                  width: 32,
                ),
                applicationVersion: 'Version ${packageInfo.version}\nbuild number: ${packageInfo.buildNumber}',
                applicationLegalese: 'Copyright © 2003-${Settings.COPYRIGHT_DATE} DeskAngel',
                children: socialContact,
              );
            },
          ),
        ],
      ),
      body: Column(
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
    );
  }
}
