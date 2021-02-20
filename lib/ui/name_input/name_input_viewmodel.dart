import 'package:flutter/material.dart';
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

  /// showNullDialog
  void showNullDialog() async {
    await _dialog.showAlertDialog('NULL ERROR', '名前を入力してください', _navigation.pop);
  }

  /// showCheckDialog
  void showCheckDialig() async {
    await _dialog.showAlertDialog(
        '確認: $text', '以上の名前で登録します。\n新規に登録、名前を変更する場合は松尾まで連絡ください。', () async {
      await _lcoalStorage.storeUserName(text);
      _navigation.pushNamedAndRemoveUntil(routeName: '/beacon');
    });
  }

  /// fixName
  void fixName() async {
    if (text == null) {
      await showNullDialog();
    } else {
      await showCheckDialig();
    }
  }
}
