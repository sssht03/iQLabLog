import 'package:location_permissions/location_permissions.dart';

import '../service_locator.dart';
import 'dialog.dart';

/// LocationPermissionService
class LocationPermissionService {
  final _dialog = servicesLocator<DialogService>();

  /// permission
  PermissionStatus get locationPermission => _locationPermission;
  PermissionStatus _locationPermission;

  /// checkLocationAlwaysPermission
  Future<PermissionStatus> checkLocationAlwaysPermission() async {
    _locationPermission = await LocationPermissions()
        .checkPermissionStatus(level: LocationPermissionLevel.locationAlways);
    return _locationPermission;
  }

  /// openSetting
  Future<void> openSetting() async {
    await LocationPermissions().openAppSettings();
  }

  // /// requestLocationAlwaysPermission
  // Future<void> requestLocationAlwaysPermission() async {
  //   var title = '位置情報の許可';
  //   var body = 'アプリがバックグラウンドの状態でもビーコンの検知ができるように, 位置情報を「常に許可」へ変更してください';
  //   _dialog.showAlertDialog(title, body, openSetting());
  // }
}
