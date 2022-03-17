import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/reuseablecard.dart';


class AllergyToggle extends StatefulWidget {
  @override
  _AllergyToggleState createState() => _AllergyToggleState();
}

class _AllergyToggleState extends State<AllergyToggle> {
  List<bool> isSelected = [false, false, false, false];

  @override
  Widget build(BuildContext context) =>
      Container(
        //color: Color(0xFFCBC3E3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: Text('EGG', style: TextStyle(fontSize: 30)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('NUTS', style: TextStyle(fontSize: 30)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('MILK', style: TextStyle(fontSize: 30)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('SOY', style: TextStyle(fontSize: 30)),
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
      );
}
