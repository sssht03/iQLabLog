import 'package:stacked/stacked.dart';

import '../../service/local_storage.dart';
import '../../service/navigation.dart';
import '../../service_locator.dart';

/// SplashViewModel
class SplashViewModel extends BaseViewModel {
  final _localStorage = servicesLocator<LocalStorageService>();
  final _navigation = servicesLocator<NavigationService>();

  /// initialize
  void initialize() async {
    final name = await _localStorage.getUserName();
    print(name);
    await Future.delayed(Duration(milliseconds: 1200));
    if (name != null) {
      _navigation.pushAndReplace(routeName: '/beacon');
    } else {
      _navigation.pushAndReplace(routeName: '/name_input');
    }
  }
}
