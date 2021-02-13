import 'package:get_it/get_it.dart';

import 'service/local_notification.dart';
import 'service/navigation.dart';

/// servicesLocator
GetIt servicesLocator = GetIt.instance;

/// setupServiceLocator
/// - register instance (single) of every services
/// that are going to be used in the app
///
void setupServiceLocator() {
  servicesLocator.registerLazySingleton(() => LocalNotificationService());
  servicesLocator.registerLazySingleton(() => NavigationService());
}
