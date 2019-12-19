import 'package:flutter/material.dart';
import 'package:horstler/screens/homeScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'horstler',
      navigatorKey: navigatorKey,
      home: HomeScreen(),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Set to false to remove the DEBUG banner
      debugShowCheckedModeBanner: false,
    );
  }
}