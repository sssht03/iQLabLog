import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'service_locator.dart';
import 'ui/beacon/beacon_view.dart';

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
  @override
  Widget build(BuildContext context) {
    final appTheme = ThemeData(
      primaryColor: Color(0xff3EC9B5),
      textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
    );
    return MaterialApp(
      title: 'iQ Lab Log',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => BeaconView(),
      },
    );
  }
}
