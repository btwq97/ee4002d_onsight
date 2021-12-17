import 'package:flutter/material.dart';
import 'package:on_sight/setuppages/Allergy.dart';
import 'package:on_sight/setuppages/CustomerOrStoreownerPage.dart';
import 'package:on_sight/keypages/customerhomepage.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/setuppages/HalalOrNot.dart';
import 'package:on_sight/setuppages/SpiceLevel.dart';
import 'package:on_sight/setuppages/Cuisine.dart';

void main() {
  runApp(
      OnSight()
  );
}

class OnSight extends StatelessWidget {
  //const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF301934),
        scaffoldBackgroundColor: Color(0xFF301934),
      ),
      initialRoute: '/Customer or Storeowner Page',
      routes: {
        '/Customer or Storeowner Page': (context) => CustomerOrStoreOwnerPage(),
        '/Customer Home Page': (context) => CustomerHomePage(),
        '/Vegetarian Page': (context) => VegetarianPage(),
        '/Halal Page': (context) => HalalPage(),
        '/Allergy': (context) => AllergyPage(),
        '/Spice Level': (context) => SpiceLevelPage(),
        '/Cuisine': (context) => CuisinePage(),
      }
      //home: CustomerOrStoreOwnerPage(),
    );
  }
}

