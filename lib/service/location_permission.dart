import 'package:location_permissions/location_permissions.dart';

/// LocationPermissionService
class LocationPermissionService {
  /// permission
  PermissionStatus get locationPermission => _locationPermission;
  PermissionStatus _locationPermission;

  /// checkPermission
  void checkPermission() async {
    _locationPermission = await LocationPermissions().checkPermissionStatus();
  }

  /// openSetting
  void openSetting() async {
    await LocationPermissions().openAppSettings();
  }
}
