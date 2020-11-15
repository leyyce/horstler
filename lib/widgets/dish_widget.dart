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
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:horstl_wrapper/horstl_wrapper.dart';

class DishWidget extends StatefulWidget {
  final Dish dish;

  DishWidget({Key key, this.dish}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DishWidgetState(dish);
}

class _DishWidgetState extends State<DishWidget> {
  Dish dish;
  _DishWidgetState(this.dish);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                image: AdvancedNetworkImage(
                  dish.imgURL,
                  useDiskCache: true,
                  cacheRule: CacheRule(maxAge: const Duration(days: 5)),
                ),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              )),
          child: Column(children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.only(top: 10, left: 20, right: 20),
              leading: Icon(
                Icons.fastfood,
                color: Colors.white,
              ),
              title: Text(
                dish.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 20, right: 20),
              leading: Icon(
                Icons.description,
                color: Colors.white,
              ),
              title: Text(
                dish.description,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 20, right: 20),
              leading: Icon(
                Icons.attach_money,
                color: Colors.white,
              ),
              title: Text(
                dish.price,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ]),
        ));
  }
}
