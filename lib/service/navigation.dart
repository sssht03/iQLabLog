import 'package:flutter/material.dart';

/// NavigationService
/// Navigator を UI から取り出して、
/// 他の関数の中から使えるようにする
class NavigationService {
  /// Navigator を指定するキー
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // / Scaffold の Statew を取得するキー
  // final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// currentContext
  /// - context を navigatorKey から取得する
  BuildContext get currentContext => navigatorKey.currentContext;

  /// currentState
  // ScaffoldState get currentState => scaffoldKey.currentState;

  /// routeName にページ遷移する (push)
  Future<dynamic> pushNamed({@required String routeName, dynamic args}) =>
      navigatorKey.currentState.pushNamed(routeName, arguments: args);

  /// routeName にページ遷移する (今の route が上書きされる　)
  Future<dynamic> pushAndReplace({@required String routeName, dynamic args}) =>
      navigatorKey.currentState
          .pushReplacementNamed(routeName, arguments: args);

  /// routeName にページを遷移するけど、今までの遷移記録を残さない
  Future<dynamic> pushNamedAndRemoveUntil(
          {@required String routeName, dynamic args}) =>
      navigatorKey.currentState.pushNamedAndRemoveUntil(
          routeName, (route) => false,
          arguments: args);

  /// 一個前の画面に戻る
  void pop() => navigatorKey.currentState.pop();
}
