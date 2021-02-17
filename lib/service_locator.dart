import 'package:get_it/get_it.dart';
import 'package:iQLabLog/service/flushbar.dart';

import 'service/dialog.dart';
import 'service/local_notification.dart';
import 'service/local_storage.dart';
import 'service/location_permission.dart';
import 'service/navigation.dart';
import 'service/sheet.dart';
import 'service/size.dart';

/// servicesLocator
GetIt servicesLocator = GetIt.instance;

/// setupServiceLocator
/// - register instance (single) of every services
/// that are going to be used in the app
///
void setupServiceLocator() {
  servicesLocator.registerLazySingleton(() => LocalNotificationService());
  servicesLocator.registerLazySingleton(() => NavigationService());
  servicesLocator.registerLazySingleton(() => LocationPermissionService());
  servicesLocator.registerLazySingleton(() => DialogService());
  servicesLocator.registerLazySingleton(() => SheetService());
  servicesLocator.registerLazySingleton(() => LocalStorageService());
  servicesLocator.registerLazySingleton(() => SizeService());
  servicesLocator.registerLazySingleton(() => FlushBarService());
}
