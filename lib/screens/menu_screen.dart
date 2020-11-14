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

import 'package:horstl_wrapper/horstl_wrapper.dart';
import 'package:horstler/widgets/dish_widget.dart';
import 'package:horstler/screens/splash_screen.dart';
import 'package:retry/retry.dart';

class MenuScreen extends StatefulWidget {
  final String fdNumber;
  final String passWord;

  MenuScreen({Key key, this.fdNumber, this.passWord}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState(fdNumber, passWord);
}

class _MenuScreenState extends State {
  String _fdNumber;
  String _passWord;
  DateTime _requestedDay;
  DateTime _requestedMonday;
  Future<List<Menu>> _menuFuture;

  _MenuScreenState(this._fdNumber, this._passWord);

  Future<List<Menu>> _getMenuFromFuture(
      String fdNumber, String passWord, DateTime currentDay) async {
    var menuWeek = <Menu>[];
    var day = currentDay;
    for (int i = 0; i < 6; i++) {
      var menu = await HorstlScrapper(fdNumber, passWord)
          .getMenu(day)
          .timeout(Duration(seconds: 5));
      menuWeek.add(menu);
      day = day.add(Duration(days: 1));
    }
    return menuWeek;
  }

  @override
  void initState() {
    super.initState();

    _requestedDay = DateTime.now();
    if (_requestedDay.weekday == DateTime.sunday)
      _requestedDay = _requestedDay.add(Duration(days: 1));
    _requestedMonday = _getCurrentMonday(_requestedDay);

    _menuFuture =
        retry(() => _getMenuFromFuture(_fdNumber, _passWord, _requestedMonday));
  }

  @override
  Widget build(BuildContext context) {
    var dayMapping = {
      'mon': 0,
      'tue': 1,
      'wed': 2,
      'thu': 3,
      'fri': 4,
      'sat': 5,
      'sun': 0,
    };

    var splashScreen = SplashScreen(
      seconds: 51,
      navigateAfterSeconds: '/loginScreen',
      title: Text('horstler'),
      image: Image(
        image: AssetImage('assets/icons/horstler_icon_red.png'),
      ),
      photoSize: 50,
      backgroundColor: Colors.white38,
      loaderColor: Colors.red,
      styleTextUnderTheLoader: TextStyle(),
      routeName: '/splashScreen',
    );

    return new FutureBuilder(
        future: _menuFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return splashScreen;
          }
          if (!snapshot.hasData) {
            return splashScreen;
          }

          var menuList;
          menuList = snapshot.data ?? [];
          var menuWidgets = <Widget>[];
          for (var menu in menuList) {
            var dishWidgets = <Widget>[];
            for (var dish in menu.dishes) {
              dishWidgets.add(DishWidget(
                dish: dish,
              ));
            }
            if (dishWidgets.isEmpty)
              dishWidgets.add(Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.redAccent,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.6), BlendMode.darken),
                        image: AssetImage('assets/images/mensa.jpg'),
                        fit: BoxFit.fill,
                        alignment: Alignment.center,
                      )),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(25, 75, 25, 75),
                    child: Text(
                      'Heute ist die Mensa geschlossen.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ));
            menuWidgets.add(
              Center(
                  child: ListView(
                padding: EdgeInsets.all(10),
                children: dishWidgets,
              )),
            );
          }

          FloatingActionButton floatingActionButton;
          var currentWeek = DateTime.now().weekOfYear;

          if (_requestedDay.weekOfYear == currentWeek) {
            floatingActionButton = FloatingActionButton(
              backgroundColor: Colors.red,
              heroTag: null,
              onPressed: () {
                setState(() {
                  _requestedDay = _requestedDay.add(Duration(days: 7));
                  _requestedMonday = _getCurrentMonday(_requestedDay);
                  _menuFuture = _getMenuFromFuture(
                      _fdNumber, _passWord, _requestedMonday);
                });
              },
              child: Icon(Icons.arrow_forward),
            );
          } else {
            floatingActionButton = FloatingActionButton(
              backgroundColor: Colors.red,
              heroTag: null,
              onPressed: () {
                setState(
                  () {
                    _requestedDay = _requestedDay.subtract(Duration(days: 7));
                    _requestedMonday = _getCurrentMonday(_requestedDay);
                    _menuFuture = _getMenuFromFuture(
                        _fdNumber, _passWord, _requestedMonday);
                  },
                );
              },
              child: Icon(Icons.arrow_back),
            );
          }

          return DefaultTabController(
            initialIndex: dayMapping[<String>[
              'mon',
              'tue',
              'wed',
              'thu',
              'fri',
              'sat',
              'sun',
            ][_requestedDay.weekday != 7 &&
                    DateTime.now().weekOfYear == _requestedMonday.weekOfYear &&
                    DateTime.now().year == _requestedMonday.year
                ? _requestedDay.weekday - 1
                : 0]],
            length: 6,
            child: Scaffold(
              backgroundColor: Colors.white38,
              appBar: AppBar(
                backgroundColor: Colors.red,
                flexibleSpace: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TabBar(
                      indicatorColor: Colors.red,
                      tabs: <Widget>[
                        Tab(
                            text: 'Mo.\n'
                                '${_requestedMonday.day}.${_requestedMonday.month}'),
                        Tab(
                            text: 'Di.\n'
                                '${_requestedMonday.add(Duration(days: 1)).day}.${_requestedMonday.add(Duration(days: 1)).month}'),
                        Tab(
                            text: 'Mi.\n'
                                '${_requestedMonday.add(Duration(days: 2)).day}.${_requestedMonday.add(Duration(days: 2)).month}'),
                        Tab(
                            text: 'Do.\n'
                                '${_requestedMonday.add(Duration(days: 3)).day}.${_requestedMonday.add(Duration(days: 3)).month}'),
                        Tab(
                            text: 'Fr.\n'
                                '${_requestedMonday.add(Duration(days: 4)).day}.${_requestedMonday.add(Duration(days: 4)).month}'),
                        Tab(
                            text: 'Sa.\n'
                                '${_requestedMonday.add(Duration(days: 5)).day}.${_requestedMonday.add(Duration(days: 5)).month}'),
                      ],
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: menuWidgets,
              ),
              floatingActionButton: floatingActionButton,
            ),
          );
        });
  }

  static DateTime _getCurrentMonday(DateTime currentDay) {
    while (currentDay.weekday != DateTime.monday) {
      currentDay = currentDay.subtract(new Duration(days: 1));
    }

    return currentDay;
  }
}
