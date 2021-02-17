import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:stacked/stacked.dart';

import '../../model/logdata.dart';
import '../../service/local_notification.dart';
import '../../service/local_storage.dart';
import '../../service/sheet.dart';
import '../../service_locator.dart';

/// BeaconViewModel
class BeaconViewModel extends BaseViewModel
    with
        // ignore: prefer_mixin
        WidgetsBindingObserver {
  final _localNotification = servicesLocator<LocalNotificationService>();
  final _sheet = servicesLocator<SheetService>();
  final _localStorage = servicesLocator<LocalStorageService>();

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

  /// name
  String get name => _name;
  String _name;

  /// initialize
  void initialize() async {
    print('initialize');
    listeningState();
    _localNotification.initLocalNotification();
    WidgetsBinding.instance.addObserver(this);
    _name = await _localStorage.getUserName();
    notifyListeners();
  }

  /// lister
  Future<void> listeningState() async {
    _beacons.clear();
    notifyListeners();
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
    final regions = <Region>[
      Region(
        identifier: '''Shuta's iPad''',
        proximityUUID: '48534442-4C45-4144-80C0-1800FFFFFFFF',
      ),
      Region(
        identifier: '''ibeacon201''',
        proximityUUID: '5F7A409F-3D68-451E-A116-601D68E6D92D',
      ),
    ];

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
        notifyListeners();
        print(result);
        var _roomId;
        var uuid = _beacons[0].proximityUUID;
        if (regions[0].proximityUUID.contains(uuid) &&
            _beacons[0].proximity == Proximity.immediate &&
            _beacons[0].accuracy < 0.15) {
          _roomId = 0;
        } else if (regions[1].proximityUUID.contains(uuid) &&
            _beacons[0].proximity == Proximity.immediate) {
          _roomId = 1;
        }
        if (_roomId == 0 || _roomId == 1) {
          await pauseScanBeacon();
          await processAfterScanning(_roomId);
        }
      }
    });
  }

  /// processAfterScanning
  Future<void> processAfterScanning(num roomId) async {
    _streamRanging = null;
    submitData(roomId);
    await _localNotification.showNotification('iQ Lab', '入退室を検知しました！');
    _scanning = false;
    notifyListeners();
  }

  /// pauseScanBeacon
  Future<void> pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
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

  /// submitData
  void submitData(num roomId) async {
    var room;
    if (roomId == 0) {
      room = '202';
    } else {
      room = '201';
    }
    final _logdata = LogData(
        name: '$name', room: '$room', timestamp: DateTime.now().toString());
    await _sheet.submitDataToSheet(_logdata, print);
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
