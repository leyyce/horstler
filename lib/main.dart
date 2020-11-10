// horstler - Student helper app for the Fulda University of Applied Sciences.
//
// Copyright (C) 2020  Yannic Wehner
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see https://www.gnu.org/licenses/.

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
