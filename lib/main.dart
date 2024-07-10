import 'package:dashare/home.dart';
import 'package:dashare/settings.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.instance.init();

  runApp(const DaFileShare());
}

class DaFileShare extends StatelessWidget {
  const DaFileShare({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DaShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Home(),
    );
  }
}
