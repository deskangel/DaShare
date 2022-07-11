import 'package:flutter/material.dart';

class NoSharingPage extends StatelessWidget {
  const NoSharingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DaFileShare'),
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
