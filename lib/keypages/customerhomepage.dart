import 'package:flutter/material.dart';

import 'package:on_sight/constants.dart';
import 'package:on_sight/connectivity/bluetooth_main.dart';
import 'package:on_sight/connectivity/canemodule_main.dart';
import 'package:on_sight/localisation/localisation_app.dart';
import 'package:on_sight/uipagecustomer/canteen_map.dart';

class CustomerHomePage extends StatefulWidget {
  final _onSight;

  CustomerHomePage(this._onSight);

  @override
  _CustomerHomePageState createState() =>
      _CustomerHomePageState(this._onSight);
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final _onSight;

  _CustomerHomePageState(this._onSight);

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
                      // builder: (context) => VegetarianPage(this._onSight)
                      builder: (context) => CanteenTestPage()));
            },
            child: Container(
              child: Center(
                child: Text(
                  'LOCATION MAP',
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
                  //MaterialPageRoute(builder: (context) => BluetoothMainPage()));
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
                          LocalisationAppPage(this._onSight))); // TODO: resolve issue
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CaneModulePage()));
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
        ],
      ),
    );
  }
}
