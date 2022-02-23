import 'package:flutter/material.dart';

class CanteenTestPage extends StatefulWidget {
  @override
  _CanteenTestPageState createState() => _CanteenTestPageState();
}

class _CanteenTestPageState extends State<CanteenTestPage> {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text('Canteen Map')),
          body: InteractiveViewer(
              child: Center(
                  child: Image.asset('images/Technoedge_Map_PurpleBG.png')))),
    );
  }
}
