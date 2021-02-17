import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'service/navigation.dart';
import 'service_locator.dart';
import 'ui/beacon/beacon_view.dart';
import 'ui/name_input/name_input.view.dart';
import 'ui/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // 縦固定
  ]);
  setupServiceLocator();
  runApp(MyApp());
}

/// MyApp
class MyApp extends StatelessWidget {
  final _navigation = servicesLocator<NavigationService>();
  @override
  Widget build(BuildContext context) {
    final appTheme = ThemeData(
      primaryColor: Color(0xff3EC9B5),
      textTheme: GoogleFonts.notoSansTextTheme(Theme.of(context).textTheme)
      // GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)
      ,
    );
    return MaterialApp(
      title: 'iQ Lab Log',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      navigatorKey: _navigation.navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashView(),
        '/name_input': (context) => NameInputView(),
        '/beacon': (context) => BeaconView(),
      },
    );
  }
}
