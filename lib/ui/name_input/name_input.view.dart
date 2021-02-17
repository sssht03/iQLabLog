import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'name_input_viewmodel.dart';

/// NameInoutView
class NameInputView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NameInputViewModel>.reactive(
        builder: (context, model, child) => Scaffold(
            body: model.isBusy
                ? CircularProgressIndicator()
                : _NameInputScreen()),
        viewModelBuilder: () => NameInputViewModel());
  }
}

class _NameInputScreen extends ViewModelWidget<NameInputViewModel> {
  @override
  Widget build(BuildContext context, NameInputViewModel model) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '名前を入力してね\n(誰かわかれば何でもいい)',
            style: TextStyle(color: Colors.black45, fontSize: 20.0),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 20.0,
          ),
          _TextInput(),
          SizedBox(
            height: 36.0,
          ),
          _Okbutton()
        ],
      ),
    );
  }
}

/// _TextInput
class _TextInput extends ViewModelWidget<NameInputViewModel> {
  @override
  Widget build(BuildContext context, NameInputViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 56.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: '名前',
          labelStyle: TextStyle(color: Color(0xFFB5B5B5)),
          // border: OutlineInputBorder(),
        ),
        onChanged: model.handleText,
      ),
    );
  }
}

class _Okbutton extends ViewModelWidget<NameInputViewModel> {
  @override
  Widget build(BuildContext context, NameInputViewModel model) {
    return Container(
        width: 150,
        height: 50,
        child: RaisedButton(
          elevation: 5,
          shape: StadiumBorder(),
          child: Text(
            'OK',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          color: Theme.of(context).primaryColor,
          onPressed: () => {model.showCheckDialog()},
        ));
  }
}
