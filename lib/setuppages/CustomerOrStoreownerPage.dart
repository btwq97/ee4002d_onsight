import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/setuppages/CaneOrNot.dart';
import 'package:on_sight/uipagestoreowner/storeownerdemopage.dart';

enum Role {
  customer,
  storeowner,
}

class CustomerOrStoreOwnerPage extends StatefulWidget {
  CustomerOrStoreOwnerPage({
    Key? key,
    required this.onSight,
  }) : super(key: key);

  final OnSight onSight;

  @override
  _CustomerOrStoreownerPageState createState() =>
      _CustomerOrStoreownerPageState(
        onSight: onSight,
      );
}

class _CustomerOrStoreownerPageState extends State<CustomerOrStoreOwnerPage> {
  _CustomerOrStoreownerPageState({
    required this.onSight,
  });

  final OnSight onSight;

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
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CaneChoicePage(
                        onSight: onSight,
                      )));
            },
            child: ReusableCard(
              cardChild: IconContent(
                icon: FontAwesomeIcons.userFriends,
                label: 'CUSTOMER',
              ),
              colour: Color(0xFF301934),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StoreownerMainPage(
                        onSight: onSight,
                      )));
            },
            child: ReusableCard(
              cardChild: IconContent(
                icon: FontAwesomeIcons.store,
                label: 'STOREOWNER',
              ),
              colour: Color(0xFF301934),
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => VegetarianPage(
          //                   onSight: onSight,
          //                 )));
          //   },
          //   child: Container(
          //     child: Center(
          //       child: Text(
          //         'NEXT',
          //         style: kBottomButtonTextStyle,
          //       ),
          //     ),
          //     color: kBottomContainerColour,
          //     margin: EdgeInsets.only(top: 10.0),
          //     padding: EdgeInsets.only(bottom: 20.0),
          //     width: double.infinity,
          //     height: kBottomContainerHeight,
          //   ),
          // ), //Remove this gesture detector once all of the pages have been added
        ],
      ),
    );
  }
}
