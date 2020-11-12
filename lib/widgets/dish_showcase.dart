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
