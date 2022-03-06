import 'dart:async';
import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:on_sight/services/reactive_packages/reactive_state.dart';
import 'package:on_sight/services/onsight.dart';

class OnsightServicesScanner implements ReactiveState<SensorScannerState> {
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
  final StreamController<SensorScannerState> _bleStreamController =
      StreamController();
  // for subscriptions
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  final _bleDevices = <DiscoveredDevice>[];
  List<SensorCharacteristics> _accelerometerValues = [];
  List<SensorCharacteristics> _magnetometerValues = [];
  List<SensorCharacteristics> _results = [];

  @override
  Stream<SensorScannerState> get state => _bleStreamController.stream;

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
      scanMode: ScanMode.balanced,
    )
        .listen((device) {
      performLocalisation(
        areDevicesUpdated(device),
        // TODO: edit true/false to indicate if we are testing or not
        isDebugMode: true,
      );
    }, onError: (Object e) => print('Device scan fails with error: $e')));
    _pushState();
  }

  void _pushState() {
    _bleStreamController.add(
      SensorScannerState(
          discoveredDevices: _bleDevices,
          result: _results,
          acceleration: _accelerometerValues,
          magnetometer: _magnetometerValues,
          // startscan is called in init, resulting in streams being subscribed automatically.
          // thus if _streamSubscriptions.isNotEmpty, it means that scanning is in progress.
          scanIsInProgress: _streamSubscriptions.isNotEmpty),
    );
  }

  Future<void> stopScan() async {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
    _pushState();
  }

  Future<void> dispose() async {
    await _bleStreamController.close();
  }

  void performLocalisation(bool hasUpdate, {required bool isDebugMode}) {
    if (_accelerometerValues.isEmpty || _magnetometerValues.isEmpty) return;

    DateTime currTime = DateTime.now();
    String stringTime =
        '${currTime.hour}:${currTime.minute}:${currTime.second}.${currTime.millisecond}';

    // for localisation
    LinkedHashMap<String, num> tempRssi = LinkedHashMap();
    // for writing to csv
    LinkedHashMap<String, num> tempAllRssi = LinkedHashMap();
    // for localisation use
    LinkedHashMap<String, dynamic> rawData = LinkedHashMap();
    // for storing to csv
    LinkedHashMap<String, dynamic> allRawData = LinkedHashMap();
    // for storing of result of localisation
    LinkedHashMap<String, dynamic> result = LinkedHashMap();
    // to check if system is ready
    bool isReady = (hasUpdate && (_bleDevices.length >= 3));

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

    // update location
    if (isDebugMode) {
      // Placeholder values
      // used in localisation
      tempRssi.addEntries([
        MapEntry("DC:A6:32:A0:C9:9E", -67.0),
        MapEntry("DC:A6:32:A0:C8:30", -72.0),
        MapEntry("DC:A6:32:A0:B7:4D", -73.0),
      ]);
      // store to csv
      tempAllRssi.addEntries([
        MapEntry("DC:A6:32:A0:C9:9E", -67.0),
        MapEntry("DC:A6:32:A0:C8:30", -72.0),
        MapEntry("DC:A6:32:A0:B7:4D", -73.0),
      ]);
    } else {
      // updates only when 3 or more devices are found
      if (isReady) {
        // for localisation use
        tempRssi.addEntries([
          MapEntry(_bleDevices[0].id, _bleDevices[0].rssi),
          MapEntry(_bleDevices[1].id, _bleDevices[1].rssi),
          MapEntry(_bleDevices[2].id, _bleDevices[2].rssi),
        ]);
        // for writing to csv
        for (int i = 0; i < _bleDevices.length; i++) {
          tempAllRssi.addEntries([
            MapEntry(_bleDevices[i].id, _bleDevices[i].rssi),
          ]);
        }
      }
    }

    // for localisation use
    rawData.addEntries([
      MapEntry('rssi', tempRssi),
      MapEntry('accelerometer', tempAcc),
      MapEntry('magnetometer', tempMag),
    ]);

    // for storing to csv
    allRawData.addEntries([
      MapEntry('time', stringTime),
      MapEntry('rssi', tempAllRssi),
      MapEntry('accelerometer', tempAcc),
      MapEntry('magnetometer', tempMag),
    ]);

    if (isDebugMode || isReady) {
      result = _onSight.localisation(rawData);

      _results = <SensorCharacteristics>[
        SensorCharacteristics(name: 'x_coor', value: result['x_coordinate']),
        SensorCharacteristics(name: 'y_coor', value: result['y_coordinate']),
        SensorCharacteristics(
          name: 'direction',
          value: Direction(direction: result['direction']).convertToDouble(),
        ),
      ];
      _pushState();

      // publish to mqtt
      publishMqttPayload(allRawData, result);

      // print for debugging purposes
      print(
        SensorScannerState(
                discoveredDevices: _bleDevices,
                result: _results,
                acceleration: _accelerometerValues,
                magnetometer: _magnetometerValues,
                // startscan is called in init, resulting in streams being subscribed automatically.
                // thus if _streamSubscriptions.isNotEmpty, it means that scanning is in progress.
                scanIsInProgress: _streamSubscriptions.isNotEmpty)
            .toString(),
      );
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
          next.rssi.compareTo(curr.rssi)); // sort the rssi in descending order
      _pushState();
    }

    return hasUpdate;
  }

  void publishMqttPayload(
    LinkedHashMap<String, dynamic> rawData,
    LinkedHashMap<String, dynamic> result,
  ) {
    LinkedHashMap<String, dynamic> mqttPayload = LinkedHashMap();

    mqttPayload.addEntries(rawData.entries);
    mqttPayload.addEntries(result.entries);

    _onSight.mqttPublish(mqttPayload, mode: Mode.DATA_PIPELINE);
  }
}

@immutable
class SensorScannerState {
  const SensorScannerState({
    required this.discoveredDevices, // bluetooth devices
    required this.result, // results from localisation
    required this.acceleration, //acceleration value
    required this.magnetometer, // magneto value
    required this.scanIsInProgress, // checks if scanning is in progress
  });

  final List<DiscoveredDevice> discoveredDevices;
  final List<SensorCharacteristics> result;
  final List<SensorCharacteristics> acceleration;
  final List<SensorCharacteristics> magnetometer;
  final bool scanIsInProgress;

  String toString() {
    Map<String, int> dd = {};
    if (discoveredDevices.length >= 3) {
      dd = {
        discoveredDevices[0].id: discoveredDevices[0].rssi,
        discoveredDevices[1].id: discoveredDevices[1].rssi,
        discoveredDevices[2].id: discoveredDevices[2].rssi,
      };
    }
    List<double> res = [
      result[0].value,
      result[1].value,
    ];
    List<double> acc = [
      acceleration[0].value,
      acceleration[1].value,
      acceleration[2].value,
    ];
    List<double> mag = [
      magnetometer[0].value,
      magnetometer[1].value,
      magnetometer[2].value,
    ];
    String progress = scanIsInProgress ? 'True' : 'False';

    return 'discoveredDevices = ${dd},\nacceleration = ${acc},\nmagnetometer = ${mag},\nresult = ${res},\nscanIsInProgress = ${progress}';
  }
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
