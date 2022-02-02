import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Cuisine.dart';

enum SpicePreference {
  None,
  Mild,
  Full,
}

class SpiceLevelPage extends StatefulWidget {
  final appEngine;

  SpiceLevelPage(this.appEngine);

  @override
  _SpiceLevelPageState createState() => _SpiceLevelPageState(this.appEngine);
}

class _SpiceLevelPageState extends State<SpiceLevelPage> {
  final appEngine;

  _SpiceLevelPageState(this.appEngine);

  SpicePreference? level;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SPICE LEVEL?',
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
                    level = SpicePreference.None;
                  });
                },
                colour: level == SpicePreference.None
                    ? kActiveCardColour
                    : kInactiveCardColour,
                cardChild: IconContent(
                  icon: Icons.highlight_off,
                  label: 'NONE',
                )),
          ),
          Expanded(
            child: ReusableCard(
                onPress: () {
                  setState(() {
                    level = SpicePreference.Mild;
                  });
                },
                colour: level == SpicePreference.Mild
                    ? kActiveCardColour
                    : kInactiveCardColour,
                cardChild: IconContent(
                  icon: FontAwesomeIcons.pepperHot,
                  label: 'MILD',
                )),
          ),
          Expanded(
            child: ReusableCard(
                onPress: () {
                  setState(() {
                    level = SpicePreference.Full;
                  });
                },
                colour: level == SpicePreference.Full
                    ? kActiveCardColour
                    : kInactiveCardColour,
                cardChild: IconContent(
                  icon: FontAwesomeIcons.hotjar,
                  label: 'FULL',
                )),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CuisinePage(appEngine)));
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
