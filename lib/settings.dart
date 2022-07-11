class Settings {
  factory Settings() => _getInstance();
  static Settings get instance => _getInstance();
  static Settings? _instance;

  Settings._internal();

  static Settings _getInstance() {
    _instance ??= Settings._internal();

    return _instance!;
  }

  static const int COPYRIGHT_DATE = 2022;

}
