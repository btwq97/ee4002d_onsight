import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Allergy.dart';

enum FoodPreference {
  Yes,
  No,
}

class HalalPage extends StatefulWidget {
  HalalPage({
    Key? key,
    required this.onSight,
    required this.ble,
  }) : super(key: key);

  final OnSight onSight;
  final FlutterReactiveBle ble;

  @override
  _HalalPageState createState() => _HalalPageState(
        onSight: onSight,
        ble: ble,
      );
}

class _HalalPageState extends State<HalalPage> {
  _HalalPageState({
    required this.onSight,
    required this.ble,
  });

  final OnSight onSight;
  final FlutterReactiveBle ble;
  FoodPreference? preferred;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HALAL?',
          style: TextStyle(fontSize: 40),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
                onPress: () {
                  setState(() {
                    preferred = FoodPreference.Yes;
                  });
                },
                colour: preferred == FoodPreference.Yes
                    ? kActiveCardColour
                    : kInactiveCardColour,
                cardChild: IconContent(
                  icon: FontAwesomeIcons.thumbsUp,
                  label: 'YES',
                )),
          ),
          Expanded(
            child: ReusableCard(
                onPress: () {
                  setState(() {
                    preferred = FoodPreference.No;
                  });
                },
                colour: preferred == FoodPreference.No
                    ? kActiveCardColour
                    : kInactiveCardColour,
                cardChild: IconContent(
                  icon: FontAwesomeIcons.thumbsDown,
                  label: 'NO',
                )),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AllergyPage(
                            onSight: onSight,
                            ble: ble,
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
