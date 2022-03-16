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
  })  : _ble = ble,
        _onSight = onSight {
    _knownDevices = _onSight.getKnownMac();
    _ble_counter = 0;
    _mag_counter = 0;
  }

  final FlutterReactiveBle _ble;
  final OnSight _onSight;

  List<String> _knownDevices = [];
  final StreamController<SensorScannerState> _bleStreamController =
      StreamController();
  // for subscriptions
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Map<String, List<DiscoveredDevice>> _bleDevices = {};
  List<SensorCharacteristics> _magnetometerValues = [];
  List<ResultCharactersitics> _results = [];

  //final characteristic = QualifiedCharacteristic(serviceId: serviceUuid, characteristicId: characteristicUuid, deviceId: foundDeviceId);

  bool _hasUpdated = false;
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

  // TODO: figure out how to send data before averaging
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

    // TODO: duty cycle for ble devices (zero based counting)
    final num _BLE_READ = 29;
    // TODO: duty cycle for magnetometer (zero based counting)
    final num _MAG_READ = 4;

    LinkedHashMap<String, dynamic> currRawDataAll = LinkedHashMap();
    // for storing of result of localisation
    LinkedHashMap<String, dynamic> result = LinkedHashMap();
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
      LinkedHashMap<String, dynamic> tmpResult = LinkedHashMap();
      LinkedHashMap<String, num> tmpUnsortedRssi = LinkedHashMap();

      // create placeholder rssi values
      Random rand = Random();
      LinkedHashMap<String, num> currRssiAll = LinkedHashMap();
      _knownDevices.forEach((mac) {
        tmpUnsortedRssi[mac] = -(rand.nextInt(20) + 60);
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
      publishMqttPayload(currRawDataAll, result);
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
        publishMqttPayload(currRawDataAll, result);
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

  final Map<String, List<DiscoveredDevice>> discoveredDevices;
  final List<ResultCharactersitics> result;
  final List<SensorCharacteristics> magnetometer;
  final bool scanIsInProgress;
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
