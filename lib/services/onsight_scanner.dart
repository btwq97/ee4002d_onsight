import 'dart:async';
import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:on_sight/services/reactive_packages/reactive_state.dart';
import 'package:on_sight/services/onsight.dart';

class OnsightServicesScanner implements ReactiveState<ServicesScannerState> {
  OnsightServicesScanner({
    required FlutterReactiveBle ble,
    required OnSight onSight,
  })  : _ble = ble,
        _onSight = onSight {
    _knownDevices = _onSight.getKnownMac();
  }

  final FlutterReactiveBle _ble;
  final OnSight _onSight;
  List<String> _knownDevices = [];
  final StreamController<ServicesScannerState> _bleStreamController =
      StreamController();

  // for subscriptions
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  final _bleDevices = <DiscoveredDevice>[];
  List<SensorCharacteristics> _accelerometerValues = [];
  List<SensorCharacteristics> _magnetometerValues = [];
  List<SensorCharacteristics> _results = [];

  // for navigations
  /// 1: Hungry Burger
  /// 2: Asian Delight
  /// 3: HK Cafe
  Map<int, List<double>> endGoal = {
    0x1: [1580, 1880],
    0x2: [1580, 1680],
    0x3: [1580, 1480]
  };
  List<double> startPoint = [];

  @override
  Stream<ServicesScannerState> get state => _bleStreamController.stream;

  /// TODO: integrate navigations here
  /// Add try-catch for scenario when 's' and 'g' are not present in textMap
  /// print our shortest path
  /// use path following algorithm to follow path
  void startScan(List<Uuid> serviceIds) {
    // reset all subscriptions
    _bleDevices.clear();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }

    // for acc
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _accelerometerValues = <SensorCharacteristics>[
            SensorCharacteristics(name: 'acc_x', value: event.x),
            SensorCharacteristics(name: 'acc_y', value: event.y),
            SensorCharacteristics(name: 'acc_z', value: event.z),
          ];
          _pushState();
        },
      ),
    );

    // for mag
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          _magnetometerValues = <SensorCharacteristics>[
            SensorCharacteristics(name: 'mag_x', value: event.x),
            SensorCharacteristics(name: 'mag_y', value: event.y),
            SensorCharacteristics(name: 'mag_z', value: event.z),
          ];
          _pushState();
        },
      ),
    );

    // for bluetooth
    _streamSubscriptions.add(_ble
        .scanForDevices(
      withServices: serviceIds,
      // TODO: change scanMode as necessary
      scanMode: ScanMode.lowLatency,
    )
        .listen((device) {
      performLocalisation(
        areDevicesUpdated(device),
        // TODO: edit true/false to indicate if we are testing or not
        isTesting: true,
      );
      _pushState();
    }, onError: (Object e) => print('Device scan fails with error: $e')));
  }

  void _pushState() {
    _bleStreamController.add(
      ServicesScannerState(
          discoveredDevices: _bleDevices,
          acceleration: _accelerometerValues,
          magnetometer: _magnetometerValues,
          result: _results,
          scanIsInProgress: _streamSubscriptions.isNotEmpty),
    );
  }

  Future<void> stopScan() async {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    startPoint.clear();
    _streamSubscriptions.clear();
    _pushState();
  }

  Future<void> dispose() async {
    await _bleStreamController.close();
  }

  void performLocalisation(bool hasUpdate, {required bool isTesting}) {
    if (_accelerometerValues.isEmpty || _magnetometerValues.isEmpty) return;

    DateTime currTime = DateTime.now();
    String stringTime =
        '${currTime.hour}:${currTime.minute}:${currTime.second}.${currTime.millisecond}';

    LinkedHashMap<String, num> _tempRssi = LinkedHashMap(); // for localisation
    LinkedHashMap<String, num> _tempAllRssi =
        LinkedHashMap(); // for writing to csv
    bool isReady = (hasUpdate && (_bleDevices.length >= 3));

    if (isTesting) {
      // Placeholder values
      _tempAllRssi.addEntries([
        MapEntry("DC:A6:32:A0:B7:4D", -65.0),
        MapEntry("DC:A6:32:A0:C9:9E", -71.3),
        MapEntry("DC:A6:32:A0:C9:3B", -68.0),
        MapEntry("DC:A6:32:A0:C8:30", -67.0),
        MapEntry("DC:A6:32:A0:C6:17", -78.3),
      ]);
    } else {
      // updates only when 3 or more devices are found
      if (isReady) {
        // TODO: Test if clearing cache memory will result in better result

        // for localisation use
        _tempRssi.addEntries([
          MapEntry(_bleDevices[0].id, _bleDevices[0].rssi),
          MapEntry(_bleDevices[1].id, _bleDevices[1].rssi),
          MapEntry(_bleDevices[2].id, _bleDevices[2].rssi),
        ]);
        // for writing to csv
        for (int i = 0; i < _bleDevices.length; i++) {
          _tempAllRssi.addEntries([
            MapEntry(_bleDevices[i].id, _bleDevices[i].rssi),
          ]);
        }
      }
    }

    // update acceleration
    List<double> tempAcc = [
      _accelerometerValues[0].value,
      _accelerometerValues[1].value,
      _accelerometerValues[2].value,
    ];

    // update magnetometer
    List<double> tempMag = [
      _magnetometerValues[0].value,
      _magnetometerValues[1].value,
      _magnetometerValues[2].value,
    ];

    // add sensor readings to rawData for localisation
    LinkedHashMap<String, dynamic> rawData =
        LinkedHashMap(); // for localisation use
    LinkedHashMap<String, dynamic> allRawData =
        LinkedHashMap(); // for storing to csv

    // for localisation use
    rawData.addEntries([
      MapEntry('rssi', _tempRssi),
      MapEntry('accelerometer', tempAcc),
      MapEntry('magnetometer', tempMag),
    ]);
    // for storing to csv
    allRawData.addEntries([
      MapEntry('rssi', _tempAllRssi),
      MapEntry('accelerometer', tempAcc),
      MapEntry('magnetometer', tempMag),
    ]);

    LinkedHashMap<String, dynamic> tempResult = LinkedHashMap();
    tempResult.addEntries([MapEntry('time', stringTime)]);

    if (isTesting) {
      tempResult.addEntries([
        MapEntry('x_coordinate', 650.0),
        MapEntry('y_coordinate', 30.35),
        MapEntry('direction', 'North'),
      ]);
    } else {
      if (isReady) {
        tempResult = _onSight.localisation(rawData);
      }
    }

    _results = <SensorCharacteristics>[
      SensorCharacteristics(name: 'x_coor', value: tempResult['x_coordinate']),
      SensorCharacteristics(name: 'y_coor', value: tempResult['y_coordinate']),
      SensorCharacteristics(
        name: 'direction',
        value: Direction(direction: tempResult['direction']).convertToDouble(),
      ),
    ];
    _pushState();

    if (isReady) {
      // shortest path
      // startPoint = [_results[0].value, _results[1].value];
      // if (_onSight.sp.setup(startPoint, endGoal[0x3] ?? []) == 0) {
      //   print('shortest path = ${_onSight.sp.determineShortestPath()}');
      // }

      // publish to mqtt
      publishMqttPayload(allRawData, tempResult);
    }
    if (isTesting) {
      publishMqttPayload(allRawData, tempResult);
    }
  }

  bool areDevicesUpdated(DiscoveredDevice device) {
    int knownDeviceIndex = _bleDevices.indexWhere((d) => d.id == device.id);
    bool hasUpdate = false;

    if (knownDeviceIndex >= 0) {
      _bleDevices[knownDeviceIndex] = device;
      hasUpdate = true; // update prev rssi value
    } else {
      if (_knownDevices.contains(device.id)) {
        _bleDevices.add(device);
        hasUpdate = true; // new rpi found
      }
    }

    if (hasUpdate) {
      _bleDevices.sort((curr, next) =>
          next.rssi.compareTo(curr.rssi)); // sort the rssi in descendind order
      _pushState();
    }

    return hasUpdate;
  }

  void publishMqttPayload(
    LinkedHashMap<String, dynamic> rawData,
    LinkedHashMap<String, dynamic> tempResult,
  ) {
    LinkedHashMap<String, dynamic> mqttPayload = LinkedHashMap();

    mqttPayload.addEntries(rawData.entries);
    mqttPayload.addEntries(tempResult.entries);

    _onSight.mqttPublish(mqttPayload, mode: Mode.DATA_PIPELINE);
  }
}

@immutable
class ServicesScannerState {
  const ServicesScannerState({
    required this.discoveredDevices, // bluetooth devices
    required this.acceleration, //acceleration value
    required this.magnetometer, // magneto value
    required this.result, // results from localisation
    required this.scanIsInProgress, // checks if scanning is in progress
  });

  final List<DiscoveredDevice> discoveredDevices;
  final List<SensorCharacteristics> acceleration;
  final List<SensorCharacteristics> magnetometer;
  final List<SensorCharacteristics> result;
  final bool scanIsInProgress;
}

class SensorCharacteristics {
  const SensorCharacteristics({
    required this.name,
    required this.value,
  });

  final String name;
  final double value;
}

class Direction {
  const Direction({
    required this.direction,
  });

  final String direction;

  /// Function to convert String direction to its corresponding double value.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Return:
  /// 1) [double].
  double convertToDouble() {
    if (this.direction == 'North')
      return 1.0;
    else if (this.direction == 'South')
      return 2.0;
    else if (this.direction == 'East')
      return 3.0;
    else if (this.direction == 'West')
      return 4.0;
    else if (this.direction == 'NorthEast')
      return 5.0;
    else if (this.direction == 'SouthEast')
      return 6.0;
    else if (this.direction == 'SouthWest')
      return 7.0;
    else // NorthWest
      return 8.0;
  }
}
