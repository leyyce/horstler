import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:horstler/screens/loginScreen.dart';
import 'package:horstler/screens/menuScreen.dart';
import 'package:horstler/screens/timeTableScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';

class DrawerItem {
  final String title;
  final IconData icon;
  final Color mainColor;
  DrawerItem(this.title, this.icon, this.mainColor);
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  final drawerItems = [
    DrawerItem('Stundenplan', Icons.calendar_today, Colors.green),
    DrawerItem('Mensa', Icons.fastfood, Colors.red),
  ];

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos, fdNumber, passWord) {
    switch (pos) {
      case 0:
        return TimeTableScreen(
          fdNumber: fdNumber,
          passWord: passWord,
        );
      case 1:
        return MenuScreen(fdNumber: fdNumber, passWord: passWord,); // mensaPage;
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(BuildContext context, int index) {
    setState(() => _selectedDrawerIndex = index);
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
      future: _checkForLogin(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }
        if (!snapshot.hasData) {
          return SplashScreen(
            seconds: 1000,
            title: Text('horstler'),
            image: Image(
              image: AssetImage('assets/icons/horstler_icon.png'),
            ),
            photoSize: 50,
            backgroundColor: Colors.white,
            loaderColor: Colors.green,
            styleTextUnderTheLoader: TextStyle(),
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
            drawerOptions.add(
                new ListTile(
                  leading: Icon(d.icon),
                  title: Text(
                      d.title,
                  ),
                  selected: i == _selectedDrawerIndex,
                  onTap: () => _onSelectItem(context, i),
                )
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.drawerItems[_selectedDrawerIndex].title),
              backgroundColor: widget.drawerItems[_selectedDrawerIndex].mainColor,
              // bottom: widget.drawerItems[_selectedDrawerIndex].title != 'Timetable' ? null : TabBar(),
              actions: <Widget>[
                IconButton(
                  icon: new Icon(Icons.exit_to_app),
                  tooltip: 'Logout',
                  onPressed: () {
                    _saveLogin('', '');
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => LoginScreen()
                    ));
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
                      leading: Icon(Icons.person),
                      title: Text(
                        loginInfo[0],
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: widget.drawerItems[_selectedDrawerIndex].mainColor,
                    ),
                  ),
                  Column(
                    children: drawerOptions,
                  ),
                ],
              ),
            ),
            body: _getDrawerItemWidget(_selectedDrawerIndex, loginInfo[0], loginInfo[1]),
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
