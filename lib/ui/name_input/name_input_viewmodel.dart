import 'package:stacked/stacked.dart';

import '../../service/dialog.dart';
import '../../service/local_storage.dart';
import '../../service/navigation.dart';
import '../../service_locator.dart';

/// NameInputViewModel
class NameInputViewModel extends BaseViewModel {
  final _navigation = servicesLocator<NavigationService>();
  final _dialog = servicesLocator<DialogService>();
  final _lcoalStorage = servicesLocator<LocalStorageService>();

  /// text
  String get text => _text;
  String _text;

  /// handleText
  void handleText(String e) {
    _text = e;
    notifyListeners();
  }

  /// showCheckDialog
  void showCheckDialog() async {
    await _dialog.showAlertDialog('確認: $text', '変更できないよ\n機能作るのサボりました',
        () async {
      print(text);
      await _lcoalStorage.storeUserName(text);
      _navigation.pushNamedAndRemoveUntil(routeName: '/beacon');
    });
  }

  /// fixName
  void fixName() {
    _navigation.pushNamedAndRemoveUntil(routeName: '/beacon');
  }
}
