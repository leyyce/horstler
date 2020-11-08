import 'package:flutter/material.dart';
import 'package:horstler/screens/homeScreen.dart';
import 'package:horstler/screens/loginScreen.dart';
import 'package:horstler/screens/menuScreen.dart';
import 'package:horstler/screens/timeTableScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'horstler',
      // navigatorKey: navigatorKey,
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => HomeScreen(),
        '/loginScreen': (BuildContext context) => LoginScreen(),
        '/menuScreen': (BuildContext context) => MenuScreen(),
        '/timeTableScreen': (BuildContext context) => TimeTableScreen(),
      },
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Set to false to remove the DEBUG banner
      debugShowCheckedModeBanner: false,
    );
  }
}
