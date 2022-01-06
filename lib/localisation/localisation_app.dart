import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'localisation_dynamodb.dart';
import 'localisation_localisation.dart';
import 'localisation_mqtt.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:on_sight/connectivity/bluetooth_main.dart';
import 'package:on_sight/connectivity/bluetooth_widgets.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

// TODO:
// 1) add in functionalities to retrieve magnetometer and accelerometer here.
class LocalisationAppPage extends StatefulWidget {
  final appEngine;

  LocalisationAppPage(this.appEngine);

  @override
  _LocalisationAppPageState createState() =>
      _LocalisationAppPageState(this.appEngine);
}

class _LocalisationAppPageState extends State<LocalisationAppPage> {
  final appEngine;

  _LocalisationAppPageState(this.appEngine);

  List<double>? _accelerometerValues;
  List<double>? _magnetometerValues;
  List<double>? _magnetometerValuesX;
  List<double>? _magnetometerValuesY;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<String> knownUuid = [
    '60:C0:BF:26:E0:DE',
    '60:C0:BF:26:E0:8A',
    '60:C0:BF:26:DF:63',
    '60:C0:BF:26:E0:A5'
  ];
  Map<String, int> topFour = {};
  Map<String, dynamic> resultsLocalisation = {};//   "60:C0:BF:26:E0:00" stuck at -17dBm
  //List<String> knownUuid = ['FDD1BB34-B18E-5F7A-7019-3A5F3FD15957', '641508E6-7E97-1BCE-0317-652200C4DD86', '438ED97B-C158-71D4-D5E6-B10136FDCE75', '3B55A5F1-FD5D-8198-63C9-B7D91E8BBE0D']; //   "60:C0:BF:26:E0:00" stuck at -17dBm
  //List<double>? _rssiValues;
  // Map<String, int> knownUuid = {
  //   "60:C0:BF:26:E0:DE": 0,
  //   "60:C0:BF:26:E0:00": 0, //stuck at -17dBm
  //   "60:C0:BF:26:E0:8A": 0,
  //   "60:C0:BF:26:DF:63": 0,
  //   "60:C0:BF:26:E0:A5": 0,
  // };

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final magnetometer =
        _magnetometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    // final topthreerssi =
    // _rssiValues?.map((int v) => v.toStringAsFixed(1)).toList();
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
                Text('Accelerometer: $accelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Magnetometer: $magnetometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('$topFour'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0),
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
          GestureDetector(
            onTap: () {
              Map<String, dynamic> rawData = {};
              rawData['rssi'] = {};
              topFour.forEach((k, v) => rawData['rssi'][k] = v.toDouble());
              rawData['accelerometer'] = _accelerometerValues;
              rawData['magnetometer'] = _magnetometerValues;
              print(rawData);
              // this.appEngine.mqttPublish(rawData, 'rssi');
              resultsLocalisation = appEngine.localisation(rawData);
              print(resultsLocalisation);
            },
            child: Container(
              child: Center(
                child: Text(
                  'SEND DATA',
                  style: kBottomButtonTextStyle,
                ),
              ),
              color: kBottomContainerColour,
              margin: EdgeInsets.only(top: 10.0),
              //padding: EdgeInsets.only(bottom: 20.0),
              width: double.infinity,
              height: kBottomContainerHeight,
            ),
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
  }

  @override
  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
            //print('Accelerometer: $_accelerometerValues');
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
    // _streamSubscriptions.add(
    //   magnetometerEvents.listen(
    //         (MagnetometerEvent event) {
    //       setState(() {
    //         _magnetometerValuesX = <double>[event.x];
    //         //print('Magnetometer X: $_magnetometerValuesX');
    //       });
    //     },
    //   ),
    // );
    // _streamSubscriptions.add(
    //   magnetometerEvents.listen(
    //         (MagnetometerEvent event) {
    //       setState(() {
    //         _magnetometerValuesY = <double>[event.y];
    //         // print('Magnetometer Y: $_magnetometerValuesY');
    //       });
    //     },
    //   ),
    // );

    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    // while (true) {
    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // sort results from least negative to most negative
      results
          .sort((a, b) => ((b.rssi).toDouble()).compareTo((a.rssi).toDouble()));

      for (ScanResult r in results) {
        if (topFour.length == 4) {
          //print(topFour);
          // flutterBlue.stopScan();
          break;
        }
        for (String uuid in knownUuid) {
          // print('uuid = $uuid, scanned = ${r.device.id}');
          if (uuid == r.device.id.toString()) {
            topFour[uuid] = r.rssi;
            //print(topFour);
          }
        }
      }
    });
    // }

    flutterBlue.stopScan();
  }
}

// 3) AppEngine
class AppEngine {
  // late WrapperDynamoDB _db;
  late Localisation _lc;
  // late Mqtt _mq;

  // ==== Private Methods ====
  AppEngine();

  // ==== Public Methods ====
  /// Runs the localisation algorithm
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) None.
  Future start() async {
    // DotEnv
    await dotenv.load(fileName: './lib/assets/.env');

    // DynamoDB
    // _db = WrapperDynamoDB(
    //     dotenv.env['awsRegion'].toString(),
    //     dotenv.env['awsEndPoint'].toString(),
    //     dotenv.env['awsTableName'].toString(),
    //     dotenv.env['awsPrimaryKey'].toString(),
    //     dotenv.env['awsVenue'].toString()); // Only instance of db
    // await _db.init(); // must await for data to be pulled successfully

    // print('${dotenv.env['mqttHost'].toString()}');
    //
    // // MQTT
    // _mq = Mqtt(
    //     dotenv.env['mqttHost'].toString(),
    //     dotenv.env['mqttUsername'].toString(),
    //     dotenv.env['mqttPassword'].toString());
    // await _mq.init();

    // Localisation
    // _lc = Localisation(_db);
    _lc = Localisation();
  }

  /// Wrapper function for localisation.
  ///
  /// Inputs:
  /// 1) rawData [Map<String, dynamic>] -
  /// e.g. {
  ///         'rssi': {
  ///           'd94250a2-c73a-4249-9a1e-4abb2643078a': -74.35,
  ///           '87ccf436-0f86-4dfe-80f9-9ff731033620': -65.25,
  ///           '9d9214f8-8870-43dd-a496-401765bf7866': -65.75
  ///         },
  ///         'accelerometer': $_accelerometerValues,
  ///         'magnetometer': [$_magnetometerValuesX, $_magnetometerValuesY]
  ///      }
  ///
  /// Returns:
  /// 1) None.
  Map<String, dynamic> localisation(Map<String, dynamic> rawData) {
    return _lc.localisation(rawData);
  }

  /// Wrapper function for publishing data points to mqtt server.
  ///
  /// Inputs:
  /// 1) rawData [Map<String, dynamic>] -
  /// e.g. {
  ///         'x_coordinate': $_magnetometerValuesX,
  ///         'y_coordinate': $_magnetometerValuesY,
  ///         'direction':direction
  ///      }
  /// 2) mode [String] - either 'rssi' or 'result'.
  /// 2) topic [String] - default is 'test/pub'.
  ///
  /// Returns:
  /// 1) None.
  void mqttPublish(Map<String, dynamic> rawData, String mode,
      {String topic = 'test/pub'}) {
    // _mq.publish(rawData, mode, topic: topic);
  }
}
