import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/iconcontent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/components/reuseablecard.dart';


class AllergyPage extends StatefulWidget {
  @override
  _AllergyPageState createState() => _AllergyPageState();
}

class _AllergyPageState extends State<AllergyPage> {

  Color eggCardColour = kInactiveCardColour;
  Color nutsCardColour = kInactiveCardColour;
  Color milkCardColour = kInactiveCardColour;
  Color soyCardColour = kInactiveCardColour;

  //1 = egg, 2 = nuts, 3 = milk, 4 = soy
  void updateColour (int chosen){
    if (chosen == 1){
      if (eggCardColour == kInactiveCardColour){
        eggCardColour = kActiveCardColour;
      }else{
        eggCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 2){
      if (nutsCardColour == kInactiveCardColour){
        nutsCardColour = kActiveCardColour;
      }else{
        nutsCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 3){
      if (milkCardColour == kInactiveCardColour){
        milkCardColour = kActiveCardColour;
      }else{
        milkCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 4){
      if (soyCardColour == kInactiveCardColour){
        soyCardColour = kActiveCardColour;
      }else{
        soyCardColour = kInactiveCardColour;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SELECT YOUR ALLERGIES'),
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
                  cardChild: IconContent(
                    icon: FontAwesomeIcons.egg,
                    label: 'EGGS',
                  )
              ),
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
                  cardChild: IconContent(
                    icon: FontAwesomeIcons.nutritionix,
                    label: 'NUTS',
                  )
              ),
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
                  cardChild: IconContent(
                    icon: FontAwesomeIcons.hatCowboy,
                    label: 'MILK',
                  )
              ),
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
                  cardChild: IconContent(
                    icon: FontAwesomeIcons.bandcamp,
                    label: 'SOY',
                  )
              ),
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





/*class Allergy extends StatelessWidget {

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
}*/