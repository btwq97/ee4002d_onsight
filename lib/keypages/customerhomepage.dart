import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:on_sight/constants.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/services/onsight_cane.dart';
import 'package:on_sight/connectivity/canemodule_main.dart';
import 'package:on_sight/uipagecustomer/canteen_map.dart';
import 'package:on_sight/services/onsight_device_list.dart';

class CustomerHomePage extends StatefulWidget {
  CustomerHomePage({
    Key? key,
    required this.onSight,
    required this.ble,
  }) : super(key: key);

  final OnSight onSight;
  final FlutterReactiveBle ble;

  @override
  _CustomerHomePageState createState() => _CustomerHomePageState(
        onSight: onSight,
        ble: ble,
      );
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  _CustomerHomePageState({
    required this.onSight,
    required this.ble,
  });

  final OnSight onSight;
  final FlutterReactiveBle ble;

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
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OnsightCaneScreen()));
            },
            child: Container(
              child: Center(
                child: Text(
                  'CONNECT TO ESP32',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OnsightLocalisationUI(
                            onSight: this.onSight,
                            ble: ble,
                          )));
            },
            child: Container(
              child: Center(
                child: Text(
                  'FLUTTER REACTIVE BLE',
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
