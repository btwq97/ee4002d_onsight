import 'package:flutter/material.dart';
import 'package:on_sight/setuppages/Allergy.dart';
import 'package:on_sight/setuppages/CustomerOrStoreownerPage.dart';
import 'package:on_sight/keypages/customerhomepage.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/setuppages/HalalOrNot.dart';
import 'package:on_sight/setuppages/SpiceLevel.dart';
import 'package:on_sight/setuppages/Cuisine.dart';
import 'package:on_sight/localisation/localisation_app.dart';

void main() async {
  AppEngine appEngine = AppEngine();
  await appEngine.start();
  runApp(OnSight(appEngine));
}

class OnSight extends StatelessWidget {
  final appEngine;

  OnSight(this.appEngine);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark().copyWith(
          primaryColor: Color(0xFF301934),
          scaffoldBackgroundColor: Color(0xFF301934),
        ),
        initialRoute: '/Customer or Storeowner Page',
        routes: {
          '/Customer or Storeowner Page': (context) =>
              CustomerOrStoreOwnerPage(this.appEngine),
          '/Customer Home Page': (context) => CustomerHomePage(this.appEngine),
          '/Vegetarian Page': (context) => VegetarianPage(this.appEngine),
          '/Halal Page': (context) => HalalPage(this.appEngine),
          '/Allergy': (context) => AllergyPage(this.appEngine),
          '/Spice Level': (context) => SpiceLevelPage(this.appEngine),
          '/Cuisine': (context) => CuisinePage(appEngine),
        });
  }
}
