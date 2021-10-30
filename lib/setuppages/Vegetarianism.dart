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
  @override
  _VegetarianPageState createState() => _VegetarianPageState();
}

class _VegetarianPageState extends State<VegetarianPage> {

  FoodPreference? preferred;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VEGETARIAN?', style: TextStyle(fontSize: 40),),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
                onPress: (){
                  setState(() {
                    preferred = FoodPreference.Yes;
                  });
                },
                colour: preferred == FoodPreference.Yes ? kActiveCardColour : kInactiveCardColour,
                cardChild: IconContent(
                  icon: FontAwesomeIcons.thumbsUp,
                  label: 'YES',
                )
            ),
          ),
          Expanded(
            child: ReusableCard(
                onPress: (){
                  setState(() {
                    preferred = FoodPreference.No;
                  });
                },
                colour:  preferred == FoodPreference.No ? kActiveCardColour : kInactiveCardColour,
                cardChild: IconContent(
                  icon: FontAwesomeIcons.thumbsDown,
                  label: 'NO',
                )
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => HalalPage()));
              },
              child: Container(
                child: Center(
                  child: Text (
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


/*class Vegetarianism extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VEGETARIAN?'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
              cardChild: IconContent(
                icon: FontAwesomeIcons.thumbsUp,
                label: 'YES',
              )
            ),
          ),
          Expanded(
            child: ReusableCard(
                cardChild: IconContent(
                  icon: FontAwesomeIcons.thumbsDown,
                  label: 'NO',
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

/*class Vegetarianism extends StatefulWidget {
  @override
  _VegetarianState createState() => _VegetarianState();
}*/

/*class _VegetarianState extends State<Vegetarianism> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Onsight',
          style: TextStyle(
            fontFamily: 'HKGrotesk',
            color: Color(0xFFFFFF00),
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black12,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ReusableCard(
                      onPress: () {
                        setState(() {
                          selectedChoice = Choice.vegetarian;
                        });
                      },
                      colour: selectedChoice = Choice.vegetarian
                          ? kActiveCardColour
                          : kInactiveCardColour,
                      cardChild: IconContent(
                        icon: FontAwesomeIcons.mars,
                        label: 'VEGETARIAN',
                      ),
                    ),
                  ),
                  Expanded(
                    child: ReusableCard(
                      onPress: () {
                        setState(() {
                          selectedGender = Gender.female;
                        });
                      },
                      colour: selectedGender == Gender.female
                          ? kActiveCardColour
                          : kInactiveCardColour,
                      cardChild: IconContent(
                        icon: FontAwesomeIcons.venus,
                        label: 'FEMALE',
                      ),
                    ),
                  ),
                ],
              )),
          Expanded(
            child: ReusableCard(
              colour: kActiveCardColour,
              cardChild: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'HEIGHT',
                    style: kLabelTextStyle,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        height.toString(),
                        style: kNumberTextStyle,
                      ),
                      Text(
                        'cm',
                        style: kLabelTextStyle,
                      )
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      inactiveTrackColor: Color(0xFF8D8E98),
                      activeTrackColor: Colors.white,
                      thumbColor: Color(0xFFEB1555),
                      overlayColor: Color(0x29EB1555),
                      thumbShape:
                      RoundSliderThumbShape(enabledThumbRadius: 15.0),
                      overlayShape:
                      RoundSliderOverlayShape(overlayRadius: 30.0),
                    ),
                    child: Slider(
                      value: height.toDouble(),
                      min: 120.0,
                      max: 220.0,
                      onChanged: (double newValue) {
                        setState(() {
                          height = newValue.round();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ReusableCard(
                    colour: kActiveCardColour,
                    cardChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'WEIGHT',
                          style: kLabelTextStyle,
                        ),
                        Text(
                          weight.toString(),
                          style: kNumberTextStyle,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RoundIconButton(
                                icon: FontAwesomeIcons.minus,
                                onPressed: () {
                                  setState(() {
                                    weight--;
                                  });
                                }),
                            SizedBox(
                              width: 10.0,
                            ),
                            RoundIconButton(
                              icon: FontAwesomeIcons.plus,
                              onPressed: () {
                                setState(() {
                                  weight++;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ReusableCard(
                    colour: kActiveCardColour,
                    cardChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'AGE',
                          style: kLabelTextStyle,
                        ),
                        Text(
                          age.toString(),
                          style: kNumberTextStyle,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RoundIconButton(
                              icon: FontAwesomeIcons.minus,
                              onPressed: () {
                                setState(
                                      () {
                                    age--;
                                  },
                                );
                              },
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            RoundIconButton(
                                icon: FontAwesomeIcons.plus,
                                onPressed: () {
                                  setState(() {
                                    age++;
                                  });
                                })
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          BottomButton(
            buttonTitle: 'CONTINUE',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Vegetarianism(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}*/




