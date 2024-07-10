import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  factory Settings() => _getInstance();
  static Settings get instance => _getInstance();
  static Settings? _instance;

  Settings._internal();

  static Settings _getInstance() {
    _instance ??= Settings._internal();

    return _instance!;
  }

  static const int COPYRIGHT_DATE = 2024;
  static const int DEFAULT_PORT = 30800;

  static const int MAX_SIZE_FOR_QR_CODE = 1024;

  late SharedPreferences prefs;
  Future init({SharedPreferences? prefs}) async {
    this.prefs = prefs ?? await SharedPreferences.getInstance();

    _useRandomPort = this.prefs.getBool('setting.useRandomPort') ?? _useRandomPort;
  }

  bool _useRandomPort = false;
  bool get useRandomPort => _useRandomPort;
  set useRandomPort(bool value) {
    _useRandomPort = value;
    this.prefs.setBool('setting.useRandomPort', value);
  }
}
