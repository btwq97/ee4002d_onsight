import 'package:flutter/material.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontenttwo.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/setuppages/SpiceLevel.dart';
import 'package:on_sight/setuppages/Allergy.dart';
import 'package:on_sight/setuppages/Cuisine.dart';
import 'package:on_sight/setuppages/HalalOrNot.dart';

//Page to toggle and select all preferences

class CustomerPreferencesSetup extends StatefulWidget {
  CustomerPreferencesSetup({
    Key? key,
    required this.onSight,
  }) : super(key: key);

  final OnSight onSight;

  @override
  _CustomerPreferencesSetupState createState() => _CustomerPreferencesSetupState(
    onSight: onSight,
  );
}

class _CustomerPreferencesSetupState extends State<CustomerPreferencesSetup> {
  _CustomerPreferencesSetupState({
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
          'SELECT CHOICES',
          style: TextStyle(fontSize: 30),
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
                    label: 'VEGETARIAN?',
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
                    label: 'TEST THE PAGE',
                  )),
            ),
          ),
        ],
      ),
    );
  }
}