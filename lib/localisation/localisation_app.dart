import 'dart:isolate';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:on_sight/constants.dart';
import 'package:on_sight/backend/backend_database.dart';
import 'package:on_sight/localisation/localisation_localisation.dart';
import 'package:on_sight/navigations/navigations_navigations.dart';
import 'package:on_sight/mqtt/mqtt_mqtt.dart';

// 1) add in functionalities to retrieve magnetometer and accelerometer here.
class LocalisationAppPage extends StatefulWidget {
  final OnSight;

  LocalisationAppPage(this.OnSight);

  @override
  _LocalisationAppPageState createState() =>
      _LocalisationAppPageState(this.OnSight);
}

class _LocalisationAppPageState extends State<LocalisationAppPage> {
  final OnSight;
  Isolate? isolate;

  // TODO: call from backend instead of hardcoding
  List<String> knownUuid = [
    '60:C0:BF:26:E0:DE',
    '60:C0:BF:26:E0:8A',
    '60:C0:BF:26:DF:63',
    '60:C0:BF:26:E0:A5',
    '60:C0:BF:26:E0:00'
  ]; // TO be changed once finalised with Zac

  Map<String, int> topFour = {};
  Map<String, dynamic> resultsLocalisation = {};
  List<double>? _accelerometerValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  // constructor
  _LocalisationAppPageState(this.OnSight);

  @override
  //This whole widget component to be removed in final run
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
              // this.OnSight.mqttPublish(rawData, 'rssi');
              resultsLocalisation = OnSight.localisation(rawData);
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

    /// Start background task
    _asyncInit();
    super.initState();

    FlutterBlue.instance.startScan(timeout: Duration(days: 4));
    // Listen to scan results
    var subscription = FlutterBlue.instance.scanResults.listen((results) {
      // sort results from least negative to most negative
      for (ScanResult r in results) {
        results.sort(
            (a, b) => ((b.rssi).toDouble()).compareTo((a.rssi).toDouble()));
        if (topFour.length == 6) {
          //print('scanned = ${r.device.id}');
          //print(topFour);
          print("Loop break");
          break;
        }
        print("Loop start");
        print('scanned = ${r.device.id}, RSSI = ${r.rssi}');

        for (String uuid in knownUuid) {
          //print('uuid = $uuid, scanned = ${r.device.id}');
          //print('uuid = $uuid, scanned = ${r.device.id}, RSSI = ${r.rssi}');
          if (uuid == r.device.id.toString()) {
            topFour[uuid] = r.rssi;
            //print(topFour);
          }
        }
        print("Loop end");
      }
    });

    //FlutterBlue.instance.stopScan();
  }

  _asyncInit() async {
    ReceivePort receivePort = ReceivePort();
    isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);

    receivePort.listen((dynamic data) {
      if (data is SendPort) {
        if (mounted) {
          data.send({
            /// Map data using key-value pair
            /// i.e. 'key' : String
          });
        }
      } else {
        if (mounted) {
          setState(() {
            /// Update data here as needed
          });
        }
      }
    });
  }

  _isolateEntry(dynamic d) async {
    final ReceivePort receivePort = ReceivePort();
    d.send(receivePort.sendPort);

    /// config contains the key-value pair from _asyncInit()
    final config = await receivePort.first;

    /// send bluetooth data you received
    d.send(topFour);
  }
}

// TODO:
// 1) add in functionalities to retrieve magnetometer here.
// 2) add in functionalities to retrieve uuid and rssi here.
class OnSight {
  late MyDatabase _db;
  late Localisation _lc;
  late Mqtt _mq;
  late MyShortestPath _sp;

  // ==== Private Methods ====
  OnSight();

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
    _db = MyDatabase(dotenv.env['awsRegion'].toString(),
        dotenv.env['awsEndPoint'].toString()); // Only instance of db
    await _db.init(); // must await for data to be pulled successfully

    // MQTT
    _mq = Mqtt(
        dotenv.env['mqttHost'].toString(),
        dotenv.env['mqttUsername'].toString(),
        dotenv.env['mqttPassword'].toString());
    await _mq.init();

    // Localisation
    _lc = Localisation(_db);

    // Shortest Path
    _sp = MyShortestPath(_db); // TODO: edit start and goal
    _testShortestPath([400.0, 0.0], [1500.0, 1200.0]);
  }

  /// TODO: TO delete in production code
  /// To test if shortest path algorithm runs properly
  void _testShortestPath(List<double> start, List<double> goal) {
    _sp.setup(start, goal);
    print(_sp.determineShortestPath());
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
