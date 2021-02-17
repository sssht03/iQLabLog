import 'package:shared_preferences/shared_preferences.dart';

/// LocalStorageService
class LocalStorageService {
  // SharedPreferences _prefs;

  /// nameKey
  final nameKey = 'name';

  // /// constructor
  // LocalStorageService() {
  //   SharedPreferences.getInstance().then((instance) => _prefs = instance);
  // }

  /// storeUserName
  Future<void> storeUserName(String name) async {
    final _prefs = await SharedPreferences.getInstance();
    await _prefs?.setString('$nameKey', name);
  }

  /// getUserName
  Future<String> getUserName() async {
    final _prefs = await SharedPreferences.getInstance();
    var name = _prefs?.getString('$nameKey');
    print('local name: $name');
    return name;
  }
}
