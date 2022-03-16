import 'package:flutter/material.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/services/onsight.dart';
// import 'package:on_sight/services/onsight_cane.txt';
import 'package:on_sight/uipagecustomer/canteen_map.dart';
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
          style: TextStyle(fontSize: 40),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CanteenTestPage()));
            },

            // Location map
            child: Container(
              child: Center(
                child: Text(
                  'LOCATION MAP',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          ),

          // Connect to ESP32
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => OnsightCaneScreen()));
          //   },
          //   child: Container(
          //     child: Center(
          //       child: Text(
          //         'CONNECT TO ESP32',
          //         style: kBottomButtonTextStyle,
          //       ),
          //     ),
          //     color: kBottomContainerColour,
          //     margin: EdgeInsets.only(top: 10.0),
          //     width: double.infinity,
          //     height: kBottomContainerHeight,
          //   ),
          // ),

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
          //         'CHARACTERISTICS TESTING',
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
                  'LOCALISATION TESTING',
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
