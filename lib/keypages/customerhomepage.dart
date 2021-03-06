import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/uipagecustomer/canteen_map.dart';
import 'package:on_sight/uipagecustomer/customer_preferences_setup.dart'; //for UI improvement purposes, not to be used for demo
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/services/onsight_device_list.dart';
import 'package:on_sight/services/onsight_system_test_device_list.dart';

class CustomerHomePage extends StatefulWidget {
  CustomerHomePage({
    Key? key,
    required this.onSight,
  }) : super(key: key);

  final OnSight onSight;

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState(
        onSight: onSight,
      );
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  _CustomerHomePageState({
    required this.onSight,
  });

  final OnSight onSight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HOME PAGE',
          style: TextStyle(fontSize: 40, color: Color(0xFFFFFF00),),
        ),
        backgroundColor: Color(0xFF702963),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          //Set up your preferences
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VegetarianPage(onSight: onSight,)));
            },

            // Set up your preferences
            child: Container(
              child: Center(
                child: Text(
                  'SET UP YOUR PREFERENCES',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          ),

          //View the Map of the location

          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CanteenTestPage()));
            },

            // Set up your preferences new
            child: Container(
              child: Center(
                child: Text(
                  'VIEW THE MAP',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          ),


          // System Characteristics Testing
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => OnsightSystemTestScreen(
          //                   onSight: this.onSight,
          //                 )));
          //   },
          //   child: Container(
          //     child: Center(
          //       child: Text(
          //         '(Testing) CHARACTERISTICS',
          //         style: kBottomButtonTextStyle,
          //       ),
          //     ),
          //     color: kBottomContainerColour,
          //     margin: EdgeInsets.only(top: 10.0),
          //     width: double.infinity,
          //     height: kBottomContainerHeight,
          //   ),
          // ),

          // Localisation Screen
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OnsightLocalisationScreen(
                            onSight: this.onSight,
                          )));
            },
            child: Container(
              child: Center(
                child: Text(
                  'GET DIRECTIONS',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          )
        ],
      ),
    );
  }
}
