import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:stacked/stacked.dart';

import '../../service/local_notification.dart';
import '../../service/realtime_database.dart';
import '../../service_locator.dart';

/// BeaconViewModel
class BeaconViewModel extends BaseViewModel
    with
        // ignore: prefer_mixin
        WidgetsBindingObserver {
  final _localNotification = servicesLocator<LocalNotificationService>();
  final _rdb = servicesLocator<RDBService>();

  /// streamController
  final StreamController streamController = StreamController();
  StreamSubscription<BluetoothState> _streamBluetooth;
  StreamSubscription<RangingResult> _streamRanging;

  final _regionBeacons = <Region, List<Beacon>>{};

  /// beacons
  List<Beacon> get beacons => _beacons;
  final _beacons = <Beacon>[];

  /// authorizationStatusOk
  bool get authorizationStatusOk => _authorizationStatusOk;
  bool _authorizationStatusOk = false;

  /// locationServiceEnabled
  bool get locationServiceEnabled => _locationServiceEnabled;
  bool _locationServiceEnabled = false;

  /// bluetoothEnabled
  bool get bluetoothEnabled => _bluetoothEnabled;
  bool _bluetoothEnabled = false;

  /// scanning
  bool get scanning => _scanning;
  set scanning(bool e) {
    _scanning = e;
    notifyListeners();
  }

  bool _scanning = false;

  /// onTap
  bool get onTap => _onTap;
  set onTap(bool e) {
    _onTap = e;
    notifyListeners();
  }

  bool _onTap = false;

  /// text
  String get username => _username;
  String _username = '';

  /// userData
  dynamic get userData => _userData;
  var _userData;

  /// handleText
  void handleText(String e) {
    _username = e;
    notifyListeners();
  }

  /// upDateLogData
  void upDateLogData(String username) => _rdb.upDateLogData(username);

  /// initialize
  void initialize() async {
    print('initialize');
    _localNotification.initLocalNotification();
    WidgetsBinding.instance.addObserver(this);
    _userData = await _rdb.getUserData();
    print(_userData);
    notifyListeners();
  }

  /// lister
  Future<void> listeningState() async {
    _streamBluetooth =
        flutterBeacon.bluetoothStateChanged().listen((state) async {
      streamController.add(state);

      if (state == BluetoothState.stateOn) {
        initScanBeacon();
      } else if (state == BluetoothState.stateOff) {
        await pauseScanBeacon();
        await checkAllRequirements();
      }
    });
  }

  /// checkAllRequirements
  Future<void> checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    final bluetoothEnabled = bluetoothState == BluetoothState.stateOn;
    final authorizationStatus = await flutterBeacon.authorizationStatus;
    final authorizationStatusOk =
        authorizationStatus == AuthorizationStatus.whenInUse ||
            authorizationStatus == AuthorizationStatus.always;
    final locationServiceEnabled =
        await flutterBeacon.checkLocationServicesIfEnabled;

    _authorizationStatusOk = authorizationStatusOk;
    _locationServiceEnabled = locationServiceEnabled;
    _bluetoothEnabled = bluetoothEnabled;
    notifyListeners();
  }

  /// requestAuthorization
  Future<void> requestAuthorization() async {
    await flutterBeacon.requestAuthorization;
  }

  /// initScanBeacon
  void initScanBeacon() async {
    _scanning = true;
    await checkAllRequirements();

    if (!_authorizationStatusOk ||
        !_locationServiceEnabled ||
        !_bluetoothEnabled) {
      print('RETURNED, authorizationStatusOk=$_authorizationStatusOk, '
          'locationServiceEnabled=$_locationServiceEnabled, '
          'bluetoothEnabled=$_bluetoothEnabled');
      return;
    }

    final regions = <Region>[
      Region(
        identifier: '''Shuta's iPad''',
        proximityUUID: '48534442-4C45-4144-80C0-1800FFFFFFFF',
      ),
    ];

    if (_streamRanging != null) {
      if (_streamRanging.isPaused) {
        _streamRanging.resume();
        return;
      }
    }

    _streamRanging = flutterBeacon.ranging(regions).listen((result) async {
      if (result != null) {
        _regionBeacons[result.region] = result.beacons;
        _beacons.clear();
        _regionBeacons.values.forEach(_beacons.addAll);
        _beacons.sort(_compareParameters);
        print(result);
        for (var i = 0; i < _beacons.length; i++) {
          var uuid = _beacons[i].proximityUUID;
          if (regions[0].proximityUUID.contains(uuid) &&
              _beacons[i].proximity == Proximity.immediate &&
              _beacons[i].accuracy < 0.15) {
            await pauseScanBeacon();
            _streamRanging = null;
            await _localNotification.showNotification('iQ Lab', '入退室を検知しました！');
            _scanning = false;
          }
        }
        notifyListeners();
      }
    });
  }

  /// pauseScanBeacon
  void pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      print('clear');
      _beacons.clear();
      notifyListeners();
    }
  }

  int _compareParameters(Beacon a, Beacon b) {
    var compare = a.proximityUUID.compareTo(b.proximityUUID);
    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }
    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }
    return compare;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null && _streamBluetooth.isPaused) {
        _streamBluetooth.resume();
      }
      await checkAllRequirements();
      if (_authorizationStatusOk &&
          _locationServiceEnabled &&
          _bluetoothEnabled) {
        await initScanBeacon();
      } else {
        await pauseScanBeacon();
        await checkAllRequirements();
      }
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamController?.close();
    _streamRanging?.cancel();
    _streamBluetooth?.cancel();
    flutterBeacon.close;

    super.dispose();
  }
}
