import 'package:flutter/material.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontenttwo.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/SpiceLevel.dart';

class AllergyPage extends StatefulWidget {
  AllergyPage({
    Key? key,
    required this.onSight,
  }) : super(key: key);

  final OnSight onSight;

  @override
  _AllergyPageState createState() => _AllergyPageState(
        onSight: onSight,
      );
}

class _AllergyPageState extends State<AllergyPage> {
  _AllergyPageState({
    required this.onSight,
  });

  final OnSight onSight;

  Color eggCardColour = kInactiveCardColour;
  Color nutsCardColour = kInactiveCardColour;
  Color milkCardColour = kInactiveCardColour;
  Color soyCardColour = kInactiveCardColour;

  //1 = egg, 2 = nuts, 3 = milk, 4 = soy
  void updateColour(int chosen) {
    if (chosen == 1) {
      if (eggCardColour == kInactiveCardColour) {
        eggCardColour = kActiveCardColour;
      } else {
        eggCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 2) {
      if (nutsCardColour == kInactiveCardColour) {
        nutsCardColour = kActiveCardColour;
      } else {
        nutsCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 3) {
      if (milkCardColour == kInactiveCardColour) {
        milkCardColour = kActiveCardColour;
      } else {
        milkCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 4) {
      if (soyCardColour == kInactiveCardColour) {
        soyCardColour = kActiveCardColour;
      } else {
        soyCardColour = kInactiveCardColour;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ALLERGIES',
          style: TextStyle(fontSize: 40),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  updateColour(1);
                });
              },
              child: ReusableCard(
                  colour: eggCardColour,
                  cardChild: IconContentTwo(
                    label: 'EGGS',
                  )),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  updateColour(2);
                });
              },
              child: ReusableCard(
                  colour: nutsCardColour,
                  cardChild: IconContentTwo(
                    label: 'NUTS',
                  )),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  updateColour(3);
                });
              },
              child: ReusableCard(
                  colour: milkCardColour,
                  cardChild: IconContentTwo(
                    label: 'MILK',
                  )),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  updateColour(4);
                });
              },
              child: ReusableCard(
                  colour: soyCardColour,
                  cardChild: IconContentTwo(
                    label: 'SOY',
                  )),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SpiceLevelPage(
                            onSight: onSight,
                          )));
            },
            child: Container(
              child: Center(
                child: Text(
                  'NEXT',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              padding: EdgeInsets.only(bottom: 20.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          ),
        ],
      ),
    );
  }
}
