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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:horstl_wrapper/horstl_wrapper.dart';

class CourseWidget extends StatefulWidget {
  final Course course;

  CourseWidget({Key key, this.course}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CourseWidgetState(course);
}

class _CourseWidgetState extends State<CourseWidget> {
  Course course;
  _CourseWidgetState(this.course);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Color.fromRGBO(18, 124, 47, 100),
      child: Column(children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.only(top: 5, left: 20, right: 20),
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
      ]),
    );
  }
}
