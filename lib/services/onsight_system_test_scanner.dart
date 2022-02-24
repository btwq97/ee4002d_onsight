import 'dart:async';
import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:on_sight/services/reactive_packages/reactive_state.dart';
import 'package:on_sight/services/onsight.dart';

class OnsightSystemTestScanner
    implements ReactiveState<OnsightSystemTestScannerState> {
  OnsightSystemTestScanner({
    required FlutterReactiveBle ble,
    required OnSight onSight,
  })  : _ble = ble,
        _onSight = onSight {
    _knownDevices = _onSight.getKnownMac();
  }

  final FlutterReactiveBle _ble;
  final OnSight _onSight;
  List<String> _knownDevices = [];
  final StreamController<OnsightSystemTestScannerState> _bleStreamController =
      StreamController();

  // for subscriptions
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  final _bleDevices = <DiscoveredDevice>[];

  @override
  Stream<OnsightSystemTestScannerState> get state =>
      _bleStreamController.stream;

  void startScan(List<Uuid> serviceIds) {
    // reset all subscriptions
    _bleDevices.clear();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }

    // for bluetooth
    _streamSubscriptions.add(_ble
        .scanForDevices(
      withServices: serviceIds,
      // TODO: change scanMode as necessary
      scanMode: ScanMode.lowLatency,
    )
        .listen((device) {
      storeBleData(areDevicesUpdated(device), isTesting: true);
      _pushState();
    }, onError: (Object e) => print('Device scan fails with error: $e')));
  }

  void _pushState() {
    _bleStreamController.add(
      OnsightSystemTestScannerState(
          discoveredDevices: _bleDevices,
          // startscan is called when 'start' button is pressed,
          // resulting in streams being subscribed.
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

  void storeBleData(bool hasUpdate, {required bool isTesting}) {
    DateTime currTime = DateTime.now();
    String stringTime =
        '${currTime.hour}:${currTime.minute}:${currTime.second}.${currTime.millisecond}';

    LinkedHashMap<String, dynamic> rawData = LinkedHashMap();
    rawData.addEntries([MapEntry('time', stringTime)]); // store current time

    if (isTesting) {
      rawData.addEntries([
        MapEntry("DC:A6:32:A0:B7:4D", -65.0),
      ]);
    } else {
      for (int i = 0; i < _bleDevices.length; i++) {
        rawData.addEntries([MapEntry(_bleDevices[i].id, _bleDevices[i].rssi)]);
      }
    }

    publishMqttPayload(rawData, mode: Mode.SYSTEM_TESTING);
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
    LinkedHashMap<String, dynamic> rawData, {
    required Mode mode,
  }) {
    LinkedHashMap<String, dynamic> mqttPayload = LinkedHashMap();

    mqttPayload.addEntries(rawData.entries);

    _onSight.mqttPublish(mqttPayload,
        topic: 'fyp/test/sc', mode: mode); // sc: system characteristics
  }
}

@immutable
class OnsightSystemTestScannerState {
  const OnsightSystemTestScannerState({
    required this.discoveredDevices, // bluetooth devices
    required this.scanIsInProgress, // checks if scanning is in progress
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}
