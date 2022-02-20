import 'package:meta/meta.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:on_sight/services/reactive_packages/reactive_state.dart';

class ServicesScanner implements ReactiveState<ServicesScannerState> {
  ServicesScanner({
    required FlutterReactiveBle ble,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final void Function(String message) _logMessage;
  final StreamController<ServicesScannerState> _bleStreamController =
      StreamController();

  // for subscriptions
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  final _bleDevices = <DiscoveredDevice>[];
  List<double> _accelerometerValues = [];
  List<double> _magnetometerValues = [];

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
    _streamSubscriptions
        .add(_ble.scanForDevices(withServices: serviceIds).listen((device) {
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
    }, onError: (Object e) => _logMessage('Device scan fails with error: $e')));

    // for acc
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _accelerometerValues = <double>[
            event.x,
            event.y,
            event.z,
          ];
          _pushState();
        },
      ),
    );

    // for mag
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          _magnetometerValues = <double>[
            event.x,
            event.y,
            event.z,
          ];
          _pushState();
        },
      ),
    );

    _pushState();
  }

  void _pushState() {
    _bleStreamController.add(
      ServicesScannerState(
          discoveredDevices: _bleDevices,
          acceleration: _accelerometerValues,
          magnetometer: _magnetometerValues,
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
}

@immutable
class ServicesScannerState {
  const ServicesScannerState({
    required this.discoveredDevices, // bluetooth devices
    required this.acceleration, //acceleration value
    required this.magnetometer, // magneto value
    required this.scanIsInProgress, // checks if scanning is in progress
  });

  final List<DiscoveredDevice> discoveredDevices;
  final List<double> acceleration;
  final List<double> magnetometer;
  final bool scanIsInProgress;
}
