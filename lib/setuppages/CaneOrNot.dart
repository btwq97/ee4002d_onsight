import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Allergy.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/uipagecustomer/connecttocane.dart';
import 'package:on_sight/keypages/customerhomepage.dart';

enum CaneChoice {
  Yes,
  No,
}

class CaneChoicePage extends StatefulWidget {
  CaneChoicePage({
    Key? key,
    required this.onSight,
  }) : super(key: key);

  final OnSight onSight;

  @override
  _CaneChoicePageState createState() => _CaneChoicePageState(
        onSight: onSight,
      );
}

class _CaneChoicePageState extends State<CaneChoicePage> {
  _CaneChoicePageState({
    required this.onSight,
  });

  final OnSight onSight;
  CaneChoice? preferred;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CANE MODULE?',
          style: TextStyle(fontSize: 40, color: Color(0xFFFFFF00),),
        ),
        backgroundColor: Color(0xFF702963),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConnectToCane(
                            onSight: onSight,
                          )));
            },
            child: ReusableCard(
              cardChild: IconContent(
                icon: FontAwesomeIcons.candyCane,
                label: 'HAVE',
              ),
              colour: Color(0xFF301934),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CustomerHomePage(
                            onSight: onSight,
                          )));
            },
            child: ReusableCard(
              cardChild: IconContent(
                icon: FontAwesomeIcons.thumbsDown,
                label: 'DO NOT HAVE',
              ),
              colour: Color(0xFF301934),
            ),
          ),
        ],
      ),
    );
  }
}
