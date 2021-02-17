import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/logdata.dart';
import '../service_locator.dart';
import 'flushbar.dart';

/// SheetService
class SheetService {
  final _flushbar = servicesLocator<FlushBarService>();

  /// API URL
  static const String url =
      "https://script.google.com/macros/s/AKfycbzJ6EYxFsd8m41KTrOw9QMUmPZCGn3ZiRLJwbu-s5u6TJIaJyjaI8DO/exec";

  /// status_success
  static const String statusSuccess = "SUCCESS";

  /// submitDataToSheet
  void submitDataToSheet(
      LogData logdata, void Function(String) callback) async {
    try {
      await http.post(url, body: logdata.toJson()).then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(url).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
            _flushbar.showFlushbar('データを記録しました', Colors.blueAccent);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
          _flushbar.showFlushbar('送信に失敗しました。もう一度試してください。', Colors.redAccent);
        }
      });
    } on Exception catch (e) {
      print(e);
    }
  }
}
