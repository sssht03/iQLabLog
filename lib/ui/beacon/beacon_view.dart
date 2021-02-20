import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:stacked/stacked.dart';

import 'beacon_viewmodel.dart';

/// BeaconView
class BeaconView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<BeaconViewModel>.reactive(
      builder: (context, model, child) => Scaffold(body: _BeaconScreen()),
      viewModelBuilder: () => BeaconViewModel(),
      onModelReady: (model) => {model.initialize()},
    );
  }
}

class _BeaconScreen extends ViewModelWidget<BeaconViewModel> {
  @override
  Widget build(BuildContext context, BeaconViewModel model) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'iQ Lab Log',
            style: TextStyle(color: Color(0xff434A56)),
          ),
          centerTitle: false,
          actions: <Widget>[
            if (!model.authorizationStatusOk)
              IconButton(
                  icon: Icon(Icons.portable_wifi_off),
                  color: Colors.red,
                  onPressed: () async {
                    model.requestAuthorization();
                  }),
            if (!model.locationServiceEnabled)
              IconButton(
                  icon: Icon(Icons.location_off),
                  color: Colors.red,
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      await flutterBeacon.openLocationSettings;
                    } else if (Platform.isIOS) {}
                  }),
            StreamBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final state = snapshot.data;

                  if (state == BluetoothState.stateOn) {
                    return IconButton(
                      icon: Icon(Icons.bluetooth_connected),
                      onPressed: () {},
                      color: Colors.blue,
                    );
                  } else if (state == BluetoothState.stateOff) {
                    return IconButton(
                      icon: Icon(
                        Icons.bluetooth,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        if (Platform.isAndroid) {
                          try {
                            await flutterBeacon.openBluetoothSettings;
                          } on PlatformException catch (e) {
                            print(e);
                          }
                        } else if (Platform.isIOS) {}
                      },
                      color: Colors.red,
                    );
                  } else {
                    return IconButton(
                      icon: Icon(Icons.bluetooth_disabled),
                      onPressed: () {},
                      color: Colors.grey,
                    );
                  }
                }

                return SizedBox.shrink();
              },
              stream: model.streamController.stream,
              initialData: BluetoothState.stateUnknown,
            ),
          ],
        ),
        body: model.sending
            ? SpinKitPulse(
                color: Theme.of(context).primaryColor,
                size: 150,
              )
            : Container(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 36.0),
                      _HelloText(),
                      SizedBox(height: 20.0),
                      _BeaconText(),
                      if (model.room != null) _RecordButton(),
                      SizedBox(height: 28.0),
                      if (!model.scanning) _ScanButton(),
                      SizedBox(height: 28.0),
                      if (model.scanning) _CancelButton(),
                      if (model.scanning) SizedBox(height: 28.0),
                      if (!model.scanning) _ReNameButton(),
                      SizedBox(height: 28.0),
                      if (model.scanning && model.onTap)
                        CircularProgressIndicator()
                    ],
                  ),
                )));
  }
}

/// _HelloText
class _HelloText extends ViewModelWidget<BeaconViewModel> {
  @override
  Widget build(BuildContext context, BeaconViewModel model) {
    return Center(
      child: Text('Hello ${model.name}!',
          style: TextStyle(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87)),
    );
  }
}

/// BeaconText
class _BeaconText extends ViewModelWidget<BeaconViewModel> {
  @override
  Widget build(BuildContext context, BeaconViewModel model) {
    return Column(children: [
      SizedBox(height: 8.0),
      (model.room == null)
          ? Text(
              'Beacon \nNot Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
            )
          : Column(
              children: [
                Text(
                  'room',
                  style: TextStyle(fontSize: 24.0, color: Colors.black54),
                ),
                Text(
                  model.room,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 56.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
      SizedBox(height: 20.0),
    ]);
  }
}

/// _ScanButton
class _ScanButton extends ViewModelWidget<BeaconViewModel> {
  @override
  Widget build(BuildContext context, BeaconViewModel model) {
    return Container(
        width: 150,
        height: 50,
        child: RaisedButton(
          elevation: 5,
          shape: StadiumBorder(),
          child: Text(
            'スキャンする',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          color: Theme.of(context).primaryColor,
          onPressed: () => {model.initScanBeacon(), model.onTap = true},
        ));
  }
}

/// _RecordButton
class _RecordButton extends ViewModelWidget<BeaconViewModel> {
  @override
  Widget build(BuildContext context, BeaconViewModel model) {
    return Container(
        width: 150,
        height: 50,
        child: RaisedButton(
          elevation: 5,
          shape: StadiumBorder(),
          child: Text(
            '記録送信',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          color: Theme.of(context).primaryColor,
          onPressed: () async {
            await model.submitData();
          },
        ));
  }
}

/// _CancelButton
class _CancelButton extends ViewModelWidget<BeaconViewModel> {
  @override
  Widget build(BuildContext context, BeaconViewModel model) {
    return Container(
        width: 150,
        height: 50,
        child: RaisedButton(
          elevation: 5,
          shape: StadiumBorder(),
          child: Text(
            'スキャンをやめる',
            style:
                TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            await model.pauseScanBeacon();
            model.scanning = false;
            model.onTap = false;
          },
        ));
  }
}

class _ReNameButton extends ViewModelWidget<BeaconViewModel> {
  @override
  Widget build(BuildContext context, BeaconViewModel model) {
    return Container(
        width: 150,
        height: 50,
        child: RaisedButton(
          elevation: 5,
          shape: StadiumBorder(),
          child: Text(
            '名前を変更する',
            style:
                TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            model.rename();
          },
        ));
  }
}
