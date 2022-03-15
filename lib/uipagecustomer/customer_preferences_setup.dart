import 'package:flutter/material.dart';
import 'package:on_sight/keypages/customerhomepage.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontenttwo.dart';
import 'package:on_sight/components/reuseablecard.dart';

//Toggle pages for preferences
import 'package:on_sight/uipagecustomer/setup_page_toggles/AllergyToggle.dart';
import 'package:on_sight/uipagecustomer/setup_page_toggles/CuisineToggle.dart';
import 'package:on_sight/uipagecustomer/setup_page_toggles/HalalOrNotToggle.dart';
import 'package:on_sight/uipagecustomer/setup_page_toggles/SpiceLevelToggle.dart';
import 'package:on_sight/uipagecustomer/setup_page_toggles/VegetarianismToggle.dart';

//KIV
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/setuppages/SpiceLevel.dart';
import 'package:on_sight/setuppages/Allergy.dart';
import 'package:on_sight/setuppages/Cuisine.dart';
import 'package:on_sight/setuppages/HalalOrNot.dart';

//Page to toggle and select all preferences

class CustomerPreferencesSetup extends StatefulWidget {
  CustomerPreferencesSetup({
    Key? key,
    required this.onSight,
  }) : super(key: key);

  final OnSight onSight;

  @override
  _CustomerPreferencesSetupState createState() =>
      _CustomerPreferencesSetupState(
        onSight: onSight,
      );
}

class _CustomerPreferencesSetupState extends State<CustomerPreferencesSetup> {
  _CustomerPreferencesSetupState({
    required this.onSight,
  });

  final OnSight onSight;

  Widget build(BuildContext context) =>  Scaffold(
    appBar: AppBar(
      title: const Text('PREFERENCES', style: TextStyle(fontSize: 40, color: Color(0xFFFFFF00),),),
      backgroundColor: Color(0xFF702963),
    ),
    body: Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildHeader(
              title: 'VEGETARIAN?',
              child: //Text("INSERT VEGETARIAN TOGGLE HERE"),
              VegetarianToggle(),
            ),
            const SizedBox(height: 32),
            buildHeader(
              title: 'HALAL OPTION?',
              child: //Text("INSERT HALAL TOGGLE HERE"),
              HalalOrNotToggle(),
            ),
            const SizedBox(height: 32),
            buildHeader(
              title: 'SPICINESS LEVEL?',
              child: Text("INSERT SPICINESS TOGGLE HERE"),
              //HalalOrNotToggle(),
            ),
            const SizedBox(height: 32),
            buildHeader(
              title: 'ANY ALLERGIES?',
              child: Text("INSERT ALLERGY TOGGLE HERE"),
              //HalalOrNotToggle(),
            ),
            const SizedBox(height: 32),
            buildHeader(
              title: 'CUISINE PREFERENCES?',
              child: Text("INSERT CUISINE TOGGLE HERE"),
              //HalalOrNotToggle(),
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
              child: Container(
                child: Center(
                  child: Text(
                    'SAVE',
                    style: kBottomButtonTextStyle,
                  ),
                ),
                color: kBottomContainerColour,
                margin: EdgeInsets.only(top: 10.0),
                padding: EdgeInsets.only(bottom: 10.0),
                width: double.infinity,
                height: kBottomContainerHeight,
              ),
            ),

          ],
        ),
      ),
    ),
  );

  Widget buildHeader({
    required Widget child,
    required String title,
  }) =>
      Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      );
      // Container(
      // margin: EdgeInsets.all(5.0),
      // height: 295.0,
      // width: 333.0,
      // child: ListView(shrinkWrap: true, children: [
      //   //Text('VEGETARIAN?'),
      //   VegetarianToggle(),
      // ]));
}
