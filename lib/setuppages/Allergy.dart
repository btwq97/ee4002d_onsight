import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/iconcontent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/components/reuseablecard.dart';


class Allergy extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIST YOUR ALLERGIES'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
                cardChild: IconContent(
                  icon: FontAwesomeIcons.egg,
                  label: 'EGGS',
                )
            ),
          ),
          Expanded(
            child: ReusableCard(
                cardChild: IconContent(
                  icon: FontAwesomeIcons.nutritionix,
                  label: 'NUTS',
                )
            ),
          ),
          Expanded(
            child: ReusableCard(
                cardChild: IconContent(
                  icon: FontAwesomeIcons.hatCowboy,
                  label: 'MILK',
                )
            ),
          ),
          Expanded(
            child: ReusableCard(
                cardChild: IconContent(
                  icon: FontAwesomeIcons.bandcamp,
                  label: 'SOY',
                )
            ),
          ),
          /*BottomButton(
            buttonTitle: 'NEXT',
            onTap: () {
              Navigator.pop(context);
            },
          )*/
        ],
      ),
    );
  }
}