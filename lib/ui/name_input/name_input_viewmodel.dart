import 'package:stacked/stacked.dart';

import '../../service/dialog.dart';
import '../../service/navigation.dart';
import '../../service_locator.dart';

/// NameInputViewModel
class NameInputViewModel extends BaseViewModel {
  final _navigation = servicesLocator<NavigationService>();
  final _dialog = servicesLocator<DialogService>();

  /// transitionToBeaconView
  void transitionToBeaconView() {
    _navigation.pushNamedAndRemoveUntil(routeName: '/beacon');
  }

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
    _dialog.showAlertDialog(
        '確認: $text', '変更できないよ\n機能作るのサボりました', transitionToBeaconView);
  }
}
