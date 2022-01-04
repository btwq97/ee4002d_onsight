import 'package:flutter/material.dart';
import 'package:on_sight/setuppages/Allergy.dart';
import 'package:on_sight/setuppages/CustomerOrStoreownerPage.dart';
import 'package:on_sight/keypages/customerhomepage.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:on_sight/setuppages/HalalOrNot.dart';
import 'package:on_sight/setuppages/SpiceLevel.dart';
import 'package:on_sight/setuppages/Cuisine.dart';
import 'package:on_sight/localisation/localisation_app.dart';

class TestCases extends AppEngine {
  TestCases();
  // Test cases
  final Map<String, dynamic> _input = {
    // 'A': {
    //   'rssi': {
    //     'd94250a2-c73a-4249-9a1e-4abb2643078a': -74.35,
    //     '87ccf436-0f86-4dfe-80f9-9ff731033620': -65.25,
    //     '9d9214f8-8870-43dd-a496-401765bf7866': -65.75
    //   },
    //   'accelerometer': 5,
    //   'magnetometer': [-33.57, 86.31]
    // }, //can remove, only example to show how it is tested. Will be using public method eventually
    // 'B': {
    //   'rssi': {
    //     '40409a6a-ec8b-4d24-b496-9bd2e78c044f': -70.75,
    //     'd94250a2-c73a-4249-9a1e-4abb2643078a': -72.4,
    //     '9d9214f8-8870-43dd-a496-401765bf7866': -60.45
    //   },
    //   'accelerometer': 5,
    //   'magnetometer': [-33.57, 86.31]
    // }, //not needed
    // 'C': {
    //   'rssi': {
    //     '40409a6a-ec8b-4d24-b496-9bd2e78c044f': -72.0,
    //     'd94250a2-c73a-4249-9a1e-4abb2643078a': -67.85,
    //     '9d9214f8-8870-43dd-a496-401765bf7866': -62.95
    //   },
    //   'accelerometer': 5,
    //   'magnetometer': [-33.57, 86.31]
    // }, //not needed
    // 'D': {
    //   'rssi': {
    //     'd94250a2-c73a-4249-9a1e-4abb2643078a': -78.4,
    //     '46cfaea6-47ce-4491-acf4-72bc0264437a': -71.6,
    //     '9d9214f8-8870-43dd-a496-401765bf7866': -65.25
    //   },
    //   'accelerometer': 5,
    //   'magnetometer': [-33.57, 86.31]
    // }, //not needed
    // // (-53.6 200.1)
    // 'EXACT': {
    //   'rssi': {
    //     '9d9214f8-8870-43dd-a496-401765bf7866': -61.6888,
    //     '40409a6a-ec8b-4d24-b496-9bd2e78c044f': -73.5868,
    //     '87ccf436-0f86-4dfe-80f9-9ff731033620': -75.7231
    //   },
    //   'accelerometer': 5,
    //   'magnetometer': [-33.57, 86.31]
    // }, //not needed
    // 'INTERCEPT': {
    //   'rssi': {
    //     'd94250a2-c73a-4249-9a1e-4abb2643078a': -79.35,
    //     '87ccf436-0f86-4dfe-80f9-9ff731033620': -70.25,
    //     '9d9214f8-8870-43dd-a496-401765bf7866': -69.75
    //   },
    //   'accelerometer': 5,
    //   'magnetometer': [-33.57, 86.31]
    // } //not needed
  };

  // Public methods
  Map<String, dynamic> getJson(String key) {
    return _input[key];
  }
}

void main() async {
  runApp(
      OnSight()
  );
  // How to use AppEngine
  TestCases appEngineExample = TestCases();
  await appEngineExample.start();

  // Testing
  List<String> inputs = ['A', 'B', 'C', 'D', 'EXACT', 'INTERCEPT'];
  for (var input in inputs) {
    Map<String, dynamic> rawData = appEngineExample.getJson(input);
    appEngineExample.mqttPublish(rawData, 'rssi', topic: 'fyp/test/rssi');
    Map<String, dynamic> result = appEngineExample.localisation(rawData);
    appEngineExample.mqttPublish(result, 'result', topic: 'fyp/test/result');
  }
  // Loop to return values
  var i = 0;
  while (i>=0){
    for (var input in inputs){
      Map<String, dynamic> rawData = appEngineExample.getJson(input);
      appEngineExample.mqttPublish(rawData, 'rssi', topic: 'fyp/test/rssi');
      Map<String, dynamic> result = appEngineExample.localisation(rawData);
      appEngineExample.mqttPublish(result, 'result', topic: 'fyp/test/result');
      i++; //run infinite times until app stops
    }
  }
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

