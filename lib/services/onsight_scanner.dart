import 'package:meta/meta.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:on_sight/services/reactive_packages/reactive_state.dart';
import 'package:on_sight/services/onsight.dart';

class ServicesScanner implements ReactiveState<ServicesScannerState> {
  ServicesScanner({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
    required OnSight onSight,
  })  : _ble = ble,
        _logMessage = logMessage,
        _onSight = onSight {
    _knownDevices = _onSight.getKnownMac();
  }

  final FlutterReactiveBle _ble;
  final OnSight _onSight;
  List<String> _knownDevices = [];
  final void Function(String message) _logMessage;
  final StreamController<ServicesScannerState> _bleStreamController =
      StreamController();

  // for subscriptions
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  final _bleDevices = <DiscoveredDevice>[];
  List<SensorCharacteristics> _accelerometerValues = [];
  List<SensorCharacteristics> _magnetometerValues = [];
  List<SensorCharacteristics> _results = [];

  @override
  Stream<ServicesScannerState> get state => _bleStreamController.stream;

  void startScan(List<Uuid> serviceIds) {
    // reset all subscriptions
    _logMessage('Start ble discovery');
    _bleDevices.clear();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }

    // for bluetooth
    _streamSubscriptions.add(_ble
        .scanForDevices(
      withServices: serviceIds,
      scanMode: ScanMode.lowPower,
    )
        .listen((device) {
      int knownDeviceIndex = _bleDevices.indexWhere((d) => d.id == device.id);
      performLocalisation(isNewDeviceFound(
        knownDeviceIndex,
        device,
      )); // note: localisation is only performed when 3 or more rssi is found
    }, onError: (Object e) => _logMessage('Device scan fails with error: $e')));

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
    _logMessage('Stop ble discovery');
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
    _pushState();
  }

  Future<void> dispose() async {
    await _bleStreamController.close();
  }

  void performLocalisation(bool hasUpdate) {
    // perform localisation when there is a change is rssi/uuid detection
    Map<String, dynamic> rawData = {};
    Map<String, num> _tempRssi =
        {}; // TODO: uncomment to pass actual values to rawData

    if (hasUpdate) {
      // updates only when 3 or more devices are found
      // TODO: Test if clearing cache memory will result in better result
      if (_bleDevices.length >= 3) {
        // update uuid and rssi
        _tempRssi.addEntries([
          MapEntry(_bleDevices[0].id.toString(), _bleDevices[0].rssi.toInt()),
          MapEntry(_bleDevices[1].id.toString(), _bleDevices[1].rssi.toInt()),
          MapEntry(_bleDevices[2].id.toString(), _bleDevices[2].rssi.toInt()),
        ]);

        // update acceleration
        List<double> tempAcc = [
          _accelerometerValues[0].value.toDouble(),
          _accelerometerValues[1].value.toDouble(),
          _accelerometerValues[2].value.toDouble(),
        ];

        // update magnetometer
        List<double> tempMag = [
          _magnetometerValues[0].value.toDouble(),
          _magnetometerValues[1].value.toDouble(),
          _magnetometerValues[2].value.toDouble(),
        ];

        // add sensor readings to rawData for localisation
        rawData.addEntries([
          MapEntry('rssi', _tempRssi),
          MapEntry('accelerometer', tempAcc),
          MapEntry('magnetometer', tempMag),
        ]);

        // TODO: uncomment to pass placeholder values to rawData for testing
        // rawData = {
        //   'rssi': {
        //     'DC:A6:32:A0:B7:4D': -74.35,
        //     'DC:A6:32:A0:C8:30': -65.25,
        //     'DC:A6:32:A0:C9:9E': -65.75
        //   },
        //   'accelerometer': [3.22, 5.5, 0.25],
        //   'magnetometer': [0.215, 9.172, 2.8155],
        // };

        // TODO: uncomment to send data to mqtt server
        _onSight.mqttPublish(rawData, 'rssi', topic: 'fyp/test/rssi');

        Map<String, dynamic> tempResult = _onSight.localisation(rawData);
        // TODO: uncomment to send data to mqtt server
        _onSight.mqttPublish(tempResult, 'result', topic: 'fyp/test/result');

        _results = <SensorCharacteristics>[
          SensorCharacteristics(
            name: 'x_coor',
            value: tempResult['x_coordinate'],
          ),
          SensorCharacteristics(
            name: 'y_coor',
            value: tempResult['y_coordinate'],
          ),
          SensorCharacteristics(
            name: 'direction',
            value:
                Direction(direction: tempResult['direction']).convertToDouble(),
          ),
        ];

        _pushState();
      }
    }
  }

  bool isNewDeviceFound(int knownDeviceIndex, DiscoveredDevice device) {
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
      _pushState();
    }

    return hasUpdate;
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
