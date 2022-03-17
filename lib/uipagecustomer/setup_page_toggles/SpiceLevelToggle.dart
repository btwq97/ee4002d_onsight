import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/reuseablecard.dart';

enum SpicePreference {
  Yes,
  No,
}

class SpicePreferenceToggle extends StatefulWidget {
  @override
  _SpicePreferenceToggleState createState() => _SpicePreferenceToggleState();
}

class _SpicePreferenceToggleState extends State<SpicePreferenceToggle> {
  List<bool> isSelected = [true, false, false];

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
                  child: Text('NONE', style: TextStyle(fontSize: 30)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('MILD', style: TextStyle(fontSize: 30)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('FULL', style: TextStyle(fontSize: 30)),
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
          ],
        )
      );
}
