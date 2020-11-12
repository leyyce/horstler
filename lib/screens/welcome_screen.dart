import 'dart:async';

import 'package:flutter/material.dart';
import 'package:horstl_wrapper/horstl_wrapper.dart';
import 'package:horstler/screens/splash_screen.dart';
import 'package:horstler/widgets/course_widget.dart';
import 'package:horstler/widgets/dish_showcase.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class WelcomeScreen extends StatefulWidget {
  final String fdNumber;
  final String passWord;

  WelcomeScreen({Key key, this.fdNumber, this.passWord}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState(fdNumber, passWord);
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _fdNumber;
  String _passWord;
  Future<Map> _dataFuture;
  HorstlScrapper _scrapper;
  DateTime _currentTime;
  Timer _dataRefresher;
  Timer _timeRefresher;

  _WelcomeScreenState(this._fdNumber, this._passWord);

  Future<Map> _getDataFromFuture() async {
    var w = _currentTime.weekday < 7
        ? _currentTime.weekOfYear
        : _currentTime.weekOfYear + 1;
    var y = _currentTime.year;
    if (w > 53) {
      w = 1;
      y++;
    }
    var schedule = await _scrapper.getScheduleForWeek(w, y);
    var menu = await _scrapper.getMenu(_currentTime.weekday < 7
        ? _currentTime
        : _currentTime.add(Duration(days: 1)));
    return {'schedule': schedule, 'menu': menu};
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de_DE');
    _scrapper = HorstlScrapper(_fdNumber, _passWord);
    _currentTime = DateTime.now();
    _dataFuture = _getDataFromFuture();
    _dataRefresher = Timer.periodic(Duration(minutes: 5), (Timer t) {
      setState(() {
        _currentTime = DateTime.now();
        _dataFuture = _getDataFromFuture();
      });
    });
    _timeRefresher = Timer.periodic(Duration(seconds: 30), (Timer t) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _dataRefresher.cancel();
    _timeRefresher.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var splashScreen = SplashScreen(
      seconds: 20,
      navigateAfterSeconds: '/loginScreen',
      title: Text('horstler'),
      image: Image(
        image: AssetImage('assets/icons/horstler_icon.png'),
      ),
      photoSize: 50,
      backgroundColor: Colors.white38,
      loaderColor: Colors.green,
      styleTextUnderTheLoader: TextStyle(),
      routeName: '/splashScreen',
    );

    return FutureBuilder(
        future: _dataFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          if (!snapshot.hasData) {
            return splashScreen;
          }

          Schedule schedule = snapshot.data['schedule'];
          Menu menu = snapshot.data['menu'];

          var courseWidgets = <Widget>[];

          for (Day day in schedule.days.values) {
            for (Course course in day.courses()) {
              var d = day.date().split(".").reversed.toList();
              if (int.parse(d[1]) <= 9) {
                d[1] = "0" + d[1];
              }
              if (int.parse(d[2]) <= 9) {
                d[2] = "0" + d[2];
              }
              var startTime = DateTime.parse(d.join("-"));
              var startEnd = course.time().split(' bis ');

              var start = startEnd[0];
              var startHourMin = start.split(':');
              var startHour = int.parse(startHourMin[0]);
              var startMin = int.parse(startHourMin[1]);

              var end = startEnd[1];
              var endHourMin = end.split(':');
              var endHour = int.parse(endHourMin[0]);
              var endMin = int.parse(endHourMin[1]);

              startTime = DateTime(startTime.year, startTime.month,
                  startTime.day, startHour, startMin);
              var endTime = DateTime(startTime.year, startTime.month,
                  startTime.day, endHour, endMin);
              if (courseWidgets.length >= 4) {
                break;
              }
              if (_currentTime.isBefore(endTime)) {
                if (courseWidgets.length == 0) {
                  var preText = 'Dein nächster Kurs startet';
                  var text = 'N/A';
                  if ((startTime.isBefore(_currentTime) ||
                          startTime.isAtSameMomentAs(_currentTime)) &&
                      (endTime.isAfter(_currentTime) ||
                          endTime.isAtSameMomentAs(_currentTime))) {
                    preText = 'Dein nächster Kurs';
                    text = 'Läuft gerade';
                  } else if (startTime.day != _currentTime.day)
                    text = startTime.day - _currentTime.day == 1
                        ? 'Morgen'
                        : 'In ${startTime.difference(_currentTime).abs().inDays} Tagen';
                  else {
                    var difference = startTime.difference(_currentTime).abs();
                    text =
                        'in ${difference.inHours} Std. ${difference.inMinutes - 60 * difference.inHours} Min';
                  }

                  courseWidgets.add(Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 15),
                      child: Text(
                        preText,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ));

                  courseWidgets.add(Align(
                      key: UniqueKey(),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      )));
                } else if (courseWidgets.length == 3) {
                  var difference = startTime.difference(_currentTime).abs();
                  courseWidgets.add(Align(
                    key: UniqueKey(),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                      child: Text(
                        startTime.day == _currentTime.day
                            ? 'in ${difference.inHours} Std. ${difference.inMinutes - 60 * difference.inHours} Min'
                            : (startTime.day - _currentTime.day == 1
                                ? 'Morgen'
                                : 'In ${difference.inDays} Tagen'),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ));
                }
                courseWidgets.add(CourseWidget(
                  course: course,
                ));
              }
            }
            if (courseWidgets.length >= 4) {
              break;
            }
          }

          var widgets = <Widget>[];
          widgets.addAll(courseWidgets);
          widgets.add(Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 25, 0, 10),
                child: Text(
                  'Heute in der Mensa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              )));
          widgets.add(DishShowcase(menu.dishes));
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15, 20, 0, 0),
                  child: Text(
                    'Hallo ${schedule.studentName.split(' ')[0]},',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Align(
                  key: UniqueKey(),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 5, 0, 5),
                    child: Text(
                      'es ist ${DateFormat.EEEE('de_DE').format(_currentTime)}, '
                      'der ${DateFormat.d().format(_currentTime)} '
                      '${DateFormat.MMMM('de_DE').format(_currentTime)} '
                      '${DateFormat.y().format(_currentTime)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )),
              Divider(
                height: 1,
                color: Colors.black,
              ),
              Expanded(
                child: Center(
                    child: ListView.builder(
                  itemCount: widgets.length,
                  padding: EdgeInsets.all(10),
                  itemBuilder: (BuildContext context, int itemIndex) {
                    return widgets[itemIndex];
                  },
                )),
              ),
            ],
          );
        });
  }
}
