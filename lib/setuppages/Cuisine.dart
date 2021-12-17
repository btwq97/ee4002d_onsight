import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/iconcontenttwo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/keypages/customerhomepage.dart';

class CuisinePage extends StatefulWidget {
  @override
  _CuisinePageState createState() => _CuisinePageState();
}

class _CuisinePageState extends State<CuisinePage> {

  Color chineseCardColour = kInactiveCardColour;
  Color malayCardColour = kInactiveCardColour;
  Color indianCardColour = kInactiveCardColour;
  Color westernCardColour = kInactiveCardColour;
  Color japaneseCardColour = kInactiveCardColour;
  Color koreanCardColour = kInactiveCardColour;

  //1 = chinese, 2 = malay, 3 = indian, 4 = western, 5 = japanese, 6 = korean
  void updateColour (int chosen){
    if (chosen == 1){
      if (chineseCardColour == kInactiveCardColour){
        chineseCardColour = kActiveCardColour;
      }else{
        chineseCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 2){
      if (malayCardColour == kInactiveCardColour){
        malayCardColour = kActiveCardColour;
      }else{
        malayCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 3){
      if (indianCardColour == kInactiveCardColour){
        indianCardColour = kActiveCardColour;
      }else{
        indianCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 4){
      if (westernCardColour == kInactiveCardColour){
        westernCardColour = kActiveCardColour;
      }else{
        westernCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 5){
      if (japaneseCardColour == kInactiveCardColour){
        japaneseCardColour = kActiveCardColour;
      }else{
        japaneseCardColour = kInactiveCardColour;
      }
    }
    if (chosen == 6){
      if (koreanCardColour == kInactiveCardColour){
        koreanCardColour = kActiveCardColour;
      }else{
        koreanCardColour = kInactiveCardColour;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'CUISINE?',
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
                  colour: chineseCardColour,
                  cardChild: IconContentTwo(
                    label: 'CHINESE',
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
                  colour: malayCardColour,
                  cardChild: IconContentTwo(
                    label: 'MALAY',
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
                  colour: indianCardColour,
                  cardChild: IconContentTwo(
                    label: 'INDIAN',
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
                  colour: westernCardColour,
                  cardChild: IconContentTwo(
                    label: 'WESTERN',
                  )
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  updateColour(5);
                });
              },
              child: ReusableCard(
                  colour: japaneseCardColour,
                  cardChild: IconContentTwo(
                    label: 'JAPANESE',
                  )
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  updateColour(6);
                });
              },
              child: ReusableCard(
                  colour: koreanCardColour,
                  cardChild: IconContentTwo(
                    label: 'KOREAN',
                  )
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CustomerHomePage()));
            },
            child: Container(
              child: Center(
                child: Text (
                  'SAVE',
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



/*
Chinese
Malay
Indian
Western
Japanese
Korean
*/