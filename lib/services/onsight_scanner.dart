import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:meta/meta.dart';

import 'package:on_sight/services/reactive_packages/reactive_state.dart';
import 'package:on_sight/services/onsight.dart';

// TODO: find a way to integrate acc and mag here

class BleScanner implements ReactiveState<BleScannerState> {
  BleScanner({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
    required OnSight onSight,
  })  : _ble = ble,
        _logMessage = logMessage,
        _onSight = onSight;

  final FlutterReactiveBle _ble;
  final OnSight _onSight;
  final void Function(String message) _logMessage;
  final StreamController<BleScannerState> _stateStreamController =
      StreamController();

  // for subscriptions
  StreamSubscription? _subscription;

  final _bleDevices = <DiscoveredDevice>[];

  @override
  Stream<BleScannerState> get state => _stateStreamController.stream;

  void startScan(List<Uuid> serviceIds, List<double> acc, List<double> mag) {
    _logMessage('Start ble discovery');
    _bleDevices.clear();
    _subscription?.cancel();
    _subscription =
        _ble.scanForDevices(withServices: serviceIds).listen((device) {
      final knownDeviceIndex = _bleDevices.indexWhere((d) => d.id == device.id);
      // if prev value is found
      if (knownDeviceIndex >= 0) {
        _bleDevices[knownDeviceIndex] = device;
      } else {
        _bleDevices.add(device);
      }
      // sort the output
      _bleDevices.sort((a, b) => b.rssi.compareTo(a.rssi));
      // update ScannerState
      _pushState();

      // perform localisation
      print("ACC = $acc");
      print("MAG = $mag");
    }, onError: (Object e) => _logMessage('Device scan fails with error: $e'));
    _pushState();
  }

  void _pushState() {
    _stateStreamController.add(
      BleScannerState(
          discoveredDevices: _bleDevices,
          scanIsInProgress: _subscription != null),
    );
  }

  Future<void> stopScan() async {
    _logMessage('Stop ble discovery');

    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  Future<void> dispose() async {
    await _stateStreamController.close();
  }
}

@immutable
class BleScannerState {
  const BleScannerState({
    required this.discoveredDevices,
    required this.scanIsInProgress,
  });

  final List<DiscoveredDevice> discoveredDevices;
  final bool scanIsInProgress;
}
