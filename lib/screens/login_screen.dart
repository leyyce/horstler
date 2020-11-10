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
import 'package:horstler/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final fdNumController = TextEditingController();
  final passWordController = TextEditingController();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fdNumController.dispose();
    passWordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fdNumField = TextField(
      controller: fdNumController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: 'fdXXXXX',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
          )),
    );

    final passWordField = TextField(
      controller: passWordController,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    );

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.green,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        onPressed: () {
          var fdNumber = fdNumController.text;
          var passWord = passWordController.text;
          _saveLogin(fdNumber, passWord);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()));
        },
        child: Text(
          'Login',
          textAlign: TextAlign.center,
          style:
              style.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 155,
                    child: Image(
                      image: AssetImage('assets/icons/horstler_icon.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: 45,
                  ),
                  fdNumField,
                  SizedBox(
                    height: 25,
                  ),
                  passWordField,
                  SizedBox(
                    height: 35,
                  ),
                  loginButton,
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _saveLogin(String fdNumber, String passWord) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('horst_fdNumber', fdNumber);
    prefs.setString('horst_phrase', passWord);
  }
}
