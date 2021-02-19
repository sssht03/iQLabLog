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
      "https://script.google.com/macros/s/AKfycbx3ZRcXarVt7btXFiw8oYpHsr1nYxBlCIH4Ibk50sbrjsdv-Oy8FFaFCg/exec";

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
            var result = convert.jsonDecode(response.body)['status'];
            if (result == 'SUCCESS') {
              _flushbar.showFlushbar('データを記録しました', Colors.blueAccent);
            } else {
              print('302 and error');
              _flushbar.showFlushbar(
                  '送信に失敗しました。もう一度試してください。', Colors.redAccent);
            }
          });
        } else {
          callback(convert.jsonDecode(response.body)['message']);
          _flushbar.showFlushbar('送信に失敗しました。もう一度試してください。', Colors.redAccent);
        }
      });
    } on Exception catch (e) {
      print(e);
    }
  }
}
