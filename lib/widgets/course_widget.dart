import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:horstl_wrapper/horstl_wrapper.dart';

class CourseWidget extends StatefulWidget {
  final Course course;

  CourseWidget({Key key, this.course});

  @override
  State<StatefulWidget> createState() => _CourseWidgetState(course);
}

class _CourseWidgetState extends State<CourseWidget>{
  Course course;
  _CourseWidgetState(this.course);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Color.fromRGBO(18, 124, 47, 100),
      child: Column(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.only(top: 10, left: 20, right: 20),
              leading: Icon(
                Icons.assignment,
                color: Colors.white,
              ),
              title: Text(
                '[${course.id()}] ${course.name()}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 20, right: 20),
              leading: Icon(
                Icons.access_time,
                color: Colors.white,
              ),
              title: Text(
                course.time(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 20, right: 20),
              leading: Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              title: Text(
                course.roomInfo(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 20, right: 20),
              leading: Icon(
                Icons.person,
                color: Colors.white,
              ),
              title: Text(
                course.docent(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ]
      ),
    );
  }
}