import 'package:flutter/material.dart';

import 'package:horstl_wrapper/horstl_wrapper.dart';
import 'package:horstler/widgets/course_widget.dart';
import 'package:intl/intl.dart';
import 'package:splashscreen/splashscreen.dart';

class ScheduleScreen extends StatefulWidget {
  final String fdNumber;
  final String passWord;

  ScheduleScreen({Key key, this.fdNumber, this.passWord}) : super(key: key);

  @override
  _ScheduleScreenState createState() =>
      _ScheduleScreenState(fdNumber, passWord);
}

class _ScheduleScreenState extends State {
  final String _fdNumber;
  final String _passWord;
  Future<Schedule> _scheduleFuture;
  int _requestedWeek = DateTime.now().weekOfYear;
  int _requestedYear = DateTime.now().year;

  _ScheduleScreenState(this._fdNumber, this._passWord);

  Future<Schedule> _getDataFromFuture(
      String fdNumber, String passWord, int calendarWeek, int year) async {
    return HorstlScrapper(fdNumber, passWord)
        .getScheduleForWeek(calendarWeek, year);
  }

  @override
  void initState() {
    if (DateTime.now().weekday == 6) _increaseWeekOfYear();
    _scheduleFuture = _getDataFromFuture(
        _fdNumber, _passWord, _requestedWeek, _requestedYear);
    super.initState();
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

    var currentDay = DateTime.now();
    var currentDayName = DateFormat('E').format(currentDay).toLowerCase();

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

    return new FutureBuilder(
        future: _scheduleFuture,
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

          var schedule;
          schedule = snapshot.data ?? Schedule('N/A', 'N/A'); // ?? Schedule
          var dayWidgets = <Widget>[];
          for (var day in schedule.days.values) {
            var courseWidgets = <Widget>[];
            if (day.courses().isEmpty) {
              courseWidgets.add(Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Color.fromRGBO(18, 124, 47, 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.all(20),
                        leading: Icon(
                          Icons.hotel,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Sieht aus wie ein freier Tag :)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  )));
            } else if (day.courses().length == 1) {
              courseWidgets.add(CourseWidget(
                course: day.courses()[0],
              ));
            } else {
              for (int i = 0; i < day.courses().length; i++) {
                if (i < day.courses().length - 1) {
                  courseWidgets.add(CourseWidget(
                    course: day.courses()[i],
                  ));

                  var firstCourseEndTime =
                      day.courses()[i].time().split(' bis ')[1];
                  var secondCourseStartTime =
                      day.courses()[i + 1].time().split(' bis ')[0];
                  var firstCourseList = firstCourseEndTime.split(':');
                  var secondCourseList = secondCourseStartTime.split(':');
                  var firstCourseMinutes = int.parse(firstCourseList[1]) +
                      int.parse(firstCourseList[0]) * 60;
                  var secondCourseMinutes = int.parse(secondCourseList[1]) +
                      int.parse(secondCourseList[0]) * 60;

                  courseWidgets.add(_getBreakSpacer(
                      secondCourseMinutes - firstCourseMinutes));
                } else {
                  courseWidgets.add(CourseWidget(
                    course: day.courses()[i],
                  ));
                }
              }
            }
            dayWidgets.add(
              Center(
                  child: ListView(
                padding: EdgeInsets.all(10),
                children: courseWidgets,
              )),
            );
          }

          var floatingActionButtons = <Widget>[];

          floatingActionButtons.add(
            FloatingActionButton(
              heroTag: null,
              onPressed: () {
                setState(
                  () {
                    _increaseWeekOfYear();
                    _scheduleFuture = _getDataFromFuture(
                        _fdNumber, _passWord, _requestedWeek, _requestedYear);
                  },
                );
              },
              child: Icon(Icons.arrow_forward),
            ),
          );

          if (_requestedWeek != currentDay.weekOfYear &&
                  _requestedYear == currentDay.year ||
              _requestedYear != currentDay.year) {
            floatingActionButtons.add(
              SizedBox(
                height: 10,
              ),
            );
            floatingActionButtons.add(FloatingActionButton(
              heroTag: null,
              onPressed: () {
                setState(() {
                  _decreaseWeekOfYear();
                  _scheduleFuture = _getDataFromFuture(
                      _fdNumber, _passWord, _requestedWeek, _requestedYear);
                });
              },
              child: Icon(Icons.arrow_back),
            ));
          }

          return DefaultTabController(
            initialIndex: dayMapping[currentDayName],
            length: 6,
            child: Scaffold(
              backgroundColor: Colors.white38,
              appBar: AppBar(
                flexibleSpace: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TabBar(
                      tabs: <Widget>[
                        Tab(
                            text:
                                '${schedule.days['monday'].dow()}\n${schedule.days['monday'].date()}'),
                        Tab(
                            text:
                                '${schedule.days['tuesday'].dow()}\n${schedule.days['tuesday'].date()}'),
                        Tab(
                            text:
                                '${schedule.days['wednesday'].dow()}\n${schedule.days['wednesday'].date()}'),
                        Tab(
                            text:
                                '${schedule.days['thursday'].dow()}\n${schedule.days['thursday'].date()}'),
                        Tab(
                            text:
                                '${schedule.days['friday'].dow()}\n${schedule.days['friday'].date()}'),
                        Tab(
                            text:
                                '${schedule.days['saturday'].dow()}\n${schedule.days['saturday'].date()}'),
                      ],
                    ),
                  ],
                ),
              ),
              body: TabBarView(children: dayWidgets),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: floatingActionButtons,
              ),
            ),
          );
        });
  }

  void _increaseWeekOfYear() {
    if (_requestedWeek < 53)
      _requestedWeek++;
    else {
      _requestedWeek = 1;
      _requestedYear++;
    }
  }

  void _decreaseWeekOfYear() {
    if (_requestedWeek > 1)
      _requestedWeek--;
    else {
      _requestedWeek = 53;
      _requestedYear--;
    }
  }

  Widget _getBreakSpacer(int breakTimeMinutes) {
    var breakTime;
    if (breakTimeMinutes <= 60)
      breakTime = breakTimeMinutes;
    else {
      var hours = (breakTimeMinutes / 60).floor();
      var minRemaining = breakTimeMinutes - hours * 60;
      breakTime = '${hours}h $minRemaining';
    }
    IconData iconData =
        breakTimeMinutes <= 20 ? Icons.free_breakfast : Icons.fastfood;
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(iconData),
          Container(width: 15),
          Text(
            '$breakTime Minuten',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      )),
    );
  }
}
