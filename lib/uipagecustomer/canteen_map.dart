import 'package:flutter/material.dart';

class CanteenTestPage extends StatefulWidget {
  @override
  _CanteenTestPageState createState() => _CanteenTestPageState();
}

class _CanteenTestPageState extends State<CanteenTestPage> {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
            appBar: AppBar(title: Text('CANTEEN MAP', style: TextStyle(fontSize: 40, color: Color(0xFFFFFF00),),), backgroundColor: Color(0xFF702963),),
          body: InteractiveViewer(
              child: Center(
                  child: Image.asset('images/Technoedge_Map_PurpleBG.png')))),
    );
  }
}
