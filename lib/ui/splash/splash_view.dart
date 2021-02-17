import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'splash_viewmodel.dart';

/// SplashView
class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SplashViewModel>.reactive(
      builder: (context, model, child) => Scaffold(body: _SplashScreen()),
      viewModelBuilder: () => SplashViewModel(),
      onModelReady: (model) => model.initialize(),
    );
  }
}

class _SplashScreen extends ViewModelWidget<SplashViewModel> {
  @override
  Widget build(BuildContext context, SplashViewModel model) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Center(
          child: Text(
        'iQ Lab Log',
        style: TextStyle(
            color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 36.0),
      )),
    );
  }
}
