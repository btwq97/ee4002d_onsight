import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/HalalOrNot.dart';

enum FoodPreference {
  Yes,
  No,
}

class VegetarianPage extends StatefulWidget {
  VegetarianPage({
    Key? key,
    required this.onSight,
  });

  final OnSight onSight;

  @override
  _VegetarianPageState createState() => _VegetarianPageState(
        onSight: onSight,
      );
}

class _VegetarianPageState extends State<VegetarianPage> {
  _VegetarianPageState({
    required this.onSight,
  });

  final OnSight onSight;
  FoodPreference? preferred;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VEGETARIAN?',
          style: TextStyle(fontSize: 40, color: Color(0xFFFFFF00),),
        ),
        backgroundColor: Color(0xFF702963),
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
                      builder: (context) => HalalPage(
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
