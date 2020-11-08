import 'package:flutter/material.dart';

import 'package:horstl_wrapper/horstl_wrapper.dart';
import 'package:horstler/widgets/course_widget.dart';
import 'package:intl/intl.dart';
import 'package:splashscreen/splashscreen.dart';

class TimeTableScreen extends StatefulWidget {
  TimeTableScreen({Key key, this.fdNumber, this.passWord}) : super(key: key);

  final String fdNumber;
  final String passWord;
  @override
  _TimeTableScreenState createState() =>
      _TimeTableScreenState(fdNumber, passWord);
}

Future<TimeTable> _getDataFromFuture(String fdNumber, String passWord) async {
  return await HorstlScrapper(fdNumber, passWord).getTimeTable();
}

class _TimeTableScreenState extends State {
  final String fdNumber;
  final String passWord;

  _TimeTableScreenState(this.fdNumber, this.passWord);

  /*
  @override
  void initState() {
    super.initState();
  }
   */

  @override
  Widget build(BuildContext context) {
    var dayMapping = {
      'mon': 0,
      'tue': 1,
      'wed': 2,
      'thu': 3,
      'fri': 4,
      'sat': 5,
      'sun': 5,
    };
    var currentDay = DateFormat('E').format(DateTime.now()).toLowerCase();
    return new FutureBuilder(
        future: _getDataFromFuture(fdNumber, passWord),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          if (!snapshot.hasData) {
            return SplashScreen(
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
          }

          var timeTable;
          timeTable = snapshot.data ?? TimeTable('N/A', 'N/A'); // ?? timeTable
          var dayWidgets = <Widget>[];
          for (var day in timeTable.days.values) {
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
          return DefaultTabController(
            initialIndex: dayMapping[currentDay],
            length: 6,
            child: Scaffold(
              backgroundColor: Colors.white38,
              appBar: AppBar(
                // title: Text("Timetable for ${timeTable.studentName}"),
                flexibleSpace: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TabBar(
                      tabs: <Widget>[
                        Tab(
                            text:
                                '${timeTable.days['monday'].dow()}\n${timeTable.days['monday'].date()}'),
                        Tab(
                            text:
                                '${timeTable.days['tuesday'].dow()}\n${timeTable.days['tuesday'].date()}'),
                        Tab(
                            text:
                                '${timeTable.days['wednesday'].dow()}\n${timeTable.days['wednesday'].date()}'),
                        Tab(
                            text:
                                '${timeTable.days['thursday'].dow()}\n${timeTable.days['thursday'].date()}'),
                        Tab(
                            text:
                                '${timeTable.days['friday'].dow()}\n${timeTable.days['friday'].date()}'),
                        Tab(
                            text:
                                '${timeTable.days['saturday'].dow()}\n${timeTable.days['saturday'].date()}'),
                      ],
                    ),
                  ],
                ),
              ),
              body: TabBarView(children: dayWidgets),
            ),
          );
        });
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
