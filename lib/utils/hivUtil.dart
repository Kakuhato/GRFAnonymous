import 'package:hive_flutter/adapters.dart';

class HiveUtil {
  static HiveUtil? _instance;

  HiveUtil._();

  static HiveUtil instance() {
    return _instance ??= HiveUtil._();
  }

  late Box _box;
  static const String _boxName = "usr";
  static const String tokenKey = "token";

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  Future<void> setString(String key, String value) async {
    await _box.put(key, value);
  }

  String getString(String key, {String defaultValue = ""}) {
    return _box.get(key, defaultValue: defaultValue) ?? defaultValue;
  }
}
