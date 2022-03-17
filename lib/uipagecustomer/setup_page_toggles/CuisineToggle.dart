import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/reuseablecard.dart';


class CuisineToggle extends StatefulWidget {
  @override
  _CuisineToggleState createState() => _CuisineToggleState();
}

class _CuisineToggleState extends State<CuisineToggle> {
  List<bool> isSelected = [false, false, false, false];

  @override
  Widget build(BuildContext context) =>
      Container(
        //color: Color(0xFFCBC3E3),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ToggleButtons(
                isSelected: isSelected,
                selectedColor: Color(0xFFFFFF00),
                color: Color(0xFFFFF8DC),
                fillColor: Color(0xFF66023C),
                renderBorder: false,
                //splashColor: Colors.red,
                highlightColor: Colors.orange,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('CHINESE', style: TextStyle(fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('MALAY', style: TextStyle(fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('INDIAN', style: TextStyle(fontSize: 15)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('WESTERN', style: TextStyle(fontSize: 15)),
                  ),
                ],
                onPressed: (int index) {
                  setState(() {
                    isSelected[index] = !isSelected[index];
                  });
                },
              ),
            ],
          )
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   crossAxisAlignment: CrossAxisAlignment.stretch,
          //   children: [
          //     ToggleButtons(
          //       isSelected: isSelected,
          //       selectedColor: Color(0xFFFFFF00),
          //       color: Color(0xFFFFF8DC),
          //       fillColor: Color(0xFF66023C),
          //       renderBorder: false,
          //       //splashColor: Colors.red,
          //       highlightColor: Colors.orange,
          //       children: const <Widget>[
          //         Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 12),
          //           child: Text('CHINESE', style: TextStyle(fontSize: 15)),
          //         ),
          //         Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 12),
          //           child: Text('MALAY', style: TextStyle(fontSize: 15)),
          //         ),
          //         Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 12),
          //           child: Text('INDIAN', style: TextStyle(fontSize: 15)),
          //         ),
          //         Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 12),
          //           child: Text('WESTERN', style: TextStyle(fontSize: 15)),
          //         ),
          //       ],
          //       onPressed: (int index) {
          //         setState(() {
          //           isSelected[index] = !isSelected[index];
          //         });
          //       },
          //     ),
          //   ],
          // )
      );
}
