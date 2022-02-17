import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:isolate';
import 'package:on_sight/connectivity/bluetooth_main.dart';
import 'package:on_sight/connectivity/bluetooth_widgets.dart';

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

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
                  child: Image.asset('images/Technoedge_Map_PurpleBG.png'))
          )),
    );
  }
}
