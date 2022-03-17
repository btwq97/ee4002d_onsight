import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/reuseablecard.dart';

enum HalalPreference {
  Yes,
  No,
}

class HalalOrNotToggle extends StatefulWidget {
  @override
  _HalalOrNotToggleState createState() => _HalalOrNotToggleState();
}

class _HalalOrNotToggleState extends State<HalalOrNotToggle> {
  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) =>
      Padding(
        //alignment: Alignment.center,
        //color: Color(0xFFCBC3E3),
          padding: EdgeInsets.all(5),
          child: Container(
            alignment: Alignment.center,
            child: ToggleButtons(
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
                  child: Text('YES', style: TextStyle(fontSize: 70)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('NO', style: TextStyle(fontSize: 70)),
                ),
              ],
              onPressed: (int newIndex) {
                setState(() {
                  for (int index = 0; index < isSelected.length; index++) {
                    if (index == newIndex) {
                      isSelected[index] = true;
                    } else {
                      isSelected[index] = false;
                    }
                  }
                });
              },
            ),
          )
      );
}
