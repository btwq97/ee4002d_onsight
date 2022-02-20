import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';

enum Role {
  customer,
  storeowner,
}

class CustomerOrStoreOwnerPage extends StatefulWidget {
  CustomerOrStoreOwnerPage({
    Key? key,
    required this.onSight,
    required this.ble,
  }) : super(key: key);

  final OnSight onSight;
  final FlutterReactiveBle ble;

  @override
  _CustomerOrStoreownerPageState createState() =>
      _CustomerOrStoreownerPageState(
        onSight: onSight,
        ble: ble,
      );
}

class _CustomerOrStoreownerPageState extends State<CustomerOrStoreOwnerPage> {
  _CustomerOrStoreownerPageState({
    required this.onSight,
    required this.ble,
  });

  final OnSight onSight;
  final FlutterReactiveBle ble;

  Role? chosen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ROLE?',
          style: TextStyle(fontSize: 40),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ReusableCard(
                onPress: () {
                  setState(() {
                    chosen = Role.customer;
                  });
                },
                colour: chosen == Role.customer
                    ? kActiveCardColour
                    : kInactiveCardColour,
                cardChild: IconContent(
                  icon: FontAwesomeIcons.userFriends,
                  label: 'CUSTOMER',
                )),
          ),
          Expanded(
            child: ReusableCard(
                onPress: () {
                  setState(() {
                    chosen = Role.storeowner;
                  });
                },
                colour: chosen == Role.storeowner
                    ? kActiveCardColour
                    : kInactiveCardColour,
                cardChild: IconContent(
                  icon: FontAwesomeIcons.store,
                  label: 'STOREOWNER',
                )),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VegetarianPage(
                            onSight: onSight,
                            ble: ble,
                          )));
            },
            child: Container(
              child: Center(
                child: Text(
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
