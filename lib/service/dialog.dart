import 'package:flutter/material.dart';
import '../service_locator.dart';

import 'navigation.dart';

/// DialigService
class DialogService {
  final _navigation = servicesLocator<NavigationService>();

  /// ShowAlertDialog
  void showAlertDialog(String title, String body, dynamic okAction) {
    showDialog(
      context: _navigation.currentContext,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(_navigation.currentContext),
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () => {okAction},
            ),
          ],
        );
      },
    );
  }
}
