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
    _ble_counter = 0;
    _mag_counter = 0;
  }

  final FlutterReactiveBle _ble;
  final OnSight _onSight;
  bool _hasUpdated = false;
  List<String> _knownDevices = [];
  final StreamController<SensorScannerState> _bleStreamController =
      StreamController();
  // for subscriptions
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  final _bleDevices = <DiscoveredDevice>[];
  List<SensorCharacteristics> _magnetometerValues = [];
  List<ResultCharactersitics> _results = [];

  num _ble_counter = 0; // force ble duty cycle
  num _mag_counter = 0; // force mag duty cycle

  @override
  Stream<SensorScannerState> get state => _bleStreamController.stream;

  void startScan(List<Uuid> serviceIds) {
    // reset all subscriptions
    _bleDevices.clear();
    _streamSubscriptions.clear();
    _ble_counter = 0;
    _bleDevices.clear();
    _mag_counter = 0;
    _magnetometerValues.clear();
    _results.clear();
    _onSight.resetLocalisation();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }

    // for mag
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          if (_magnetometerValues.isEmpty) {
            _magnetometerValues = <SensorCharacteristics>[
              SensorCharacteristics(name: 'mag_x', value: event.x),
              SensorCharacteristics(name: 'mag_y', value: event.y),
              SensorCharacteristics(name: 'mag_z', value: event.z),
            ];
          } else {
            // finding moving average
            List<SensorCharacteristics> prev_mag_value = _magnetometerValues;
            List<SensorCharacteristics> avg_mag_value = <SensorCharacteristics>[
              SensorCharacteristics(
                name: 'mag_x',
                value: ((prev_mag_value[0].value + event.x) / 2),
              ),
              SensorCharacteristics(
                name: 'mag_y',
                value: ((prev_mag_value[1].value + event.y) / 2),
              ),
              SensorCharacteristics(
                name: 'mag_z',
                value: ((prev_mag_value[2].value + event.z) / 2),
              ),
            ];
            // update average value
            _magnetometerValues = avg_mag_value;
          }
          _pushState(fromMag: true, fromBle: false);
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
      _hasUpdated =
          _areDevicesUpdated(device); // updates if there are new devices
    }, onError: (Object e) => print('Device scan fails with error: $e')));
  }

  void _pushState({
    required bool fromMag,
    required bool fromBle,
  }) {
    _bleStreamController.add(
      SensorScannerState(
          discoveredDevices: _bleDevices,
          result: _results,
          magnetometer: _magnetometerValues,
          // startscan is called in init, resulting in streams being subscribed automatically.
          // thus if _streamSubscriptions.isNotEmpty, it means that scanning is in progress.
          scanIsInProgress: _streamSubscriptions.isNotEmpty),
    );

    performLocalisation(
      hasUpdate: _hasUpdated,
      // TODO: true if in debug mode, false if in actual test mode
      isDebugMode: true,
      fromBle: fromBle,
      fromMag: fromMag,
    );
  }

  Future<void> stopScan() async {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
    _ble_counter = 0;
    _bleDevices.clear();
    _mag_counter = 0;
    _magnetometerValues.clear();
    _results.clear();
    _onSight.resetLocalisation();
    _pushState(fromBle: false, fromMag: false);
  }

  Future<void> dispose() async {
    await _bleStreamController.close();
  }

  // TODO: Delete if testing for the new performLocalisation function is successful
  // void performLocalisation({
  //   required bool hasUpdate,
  //   required bool isDebugMode,
  //   required bool isBleScanner,
  //   required bool isMagnetometer,
  // }) {
  //   if (_magnetometerValues.isEmpty) return;

  //   DateTime currTime = DateTime.now();
  //   String stringTime =
  //       '${currTime.hour}:${currTime.minute}:${currTime.second}.${currTime.millisecond}';

  //   final num _BLE_READ = (isDebugMode ? 0 : 25);
  //   LinkedHashMap<String, num> currRssiAll = LinkedHashMap();
  //   LinkedHashMap<String, dynamic> currRawDataAll = LinkedHashMap();
  //   // for storing of result of localisation
  //   LinkedHashMap<String, dynamic> result = LinkedHashMap();
  //   // to check if system is ready
  //   bool isReady = (hasUpdate &&
  //       (_bleDevices.length >= 3) &&
  //       (_ble_counter >= _BLE_READ));
  //   // update magnetometer
  //   List<num> currMag = [
  //     _magnetometerValues[0].value,
  //     _magnetometerValues[1].value,
  //     _magnetometerValues[2].value,
  //   ];

  //   // update location
  //   if (isDebugMode) {
  //     // using placeholder values
  //     currRssiAll.addEntries([
  //       MapEntry("DC:A6:32:A0:C9:9E", -53.0),
  //       MapEntry("DC:A6:32:A0:C8:30", -49.0),
  //       MapEntry("DC:A6:32:A0:B7:4D", -48.0),
  //       MapEntry("DC:A6:32:A0:C6:17", -70.0),
  //       MapEntry("DC:A6:32:A0:C9:3B", -65.0),
  //       MapEntry("DC:A6:32:A0:C9:5C", -66.0),
  //     ]);
  //   } else {
  //     // using actual values
  //     if (isReady) {
  //       for (int i = 0; i < _bleDevices.length; i++) {
  //         currRssiAll.addEntries([
  //           MapEntry(_bleDevices[i].id, _bleDevices[i].rssi),
  //         ]);
  //       }
  //     }
  //   }

  //   if ((isDebugMode && _ble_counter >= _BLE_READ) || isReady) {
  //     // update both bearing and est position
  //     currRawDataAll.addEntries([
  //       MapEntry('time', stringTime),
  //       MapEntry('rssi', currRssiAll),
  //       MapEntry('magnetometer', currMag),
  //     ]);
  //   } else {
  //     // update bearing only
  //     currRawDataAll.addEntries([
  //       MapEntry('time', stringTime),
  //       MapEntry('magnetometer', currMag),
  //     ]);
  //   }

  //   result = _onSight.localisation(currRawDataAll);

  //   _results = <ResultCharactersitics>[
  //     ResultCharactersitics(
  //       name: 'x_coor',
  //       value: result['x_coordinate']?.toString() ?? 'Error',
  //     ),
  //     ResultCharactersitics(
  //       name: 'y_coor',
  //       value: result['y_coordinate']?.toString() ?? 'Error',
  //     ),
  //     ResultCharactersitics(
  //       name: 'zone',
  //       value: result['direction']['zone'] ?? 'Error',
  //     ),
  //     ResultCharactersitics(
  //       name: 'angle',
  //       value: result['direction']['angle'] ?? 'Error',
  //     ),
  //     ResultCharactersitics(
  //       name: 'compass_heading',
  //       value: result['direction']['compass_heading'] ?? 'Error',
  //     ),
  //     ResultCharactersitics(
  //       name: 'suggested_direction',
  //       value: result['direction']['suggested_direction'] ?? 'Error',
  //     ),
  //   ];

  //   if ((isDebugMode && _ble_counter >= _BLE_READ) || isReady) {
  //     // TODO: remove MQTT if not needed
  //     publishMqttPayload(currRawDataAll, result);
  //     // reset all storage containters
  //     _bleDevices.clear();
  //     _magnetometerValues.clear();
  //     _ble_counter = 0;
  //   }

  //   if (isBleScanner || isDebugMode) {
  //     // updates counter only when _pushState is called from a bleDevice update
  //     _ble_counter += 1;
  //   }
  // }

  void performLocalisation({
    required bool hasUpdate,
    required bool isDebugMode,
    required bool fromMag,
    required bool fromBle,
  }) {
    if (_magnetometerValues.isEmpty) return;

    DateTime currTime = DateTime.now();
    String stringTime =
        '${currTime.hour}:${currTime.minute}:${currTime.second}.${currTime.millisecond}';

    // duty cycle for ble devices
    final num _BLE_READ = 30;
    // duty cycle for magnetometer
    final num _MAG_READ = 5;

    LinkedHashMap<String, num> currRssiAll = LinkedHashMap();
    LinkedHashMap<String, dynamic> currRawDataAll = LinkedHashMap();
    // for storing of result of localisation
    LinkedHashMap<String, dynamic> result = LinkedHashMap();
    LinkedHashMap<String, dynamic> tmpResult = LinkedHashMap();
    // to check if system is ready
    bool isReady =
        (hasUpdate && (_bleDevices.length >= 3) && (_ble_counter >= _BLE_READ));
    // update magnetometer
    List<num> currMag = [
      _magnetometerValues[0].value,
      _magnetometerValues[1].value,
      _magnetometerValues[2].value,
    ];

    // In debugMode
    if (isDebugMode) {
      // create placeholder rssi values
      currRssiAll.addEntries([
        MapEntry("DC:A6:32:A0:C9:9E", -53.0),
        MapEntry("DC:A6:32:A0:C8:30", -49.0),
        MapEntry("DC:A6:32:A0:B7:4D", -48.0),
        MapEntry("DC:A6:32:A0:C6:17", -70.0),
        MapEntry("DC:A6:32:A0:C9:3B", -65.0),
        MapEntry("DC:A6:32:A0:C9:5C", -66.0),
      ]);

      // update rawData
      if (_ble_counter >= _BLE_READ) {
        // update both bearing and est position
        currRawDataAll.addEntries([
          MapEntry('time', stringTime),
          MapEntry('rssi', currRssiAll),
          MapEntry('magnetometer', currMag),
        ]);

        // perform localisation
        tmpResult = _onSight.localisation(currRawDataAll);
        _results = _formatResult(tmpResult);

        // TODO: remove MQTT if not needed
        publishMqttPayload(currRawDataAll, result);
        _bleDevices.clear(); // reset container
        _ble_counter = 0; // reset counter
      } else {
        _ble_counter += 1;
      }

      if (fromMag) {
        if (_mag_counter >= _MAG_READ) {
          // update bearing only
          currRawDataAll.addEntries([
            MapEntry('time', stringTime),
            MapEntry('magnetometer', currMag),
          ]);

          // perform localisation
          LinkedHashMap<String, dynamic> tmpResult =
              _onSight.localisation(currRawDataAll);
          _results = _formatResult(tmpResult);

          _mag_counter = 0; // reset counter
          _magnetometerValues.clear(); // reset container
        } else {
          _mag_counter += 1;
        }
      }
    }
    // In non-debugMode
    else {
      if (fromBle) {
        // using actual values
        if (isReady) {
          for (int i = 0; i < _bleDevices.length; i++) {
            currRssiAll.addEntries([
              MapEntry(_bleDevices[i].id, _bleDevices[i].rssi),
            ]);
          }
          // update both bearing and est position
          currRawDataAll.addEntries([
            MapEntry('time', stringTime),
            MapEntry('rssi', currRssiAll),
            MapEntry('magnetometer', currMag),
          ]);

          // perform localisation
          tmpResult = _onSight.localisation(currRawDataAll);
          _results = _formatResult(tmpResult);

          // TODO: remove MQTT if not needed
          publishMqttPayload(currRawDataAll, result);
          _bleDevices.clear(); // reset container
          _ble_counter = 0; // reset counter
        } else {
          _ble_counter += 1;
        }
      }

      if (fromMag) {
        if (_mag_counter >= _MAG_READ) {
          // update bearing only
          currRawDataAll.addEntries([
            MapEntry('time', stringTime),
            MapEntry('magnetometer', currMag),
          ]);

          // perform localisation
          LinkedHashMap<String, dynamic> tmpResult =
              _onSight.localisation(currRawDataAll);
          _results = _formatResult(tmpResult);

          _mag_counter = 0; // reset counter
          _magnetometerValues.clear(); // reset container
        } else {
          _mag_counter += 1;
        }
      }
    }
  }

  List<ResultCharactersitics> _formatResult(
      LinkedHashMap<String, dynamic> result) {
    return <ResultCharactersitics>[
      ResultCharactersitics(
        name: 'x_coor',
        value: result['x_coordinate'].toString(),
      ),
      ResultCharactersitics(
        name: 'y_coor',
        value: result['y_coordinate'].toString(),
      ),
      ResultCharactersitics(
        name: 'zone',
        value: result['direction']['zone'] ?? 'Error',
      ),
      ResultCharactersitics(
        name: 'angle',
        value: result['direction']['angle'] ?? 'Error',
      ),
      ResultCharactersitics(
        name: 'compass_heading',
        value: result['direction']['compass_heading'] ?? 'Error',
      ),
      ResultCharactersitics(
        name: 'suggested_direction',
        value: result['direction']['suggested_direction'] ?? 'Error',
      ),
    ];
  }

  bool _areDevicesUpdated(DiscoveredDevice device) {
    int knownDeviceIndex = _bleDevices.indexWhere((d) => d.id == device.id);
    bool hasUpdate = false;

    if (knownDeviceIndex >= 0) {
      DiscoveredDevice prev_device = _bleDevices[knownDeviceIndex];
      // getting moving avg rssi
      DiscoveredDevice avgDevice = DiscoveredDevice(
        id: prev_device.id,
        name: prev_device.name,
        serviceData: prev_device.serviceData,
        serviceUuids: prev_device.serviceUuids,
        rssi: (prev_device.rssi + device.rssi) ~/ 2,
        manufacturerData: prev_device.manufacturerData,
      );
      _bleDevices[knownDeviceIndex] = avgDevice;
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
      _pushState(fromBle: true, fromMag: false);
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
    required this.magnetometer, // magneto value
    required this.scanIsInProgress, // checks if scanning is in progress
  });

  final List<DiscoveredDevice> discoveredDevices;
  final List<ResultCharactersitics> result;
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
    List<String> res = [
      result[0].value,
      result[1].value,
    ];

    List<num> mag = [
      magnetometer[0].value,
      magnetometer[1].value,
      magnetometer[2].value,
    ];
    String progress = scanIsInProgress ? 'True' : 'False';

    return 'discoveredDevices = ${dd},\nmagnetometer = ${mag},\nresult = ${res},\nscanIsInProgress = ${progress}';
  }
}

class SensorCharacteristics {
  const SensorCharacteristics({
    required this.name,
    required this.value,
  });

  final String name;
  final num value;
}

class ResultCharactersitics {
  const ResultCharactersitics({
    required this.name,
    required this.value,
  });

  final String name;
  final String value;
}
