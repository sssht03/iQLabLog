import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
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
                      color: Colors.lightBlueAccent,
                    );
                  } else if (state == BluetoothState.stateOff) {
                    return IconButton(
                      icon: Icon(Icons.bluetooth),
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
        body: Container(
            padding: EdgeInsets.all(16.0),
            child: model.scanning && model.onTap
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 36.0),
                        _CancelButton()
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ScanButton(),
                        SizedBox(height: 36.0),
                        // RaisedButton(
                        //     child: Text('submit'),
                        //     onPressed: () async {
                        //       await model.submitData();
                        //     }),
                      ],
                    ),
                  )));
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          // color: Theme.of(context).primaryColor,
          onPressed: () async {
            await model.pauseScanBeacon();
            model.scanning = false;
            model.onTap = false;
          },
        ));
  }
}
