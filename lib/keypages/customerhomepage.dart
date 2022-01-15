import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/components/iconcontenttwo.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/setuppages/HalalOrNot.dart';
import 'package:on_sight/setuppages/Allergy.dart';
import 'package:on_sight/setuppages/SpiceLevel.dart';
import 'package:on_sight/setuppages/Cuisine.dart';
import 'package:on_sight/connectivity/bluetooth_main.dart';
import 'package:on_sight/localisation/localisation_bluetooth.dart';
import 'package:on_sight/localisation/localisation_app.dart';

class CustomerHomePage extends StatefulWidget {
  final appEngine;

  CustomerHomePage(this.appEngine);

  @override
  _CustomerHomePageState createState() =>
      _CustomerHomePageState(this.appEngine);
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final appEngine;

  _CustomerHomePageState(this.appEngine);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HOME PAGE',
          style: TextStyle(fontSize: 40),
        ),
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
                      builder: (context) => VegetarianPage(this.appEngine)));
            },
            child: Container(
              child: Center(
                child: Text(
                  'PREFERENCES',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              //padding: EdgeInsets.only(bottom: 20.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => BluetoothMainPage()));
            },
            child: Container(
              child: Center(
                child: Text(
                  'CONNECT TO BEACON',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              //padding: EdgeInsets.only(bottom: 20.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LocalisationAppPage(this.appEngine)));
            },
            child: Container(
              child: Center(
                child: Text(
                  'EXPERIMENT 1',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              //padding: EdgeInsets.only(bottom: 20.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LocalisationAppPage(this.appEngine)));
            },
            child: Container(
              child: Center(
                child: Text(
                  'EXPERIMENT 2',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              //padding: EdgeInsets.only(bottom: 20.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          ),
          // GestureDetector(
          //   onTap: (){
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => SpiceLevelPage()));
          //   },
          //   child: Container(
          //     child: Center(
          //       child: Text (
          //         'SPICINESS PAGE',
          //         style: kBottomButtonTextStyle,
          //       ),
          //     ),
          //     color: kBottomContainerColour,
          //     margin: EdgeInsets.only(top: 10.0),
          //     //padding: EdgeInsets.only(bottom: 20.0),
          //     width: double.infinity,
          //     height: kBottomContainerHeight,
          //   ),
          // ),
          // GestureDetector(
          //   onTap: (){
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => CuisinePage()));
          //   },
          //   child: Container(
          //     child: Center(
          //       child: Text (
          //         'CUISINE CHOICES',
          //         style: kBottomButtonTextStyle,
          //       ),
          //     ),
          //     color: kBottomContainerColour,
          //     margin: EdgeInsets.only(top: 10.0),
          //     //padding: EdgeInsets.only(bottom: 20.0),
          //     width: double.infinity,
          //     height: kBottomContainerHeight,
          //   ),
          // ),
          // GestureDetector(
          //   onTap: (){
          //     Navigator.popUntil(context, ModalRoute.withName('/Halal Page'));
          //         //MaterialPageRoute(builder: (context) => HalalPage()));
          //   },
          //   child: Container(
          //     child: Center(
          //       child: Text (
          //         'HALAL/NON-HALAL',
          //         style: kBottomButtonTextStyle,
          //       ),
          //     ),
          //     color: kActiveCardColour,
          //     width: double.infinity,
          //     height: kBottomContainerHeight,
          //   ),
          // ),
        ],
      ),
    );
  }
}
