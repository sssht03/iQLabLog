import 'package:flutter/material.dart';

import '../service_locator.dart';
import 'navigation.dart';

/// SizeService
class SizeService {
  final _navigation = servicesLocator<NavigationService>();

  /// get screen size
  Size get screenSize => MediaQuery.of(_navigation.currentContext).size;
}
