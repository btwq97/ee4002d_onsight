import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/HalalOrNot.dart';

enum FoodPreference {
  Yes,
  No,
}

class VegetarianPage extends StatefulWidget {
  final appEngine;

  VegetarianPage(this.appEngine);

  @override
  _VegetarianPageState createState() => _VegetarianPageState(this.appEngine);
}

class _VegetarianPageState extends State<VegetarianPage> {
  final appEngine;

  _VegetarianPageState(this.appEngine);

  FoodPreference? preferred;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VEGETARIAN?',
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
                      builder: (context) => HalalPage(this.appEngine)));
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


