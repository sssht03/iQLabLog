import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:iQLabLog/service_locator.dart';

import 'navigation.dart';
import 'size.dart';

/// FlushBarService
class FlushBarService {
  final _size = servicesLocator<SizeService>();
  final _navigation = servicesLocator<NavigationService>();

  /// showFlushbar
  void showFlushbar(String message, Color color) {
    final flushBarMaxWidth = _size.screenSize.width * 0.8;
    final flushBarMargin = EdgeInsets.all(8);
    final flushBarBorderRadius = 8.0;
    final flushBarDuration = Duration(seconds: 3);
    Flushbar(
      message: message,
      backgroundColor: color,
      maxWidth: flushBarMaxWidth,
      margin: flushBarMargin,
      borderRadius: flushBarBorderRadius,
      duration: flushBarDuration,
    )..show(_navigation.currentContext);
  }
}
