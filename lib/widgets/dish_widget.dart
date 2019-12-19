import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:horstl_wrapper/horstl_wrapper.dart';

class DishWidget extends StatefulWidget {
  final Dish dish;

  DishWidget({Key key, this.dish});

  @override
  State<StatefulWidget> createState() => _DishWidgetState(dish);
}

class _DishWidgetState extends State<DishWidget>{
  Dish dish;
  _DishWidgetState(this.dish);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
            image: AdvancedNetworkImage(
              dish.imgURL,
              useDiskCache: true,
              cacheRule: CacheRule(maxAge: const Duration(days: 5)),
            ),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          )
        ),
        child: Column(
            children: <Widget>[
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
            ]
        ),
      )
    );
  }
}