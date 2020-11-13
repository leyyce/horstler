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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:horstl_wrapper/horstl_wrapper.dart';
import 'package:horstler/screens/home_screen.dart';
import 'package:horstler/screens/splash_screen.dart';
import 'package:horstler/widgets/course_widget.dart';
import 'package:horstler/widgets/dish_showcase.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:retry/retry.dart';

class WelcomeScreen extends StatefulWidget {
  final String fdNumber;
  final String passWord;
  final HomeScreenState parentState;

  WelcomeScreen({Key key, this.fdNumber, this.passWord, this.parentState})
      : super(key: key);

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
    var scheduleCurrent = await _scrapper.getScheduleForWeek(
        _currentTime.weekOfYear, _currentTime.year);
    var w = _currentTime.weekOfYear + 1;
    var y = _currentTime.year;
    if (w > 53) {
      w = 1;
      y++;
    }
    var scheduleNext = await _scrapper.getScheduleForWeek(w, y);
    var menu = await _scrapper.getMenu(_currentTime.weekday < 7
        ? _currentTime
        : _currentTime.add(Duration(days: 1)));
    return {
      'schedule': {'current': scheduleCurrent, 'next': scheduleNext},
      'menu': menu
    };
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de_DE');
    _scrapper = HorstlScrapper(_fdNumber, _passWord);
    _currentTime = DateTime.now();
    _dataFuture =
        retry(() => _getDataFromFuture().timeout(Duration(seconds: 5)));
    _dataRefresher = Timer.periodic(Duration(minutes: 5), (Timer t) {
      setState(() {
        _currentTime = DateTime.now();
        _dataFuture =
            retry(() => _getDataFromFuture().timeout(Duration(seconds: 5)));
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
      seconds: 51,
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

          Schedule currentSchedule = snapshot.data['schedule']['current'];
          Schedule nextSchedule = snapshot.data['schedule']['next'];
          Menu menu = snapshot.data['menu'];

          var courseWidgets = <Widget>[];
          _getNextCourses(currentSchedule, courseWidgets);
          if (_countCoursesInList(courseWidgets) <= 1) {
            _getNextCourses(nextSchedule, courseWidgets);
          }

          var widgets = <Widget>[];
          if (courseWidgets.length != 0) {
            widgets.addAll(courseWidgets);
          } else {
            widgets.add(InkWell(
              onTap: () {
                widget.parentState.setState(() {
                  widget.parentState.selectedDrawerIndex = 1;
                });
              },
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15, 10, 0, 15),
                  child: Text(
                    'Das war\'s fürs erste',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 21,
                    ),
                  ),
                ),
              ),
            ));
            widgets.add(
              InkWell(
                onTap: () {
                  widget.parentState.setState(() {
                    widget.parentState.selectedDrawerIndex = 1;
                  });
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Card(
                    color: Color.fromRGBO(18, 124, 47, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(25, 35, 25, 35),
                      child: Text(
                        'Keine ausstehenden Kurse in dieser oder der nächsten Woche.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
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
          widgets.add(
            InkWell(
                onTap: () {
                  widget.parentState.setState(() {
                    widget.parentState.selectedDrawerIndex = 2;
                  });
                },
                child: DishShowcase(menu.dishes)),
          );
          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15, 20, 0, 0),
                  child: Text(
                    'Hallo ${currentSchedule.studentName.split(' ')[0]},',
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

  void _getNextCourses(Schedule schedule, List<Widget> targetList) {
    var firstCourseIsOnNextDay = false;
    var targetLength = 4;
    var targetDayTwo = 3;

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

        startTime = DateTime(startTime.year, startTime.month, startTime.day,
            startHour, startMin);
        var endTime = DateTime(
            startTime.year, startTime.month, startTime.day, endHour, endMin);
        var difference = startTime.difference(_currentTime).abs();

        if (targetList.length >= targetLength) {
          break;
        }
        if (_currentTime.isBefore(endTime)) {
          if (targetList.length == 0) {
            var preText = 'Dein nächster Kurs startet';
            var text = 'N/A';
            if ((startTime.isBefore(_currentTime) ||
                    startTime.isAtSameMomentAs(_currentTime)) &&
                (endTime.isAfter(_currentTime) ||
                    endTime.isAtSameMomentAs(_currentTime))) {
              preText = 'Dein nächster Kurs';
              text = 'läuft gerade';
            } else if (startTime.day !=
                _currentTime.day) if (startTime.day - _currentTime.day == 1) {
              firstCourseIsOnNextDay = true;
              text = 'morgen';
            } else {
              text = 'in ${difference.inDays} Tagen';
            }
            else {
              var difference = startTime.difference(_currentTime).abs();
              text =
                  'in ${difference.inHours} Std. ${difference.inMinutes - 60 * difference.inHours} Min';
            }

            targetList.add(InkWell(
              onTap: () {
                widget.parentState.setState(() {
                  widget.parentState.selectedDrawerIndex = 1;
                });
              },
              child: Align(
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
              ),
            ));

            targetList.add(InkWell(
              onTap: () {
                widget.parentState.setState(() {
                  widget.parentState.selectedDrawerIndex = 1;
                });
              },
              child: Align(
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
                ),
              ),
            ));
            if (difference.inHours != 0 &&
                startTime.day - _currentTime.day != 1) {
              targetLength++;
              targetDayTwo++;
              targetList.add(InkWell(
                onTap: () {
                  widget.parentState.setState(() {
                    widget.parentState.selectedDrawerIndex = 1;
                  });
                },
                child: Align(
                  key: UniqueKey(),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      '${difference.inHours - difference.inDays * 24} Stunden',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ));
            }
          } else if (targetList.length == targetDayTwo) {
            var difference = startTime.difference(_currentTime).abs();
            targetList.add(InkWell(
              onTap: () {
                widget.parentState.setState(() {
                  widget.parentState.selectedDrawerIndex = 1;
                });
              },
              child: Align(
                key: UniqueKey(),
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                  child: Text(
                    startTime.day == _currentTime.day
                        ? 'in ${difference.inHours} Std. ${difference.inMinutes - 60 * difference.inHours} Min'
                        : (startTime.day - _currentTime.day == 1
                            ? (firstCourseIsOnNextDay ? 'danach' : 'morgen')
                            : 'in ${difference.inDays} Tagen'),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ));

            if (startTime.day != _currentTime.day &&
                startTime.day - _currentTime.day != 1) {
              targetLength++;
              targetList.add(InkWell(
                onTap: () {
                  widget.parentState.setState(() {
                    widget.parentState.selectedDrawerIndex = 1;
                  });
                },
                child: Align(
                  key: UniqueKey(),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Text(
                      '${difference.inHours - difference.inDays * 24} Stunden',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ));
            }
          }
          targetList.add(InkWell(
            onTap: () {
              widget.parentState.setState(() {
                widget.parentState.selectedDrawerIndex = 1;
              });
            },
            child: CourseWidget(
              course: course,
            ),
          ));
        }
      }
      if (targetList.length >= targetLength) {
        break;
      }
    }
  }

  static int _countCoursesInList(List<Widget> courseList) {
    var courseCount = 0;
    courseList.forEach((element) {
      if (element is CourseWidget) courseCount++;
    });
    return courseCount;
  }
}
