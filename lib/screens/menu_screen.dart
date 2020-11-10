import 'package:flutter/material.dart';

import 'package:horstl_wrapper/horstl_wrapper.dart';
import 'package:horstler/widgets/dish_widget.dart';
import 'package:horstler/screens/splash_screen.dart';

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
      var menu = await HorstlScrapper(fdNumber, passWord).getMenu(day);
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

    _menuFuture = _getMenuFromFuture(_fdNumber, _passWord, _requestedMonday);
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
      seconds: 20,
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
          menuList = snapshot.data ?? []; // ?? timeTable
          var menuWidgets = <Widget>[];
          for (var menu in menuList) {
            var dishWidgets = <Widget>[];
            for (var dish in menu.dishes) {
              dishWidgets.add(DishWidget(
                dish: dish,
              ));
            }
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
            ][_requestedDay.weekday - 1]],
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
