import 'package:flutter/material.dart';
import '../service_locator.dart';

import 'navigation.dart';

/// DialigService
class DialogService {
  final _navigation = servicesLocator<NavigationService>();

  /// ShowAlertDialog
  Future<void> showAlertDialog(
      String title, String body, Function okAction) async {
    await showDialog(
      context: _navigation.currentContext,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: okAction,
            ),
          ],
        );
      },
    );
  }
}
