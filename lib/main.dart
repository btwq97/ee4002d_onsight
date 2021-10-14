import 'package:flutter/material.dart';
import 'package:on_sight/setuppages/CustomerOrStoreownerPage.dart';

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
      home: CustomerOrStoreOwnerPage(),
    );
  }
}

