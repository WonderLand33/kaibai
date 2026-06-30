import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
