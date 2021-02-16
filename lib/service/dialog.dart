import 'package:flutter/material.dart';
import '../service_locator.dart';

import 'navigation.dart';

/// DialigService
class DialogService {
  final _navigation = servicesLocator<NavigationService>();

  /// ShowAlertDialog
  void showAlertDialog(String title, String body, Function okAction) {
    showDialog(
      context: _navigation.currentContext,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () => Navigator.pop(_navigation.currentContext),
            ),
            FlatButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: okAction,
            ),
          ],
        );
      },
    );
  }
}
