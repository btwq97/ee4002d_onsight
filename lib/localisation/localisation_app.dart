import 'package:flutter/material.dart';

import 'localisation_dynamodb.dart';
import 'localisation_localisation.dart';
import 'localisation_mqtt.dart';
import 'localisation_mqtt.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:math' as math;

// TODO:
// 1) add in functionalities to retrieve magnetometer and accelerometer here.
class LocalisationAppPage extends StatefulWidget {
  @override
  _LocalisationAppPageState createState() => _LocalisationAppPageState();
}

class _LocalisationAppPageState extends State<LocalisationAppPage> {
  List<double>? _accelerometerValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  //List<String>? knownUuid = ['60:C0:BF:26:E0:DE', '60:C0:BF:26:E0:00', '60:C0:BF:26:E0:8A', '60:C0:BF:26:DF:63', '60:C0:BF:26:E0:A5'];
  //List<double>? _rssiValues;
  Map<String, int> knownUuid = {
    "60:C0:BF:26:E0:DE": 0,
    "60:C0:BF:26:E0:00": 0,
    "60:C0:BF:26:E0:8A": 0,
    "60:C0:BF:26:DF:63": 0,
    "60:C0:BF:26:E0:A5": 0,
  };



  @override
  Widget build(BuildContext context) {
    final accelerometer =
    _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final magnetometer =
    _magnetometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
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
            _accelerometerValues = <double>[event.x];
            print(_accelerometerValues);
          });
        },
      ),
    );
    _streamSubscriptions.add(
      magnetometerEvents.listen(
            (MagnetometerEvent event) {
          setState(() {
            _magnetometerValues = <double>[event.x, event.y];
            print(_magnetometerValues);
          });
        },
      ),
    );
  }
}

// 2) add in functionalities to retrieve uuid and rssi here.


// 3) AppEngine
class AppEngine {
  late WrapperDynamoDB _db;
  late Localisation _lc;
  late Mqtt _mq;

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
    _db = WrapperDynamoDB(
        dotenv.env['awsRegion'].toString(),
        dotenv.env['awsEndPoint'].toString(),
        dotenv.env['awsTableName'].toString(),
        dotenv.env['awsPrimaryKey'].toString(),
        dotenv.env['awsVenue'].toString()); // Only instance of db
    await _db.init(); // must await for data to be pulled successfully

    // MQTT
    _mq = Mqtt(
        dotenv.env['mqttHost'].toString(),
        dotenv.env['mqttUsername'].toString(),
        dotenv.env['mqttPassword'].toString());
    await _mq.init();

    // Localisation
    _lc = Localisation(_db);
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
  ///         'accelerometer': 5,
  ///         'magnetometer': [-33.57, 86.31]
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
  ///         'x_coordinate': X,
  ///         'y_coordinate': Y,
  ///         'direction':direction
  ///      }
  /// 2) mode [String] - either 'rssi' or 'result'.
  /// 2) topic [String] - default is 'test/pub'.
  ///
  /// Returns:
  /// 1) None.
  void mqttPublish(Map<String, dynamic> rawData, String mode,
      {String topic = 'test/pub'}) {
    _mq.publish(rawData, mode, topic: topic);
  }
}

