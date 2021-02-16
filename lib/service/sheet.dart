import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import '../model/logdata.dart';

/// SheetService
class SheetService {
  /// API URL
  static const String url =
      "https://script.google.com/macros/s/AKfycbzJ6EYxFsd8m41KTrOw9QMUmPZCGn3ZiRLJwbu-s5u6TJIaJyjaI8DO/exec";

  /// status_success
  static const String statusSuccess = "SUCCESS";

  /// submitDataToSheet
  void submitDataToSheet(
      LogData logdata, void Function(String) callback) async {
    print('subimitDataToSheet');
    try {
      await http.post(url, body: logdata.toJson()).then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(url).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } on Exception catch (e) {
      print(e);
    }
  }
}
