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

import 'package:flutter/cupertino.dart';
import 'package:horstl_wrapper/horstl_wrapper.dart';
import 'package:horstler/widgets/dish_widget.dart';

class DishShowcase extends StatefulWidget {
  final List<Dish> dishes;

  DishShowcase(this.dishes, {Key key}) : super(key: key);

  @override
  State<DishShowcase> createState() => _DishShowcaseState();
}

class _DishShowcaseState extends State<DishShowcase> {
  int _currentDish;
  Timer switcher;

  _DishShowcaseState();

  @override
  void initState() {
    super.initState();
    _currentDish = 0;
    switcher = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        if (_currentDish < widget.dishes.length - 1)
          _currentDish++;
        else
          _currentDish = 0;
      });
    });
  }

  @override
  void dispose() {
    switcher.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DishWidget> dishWidgets = <DishWidget>[];

    for (Dish dish in widget.dishes) {
      dishWidgets.add(DishWidget(
        dish: dish,
      ));
    }

    return AnimatedSwitcher(
        duration: Duration(seconds: 1, microseconds: 500),
        child: Container(
          key: ValueKey<int>(_currentDish),
          child: dishWidgets[_currentDish],
        ));
  }
}
