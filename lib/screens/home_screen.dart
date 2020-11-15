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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:horstler/screens/login_screen.dart';
import 'package:horstler/screens/menu_screen.dart';
import 'package:horstler/screens/schedule_screen.dart';
import 'package:horstler/screens/splash_screen.dart';
import 'package:horstler/screens/welcome_screen.dart';
import 'package:retry/retry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerItem {
  final String title;
  final IconData icon;
  final Color mainColor;
  DrawerItem(this.title, this.icon, this.mainColor);
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  final drawerItems = [
    DrawerItem('Home', Icons.home, Colors.green),
    DrawerItem('Kursplan', Icons.calendar_today, Colors.green),
    DrawerItem('Mensa', Icons.fastfood, Colors.red),
  ];

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos, fdNumber, passWord) {
    switch (pos) {
      case 0:
        return WelcomeScreen(
          fdNumber: fdNumber,
          passWord: passWord,
          parentState: this,
        );
      case 1:
        return ScheduleScreen(
          fdNumber: fdNumber,
          passWord: passWord,
        );
      case 2:
        return MenuScreen(
          fdNumber: fdNumber,
          passWord: passWord,
        ); // mensaPage;
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(BuildContext context, int index) {
    setState(() => selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  /*
  @override
  void initState() {
    super.initState();
  }
   */

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: retry(() => _checkForLogin().timeout(Duration(seconds: 5))),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }
        if (!snapshot.hasData) {
          return SplashScreen(
            seconds: 51,
            navigateAfterSeconds: '/loginScreen',
            title: Text('horstler'),
            image: Image(
              image: AssetImage('assets/icons/horstler_icon.png'),
            ),
            photoSize: 50,
            backgroundColor: Colors.white,
            loaderColor: Colors.green,
            styleTextUnderTheLoader: TextStyle(),
            routeName: '/splashScreen',
          );
        }

        /*
        var loginInfo = snapshot.data;
        if (loginInfo[0] != '' || loginInfo[1] != '') {
          return TimeTableScreen(
            fdNumber: loginInfo[0],
            passWord: loginInfo[1],
          );
        }
        */

        var loginInfo = snapshot.data ?? ['', ''];
        if (loginInfo[0] != '' || loginInfo[1] != '') {
          var drawerOptions = <Widget>[];
          for (var i = 0; i < widget.drawerItems.length; i++) {
            var d = widget.drawerItems[i];
            drawerOptions.add(new ListTile(
              leading: Icon(d.icon),
              title: Text(
                d.title,
              ),
              selected: i == selectedDrawerIndex,
              onTap: () => _onSelectItem(context, i),
            ));
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.drawerItems[selectedDrawerIndex].title),
              backgroundColor:
                  widget.drawerItems[selectedDrawerIndex].mainColor,
              // bottom: widget.drawerItems[_selectedDrawerIndex].title != 'Timetable' ? null : TabBar(),
              actions: <Widget>[
                IconButton(
                  icon: new Icon(Icons.exit_to_app),
                  tooltip: 'Logout',
                  onPressed: () {
                    _saveLogin('', '');
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      title: Text(
                        loginInfo[0],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.6), BlendMode.darken),
                        image: AssetImage(selectedDrawerIndex != 2
                            ? 'assets/images/hs_fulda.jpg'
                            : 'assets/images/mensa.jpg'),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Column(
                    children: drawerOptions,
                  ),
                ],
              ),
            ),
            body: _getDrawerItemWidget(
                selectedDrawerIndex, loginInfo[0], loginInfo[1]),
          );
        }
        return LoginScreen();
      },
    );
  }
}

Future<List<String>> _checkForLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final fdNumber = prefs.getString('horst_fdNumber') ?? '';
  final passWord = prefs.getString('horst_phrase') ?? '';
  return [fdNumber, passWord];
}

_saveLogin(String fdNumber, String passWord) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('horst_fdNumber', fdNumber);
  prefs.setString('horst_phrase', passWord);
}
