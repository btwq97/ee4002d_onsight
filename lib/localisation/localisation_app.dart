import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:on_sight/constants.dart';
import 'package:on_sight/services/onsight.dart';

class LocalisationAppPage extends StatefulWidget {
  final OnSight;

  LocalisationAppPage(this.OnSight);

  @override
  _LocalisationAppPageState createState() =>
      _LocalisationAppPageState(onsight: OnSight);
}

class _LocalisationAppPageState extends State<LocalisationAppPage> {
  late OnSight _onsight;

  List<String> knownUuid = [];
  Map<String, int> _testBeacons = {};
  Map<String, dynamic> resultsLocalisation = {};
  List<double>? _accelerometerValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  // constructor
  _LocalisationAppPageState({required OnSight onsight}) {
    _onsight = onsight;
    knownUuid = _onsight.getKnownStringUuid();
  }

  // TODO: connect scanned results to preform localisation
  void performMqttSend() {
    Map<String, dynamic> rawData = {};
    rawData['rssi'] = {};

    if (_testBeacons.length == 1) {
      // sorts _testBeacon
      var mapEntries = _testBeacons.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _testBeacons
        ..clear()
        ..addEntries(mapEntries);

      _testBeacons.forEach((k, v) => rawData['rssi'][k] = v);

      // reset _testBeacon
      _testBeacons.clear();
    }

    rawData['accelerometer'] = _accelerometerValues;
    rawData['magnetometer'] = _magnetometerValues;
    print('rawData = $rawData');

    // _onsight.mqttPublish(rawData, 'rssi');
    // resultsLocalisation = _onsight.localisation(rawData);
    // print(resultsLocalisation);
  }

  Future performBluetoothScan() async {
    _testBeacons.clear();
    await FlutterBlue.instance.startScan(timeout: Duration(seconds: 5));
  }

  @override
  // This whole widget component to be removed in final run
  // What you can expect here:
  // Pressing 'WHERE AM I' would trigger bluetooth scan for 5s before it TIMEOUT
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localisation'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $_accelerometerValues'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Magnetometer: $_magnetometerValues'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('$_testBeacons'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('$resultsLocalisation'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[],
            ),
          ),

          /// refresh
          GestureDetector(
            child: Container(
              child: Center(
                child: Text(
                  'WHERE AM I?',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
            onTap: () {
              performBluetoothScan();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _testBeacons.clear();
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          setState(() {
            _magnetometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(FlutterBlue.instance.scanResults.listen((results) {
      setState(() {
        for (ScanResult r in results) {
          String currUuid = r.device.id.toString();
          // if (knownUuid.contains(currUuid)) {
          //   _testBeacons[currUuid] = r.rssi;
          // }
          _testBeacons[currUuid] = r.rssi;

          // sorting results
          var tempMap = _testBeacons.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          _testBeacons
            ..clear()
            ..addEntries(tempMap);

          print("testBeacons = $_testBeacons");
        }
      });
    }));
  }
}
