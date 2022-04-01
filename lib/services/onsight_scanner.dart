import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:on_sight/services/reactive_packages/reactive_state.dart';
import 'package:on_sight/services/onsight.dart';

class OnsightLocalisationScanner implements ReactiveState<SensorScannerState> {
  OnsightLocalisationScanner({
    required FlutterReactiveBle ble,
    required OnSight onSight,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _onSight = onSight,
        _logMessage = logMessage {
    _knownDevices = _onSight.getKnownMac();
    _ble_counter = 0;
    _mag_counter = 0;
  }

  final FlutterReactiveBle _ble;
  final OnSight _onSight;

  final void Function(String message) _logMessage;
  final StreamController<SensorScannerState> _bleStreamController =
      StreamController();
  // for subscriptions
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  List<String> _knownDevices = [];
  Map<String, List<DiscoveredDevice>> _bleDevices = {};
  List<SensorCharacteristics> _magnetometerValues = [];
  List<ResultCharactersitics> _results = [];
  final _devices = <DiscoveredDevice>[];

  Random _rand = Random();
  bool _hasUpdated = false;
  num _ble_counter = 0; // force ble duty cycle
  num _mag_counter = 0; // force mag duty cycle

  @override
  Stream<SensorScannerState> get state => _bleStreamController.stream;

  void _hardReset() {
    // reset all subscriptions
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _bleDevices.clear();
    _devices.clear();
    _streamSubscriptions.clear();
    _ble_counter = 0;
    _bleDevices.clear();
    _mag_counter = 0;
    _magnetometerValues.clear();
    _results.clear();
    _onSight.resetLocalisation();
  }

  void _softReset() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
    _ble_counter = 0;
    _mag_counter = 0;
    _onSight.resetLocalisation();
  }

  void connect(List<Uuid> serviceIds) {
    _hardReset();

    // for bluetooth
    _streamSubscriptions.add(_ble
        .scanForDevices(
      withServices: serviceIds,
      // TODO: change scanMode as necessary
      scanMode: ScanMode.balanced,
    )
        .listen((device) {
      final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        _devices[knownDeviceIndex] = device;
      } else {
        _devices.add(device);
      }
      _pushState(fromMag: false, fromBle: false, isConnect: true);
    }, onError: (Object e) => _logMessage('Device scan fails with error: $e')));
    _pushState(fromMag: false, fromBle: false, isConnect: true);
  }

  void startLocalisation(List<Uuid> serviceIds) {
    _hardReset();

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
          _pushState(fromMag: true, fromBle: false, isConnect: false);
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
    required bool isConnect,
  }) {
    _bleStreamController.add(
      SensorScannerState(
        discoveredDevices: _bleDevices,
        result: _results,
        magnetometer: _magnetometerValues,
        connectDiscoveredDevices: _devices,
        // startscan is called in init, resulting in streams being subscribed automatically.
        // thus if _streamSubscriptions.isNotEmpty, it means that scanning is in progress.
        scanIsInProgress: _streamSubscriptions.isNotEmpty,
      ),
    );

    if (!isConnect) {
      performLocalisation(
        hasUpdate: _hasUpdated,
        // TODO: true if in debug mode, false if in actual test mode
        isDebugMode: false,
        fromBle: fromBle,
        fromMag: fromMag,
      );
    }
  }

  Future<void> stopScan() async {
    _softReset();
    _pushState(fromBle: false, fromMag: false, isConnect: false);
  }

  Future<void> dispose() async {
    await _bleStreamController.close();
  }

  LinkedHashMap<String, num> _sort(
    LinkedHashMap<String, dynamic> unsortedRssi,
  ) {
    SplayTreeMap currSortedRssi = SplayTreeMap();
    LinkedHashMap<String, num> sortedRssi = LinkedHashMap();

    // sort placeholder values and store to map container
    currSortedRssi = SplayTreeMap.from(unsortedRssi,
        (prev, next) => unsortedRssi[next]!.compareTo(unsortedRssi[prev] ?? 0));
    currSortedRssi.forEach((mac, rssi) {
      sortedRssi[mac] = rssi;
    });

    return sortedRssi;
  }

  /// BLE write value to characteristics.
  ///
  /// Input:
  /// 1) direction [String]
  Future<void> _writeWithoutResponse(String direction) async {
    if (_onSight.connectionState) {
      final characteristic = QualifiedCharacteristic(
          serviceId: _onSight.serviceId,
          characteristicId: _onSight.characteristicId,
          deviceId: _onSight.deviceId);
      switch (direction) {
        case 'Forward':
          await _ble
              .writeCharacteristicWithoutResponse(characteristic, value: [0x2]);
          break;
        case 'Left':
          await _ble
              .writeCharacteristicWithoutResponse(characteristic, value: [0x1]);
          break;
        case 'Right':
          await _ble
              .writeCharacteristicWithoutResponse(characteristic, value: [0x3]);
          break;
        default:
          print('[_writeWithoutResponse] Direction given is incorrect.');
          break;
      }
    } else {
      print('[_writeWithResponse] Cane device is not connected');
    }
  }

  /// This wrapper function does four things:
  /// 1) Tracks the counters for mag and ble.
  /// 2) Performs localisation when the counters reached a threshold.
  /// 3) Sync data over MQTT.
  /// 4) Write characteristics to ESP32.
  ///
  /// Inputs:
  /// 1) hasUpdate [bool] - indicates if there is an update in the bleDevice containter.
  /// 2) isDebugMode [bool] - indicates if we are debugging or using actual data collected in real time.
  /// 3) fromMag [bool] - indicates if performLocalisation is called from magnetometer sensor.
  /// 4) fromBle [bool] - indicates if performLocalisation is called from ble sensor.
  ///
  /// Returns:
  /// 1) None.
  Future<void> performLocalisation({
    required bool hasUpdate,
    required bool isDebugMode,
    required bool fromMag,
    required bool fromBle,
  }) async {
    if (_magnetometerValues.isEmpty) return;

    DateTime currTime = DateTime.now();
    String stringTime =
        '${currTime.hour}:${currTime.minute}:${currTime.second}.${currTime.millisecond}';

    // TODO: duty cycle for ble devices (zero based counting)
    final num _BLE_READ = 29;
    // TODO: duty cycle for magnetometer (zero based counting)
    final num _MAG_READ = 6;

    LinkedHashMap<String, dynamic> currRawDataAll = LinkedHashMap();
    // for storing of result of localisation
    LinkedHashMap<String, dynamic> result = LinkedHashMap();
    // to check if system is ready
    bool isReady = (hasUpdate && (_ble_counter >= _BLE_READ));
    // update magnetometer
    List<num> currMag = [
      _magnetometerValues[0].value,
      _magnetometerValues[1].value,
      _magnetometerValues[2].value,
    ];

    // In debugMode
    if (isDebugMode) {
      LinkedHashMap<String, dynamic> tmpResult = LinkedHashMap();
      LinkedHashMap<String, num> tmpUnsortedRssi = LinkedHashMap();

      // create placeholder rssi values
      LinkedHashMap<String, num> currRssiAll = LinkedHashMap();
      _knownDevices.forEach((mac) {
        tmpUnsortedRssi[mac] = -(_rand.nextInt(20) + 60);
      });
      // sort placeholder values and store to map container
      currRssiAll = _sort(tmpUnsortedRssi);

      // magneto only
      if (fromMag) {
        // update bearing only
        currRawDataAll.addEntries([
          MapEntry('time', stringTime),
          MapEntry('magnetometer', currMag),
        ]);

        if (_mag_counter >= _MAG_READ) {
          // perform localisation
          tmpResult = _onSight.localisation(currRawDataAll);
          _results = _formatResult(tmpResult);
          result.addEntries(tmpResult.entries);

          // index of 'suggested_direction' is 0
          await _writeWithoutResponse(_results[0].value);

          _mag_counter = 0; // reset counter
          _magnetometerValues.clear(); // reset container
        } else {
          _mag_counter += 1;
        }
      }

      // localisation
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
        result.addEntries(tmpResult.entries);

        _bleDevices.clear(); // reset container
        _ble_counter = 0; // reset counter
      } else {
        // update both bearing and est position
        currRawDataAll.addEntries([
          MapEntry('time', stringTime),
          MapEntry('rssi', currRssiAll),
          MapEntry('magnetometer', currMag),
        ]);

        _ble_counter += 1;
      }

      // TODO: uncomment as needed
      // publishMqttPayload(currRawDataAll, result);
    }

    // In non-debugMode
    else {
      LinkedHashMap<String, dynamic> tmpResult = LinkedHashMap();

      // localisation
      if (fromBle) {
        LinkedHashMap<String, num> currRssiAll = LinkedHashMap();
        LinkedHashMap<String, num> tmpUnsortedRssi = LinkedHashMap();

        // using actual values
        if (isReady) {
          _bleDevices.forEach((mac, details) {
            num rssiSum = 0.0;
            details.forEach((device) {
              rssiSum += device.rssi;
            });
            tmpUnsortedRssi[mac] = rssiSum / details.length;
          });
          // sort avg rssi and store to map container
          currRssiAll = _sort(tmpUnsortedRssi);

          // update both bearing and est position
          currRawDataAll.addEntries([
            MapEntry('time', stringTime),
            MapEntry('rssi', currRssiAll),
            MapEntry('magnetometer', currMag),
          ]);

          // perform localisation
          tmpResult = _onSight.localisation(currRawDataAll);
          _results = _formatResult(tmpResult);
          result.addEntries(tmpResult.entries);

          _bleDevices.clear(); // reset container
          _ble_counter = 0; // reset counter
        } else {
          _bleDevices.forEach((mac, details) {
            tmpUnsortedRssi[mac] = details.last.rssi;
          });
          // sort avg rssi and store to map container
          currRssiAll = _sort(tmpUnsortedRssi);

          // update both bearing and est position
          currRawDataAll.addEntries([
            MapEntry('time', stringTime),
            MapEntry('rssi', currRssiAll),
            MapEntry('magnetometer', currMag),
          ]);

          _ble_counter += 1;
        }

        // TODO: uncomment as needed
        // publishMqttPayload(currRawDataAll, result);
      }

      // magneto only
      if (fromMag) {
        // update bearing only
        currRawDataAll.addEntries([
          MapEntry('time', stringTime),
          MapEntry('magnetometer', currMag),
        ]);

        if (_mag_counter >= _MAG_READ) {
          // perform localisation
          tmpResult = _onSight.localisation(currRawDataAll);
          _results = _formatResult(tmpResult);
          result.addEntries(tmpResult.entries);

          // index of 'suggested_direction' is 0
          await _writeWithoutResponse(_results[0].value);

          _mag_counter = 0; // reset counter
          _magnetometerValues.clear(); // reset container
        } else {
          _mag_counter += 1;
        }
      }
    }
    // print('ble = $_ble_counter, mag = $_mag_counter');
  }

  List<ResultCharactersitics> _formatResult(
      LinkedHashMap<String, dynamic> result) {
    return <ResultCharactersitics>[
      ResultCharactersitics(
        name: 'suggested_direction',
        value: result['direction']['suggested_direction'] ?? 'Error',
      ),
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
    ];
  }

  bool _areDevicesUpdated(DiscoveredDevice device) {
    bool hasUpdate = false;

    if (_bleDevices.containsKey(device.id)) {
      // add on to current list
      _bleDevices[device.id]!.add(device);
      hasUpdate = true;
    } else {
      if (_knownDevices.contains(device.id)) {
        // create a new list
        _bleDevices[device.id] = [device];
        hasUpdate = true;
      }
    }

    if (hasUpdate) {
      _pushState(fromBle: true, fromMag: false, isConnect: false);
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
    required this.connectDiscoveredDevices,
  });

  final Map<String, List<DiscoveredDevice>> discoveredDevices;
  final List<ResultCharactersitics> result;
  final List<SensorCharacteristics> magnetometer;
  final bool scanIsInProgress;
  final List<DiscoveredDevice> connectDiscoveredDevices;
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
