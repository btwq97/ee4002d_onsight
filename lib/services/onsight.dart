import 'dart:collection';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:on_sight/backend/database.dart';
import 'package:on_sight/localisation/localisation.dart';
import 'package:on_sight/navigations/navigations.dart';
import 'package:on_sight/mqtt/mqtt.dart';

enum Mode {
  DATA_PIPELINE,
  SYSTEM_TESTING,
}

class OnSight {
  // ==== Private Methods ====
  OnSight();

  late MyDatabase _db;
  late Localisation _lc;
  late Mqtt _mq;

  // ==== Public Methods ====
  late MyShortestPath sp;

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
    _db = MyDatabase(
      region: dotenv.env['awsRegion'].toString(),
      endPointUrl: dotenv.env['awsEndPoint'].toString(),
    );
    await _db.init();

    // MQTT
    _mq = Mqtt(
      host: dotenv.env['mqttHost'].toString(),
      username: dotenv.env['mqttUsername'].toString(),
      password: dotenv.env['mqttPassword'].toString(),
    );
    await _mq.init();

    // Localisation
    _lc = Localisation(dbObj: _db);

    // Shortest Path
    sp = MyShortestPath(dbObj: _db);
  }

  /// TODO: TO delete in production code
  /// To test if shortest path algorithm runs properly
  void _testShortestPath(List<double> start, List<double> goal) {
    sp.setup(start, goal);
    print(sp.determineShortestPath());
  }

  /// Wrapper function for localisation.
  ///
  /// Inputs:
  /// 1) rawData [LinkedHashMap<String, dynamic>] -
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
  /// 1) estimated position [LinkedHashMap<String,dynamic>]
  LinkedHashMap<String, dynamic> localisation(
    LinkedHashMap<String, dynamic> rawData,
  ) {
    return _lc.localisation(rawData);
  }

  /// Wrapper function for publishing data points to mqtt server.
  ///
  /// Inputs:
  /// 1) payload [LinkedHashMap<String, dynamic>] -
  /// e.g. {
  ///         "rssi": {
  ///               "9d9214f8-8870-43dd-a496-401765bf7866": -61.6888,
  ///               "40409a6a-ec8b-4d24-b496-9bd2e78c044f": -73.5868,
  ///               "87ccf436-0f86-4dfe-80f9-9ff731033620": -75.7231
  ///         },
  ///         "accelerometer": [-33.57, 86.31, 12.2],
  ///         "magnetometer": [-33.57, 86.31, 12.2],
  ///         "x_coordinate": -53.600680425231964,
  ///         "y_coordinate": 200.09818188520637,
  ///         "direction":"North"
  ///      }
  /// 2) topic [String] - default is 'fyp/test/datapipeline'.
  /// 3) mode [Mode]:
  ///    - 0x1: 'fyp/test/datapipeline'
  ///    - 0x2: 'fyp/test/sc'
  ///
  /// Returns:
  /// 1) None.
  void mqttPublish(
    LinkedHashMap<String, dynamic> payload, {
    String topic = 'fyp/test/datapipeline',
    required Mode mode,
  }) {
    _mq.publish(payload, topic: topic, mode: mode);
  }

  /// Function to retrieve known uuid from database.
  ///
  /// Inputs:
  /// None.
  ///
  /// Return:
  /// knownUuid [List<Uuid>].
  List<Uuid> getKnownUuid() {
    return _db.getKnownUuid();
  }

  /// Function to retrieve known MAC address from database.
  ///
  /// Inputs:
  /// None.
  ///
  /// Return:
  /// knownUuid [List<String>].
  List<String> getKnownMac() {
    return _db.getKnownMac();
  }

  void disconnnectFromMqttServer() {
    _mq.disconnnectFromMqttServer();
  }

  Future<void> ConnnectToMqttServer() async {
    await _mq.init();
  }
}
