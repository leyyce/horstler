import 'package:flutter/material.dart';
import 'package:horstler/screens/home_screen.dart';
import 'package:horstler/screens/login_screen.dart';
import 'package:horstler/screens/menu_screen.dart';
import 'package:horstler/screens/schedule_screen.dart';

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
        '/timeTableScreen': (BuildContext context) => ScheduleScreen(),
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
