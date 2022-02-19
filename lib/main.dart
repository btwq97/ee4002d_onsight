import 'package:flutter/material.dart';

import 'package:on_sight/setuppages/Allergy.dart';
import 'package:on_sight/setuppages/CustomerOrStoreownerPage.dart';
import 'package:on_sight/keypages/customerhomepage.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/setuppages/HalalOrNot.dart';
import 'package:on_sight/setuppages/SpiceLevel.dart';
import 'package:on_sight/setuppages/Cuisine.dart';
import 'package:on_sight/onsight.dart';

void main() async {
  OnSight onSight = OnSight();
  await onSight.start();

  runApp(HomePage(onSight: onSight));

  return;
}

class HomePage extends StatelessWidget {
  final OnSight onSight;

  const HomePage({Key? key, required this.onSight}) : super(key: key);

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
              CustomerOrStoreOwnerPage(this.onSight),
          '/Customer Home Page': (context) => CustomerHomePage(this.onSight),
          '/Vegetarian Page': (context) => VegetarianPage(this.onSight),
          '/Halal Page': (context) => HalalPage(this.onSight),
          '/Allergy': (context) => AllergyPage(this.onSight),
          '/Spice Level': (context) => SpiceLevelPage(this.onSight),
          '/Cuisine': (context) => CuisinePage(this.onSight),
        });
  }
}
