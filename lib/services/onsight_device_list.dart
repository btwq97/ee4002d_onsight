import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'package:on_sight/services/reactive_packages/widgets.dart';
import 'package:on_sight/services/onsight_scanner.dart';
import 'package:on_sight/services/onsight.dart';

class OnsightLocalisationScreen extends StatelessWidget {
  OnsightLocalisationScreen({
    Key? key,
    required this.onSight,
  }) : super(key: key) {}

  final OnSight onSight;

  @override
  Widget build(BuildContext context) =>
      Consumer2<OnsightServicesScanner, SensorScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) => _DeviceList(
          onSight: onSight,
          sensorScannerState: bleScannerState ??
              const SensorScannerState(
                discoveredDevices: [],
                result: [],
                magnetometer: [],
                acceleration: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  _DeviceList(
      {required this.onSight,
      required this.sensorScannerState,
      required this.startScan,
      required this.stopScan});

  final OnSight onSight;
  final SensorScannerState sensorScannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  List<Uuid> knownUuid = [];

  @override
  void initState() {
    super.initState();
    _startScanning(); // we dont need to stream the devices here as it is taken cared of in ble_scanner
  }

  @override
  void dispose() {
    super.dispose();
    widget.stopScan();
  }

  void _startScanning() {
    widget.startScan(knownUuid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localisation'),
      ),
      body: Column(
        children: [
          // bluetooth start and stop
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      child: const Text('Start'),
                      onPressed: !widget.sensorScannerState.scanIsInProgress
                          ? _startScanning
                          : null,
                    ),
                    ElevatedButton(
                      child: const Text('Stop'),
                      onPressed: widget.sensorScannerState.scanIsInProgress
                          ? widget.stopScan
                          : null,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(!widget.sensorScannerState.scanIsInProgress
                          ? 'Tap start to begin localisation'
                          : 'Localisation in process...'),
                    ),
                    if (widget.sensorScannerState.scanIsInProgress &&
                        widget.sensorScannerState.discoveredDevices.isNotEmpty)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 18.0),
                        child: Text(
                            'Devices found: ${widget.sensorScannerState.discoveredDevices.length}'),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // For discovery
          Flexible(
            child: ListView(
              children: widget.sensorScannerState.discoveredDevices
                  .map(
                    (device) => ListTile(
                      title: Text(device.name),
                      subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                      leading: const BluetoothIcon(),
                    ),
                  )
                  .toList(),
            ),
          ),

          // For accelerometer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Accelerometer'),
              ),
            ],
          ),
          Flexible(
            child: ListView(
              children: widget.sensorScannerState.acceleration
                  .map(
                    (sensorValue) => ListTile(
                      title: Text(sensorValue.name),
                      subtitle: Text(sensorValue.value.toString()),
                    ),
                  )
                  .toList(),
            ),
          ),

          // For magnetometer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Magnetometer'),
              ),
            ],
          ),
          Flexible(
            child: ListView(
              children: widget.sensorScannerState.magnetometer
                  .map(
                    (sensorValue) => ListTile(
                      title: Text(sensorValue.name),
                      subtitle: Text(sensorValue.value.toString()),
                    ),
                  )
                  .toList(),
            ),
          ),

          // For results
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Results'),
              ),
              if (widget.sensorScannerState.scanIsInProgress &&
                  widget.sensorScannerState.discoveredDevices.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 18.0),
                  child: Text('Processing...'),
                ),
            ],
          ),
          Flexible(
            child: ListView(
              children: widget.sensorScannerState.result
                  .map(
                    (result) => ListTile(
                      title: Text(result.name),
                      subtitle: Text((result.name == 'direction')
                          ? convertToDirection(result.value)
                          : result.value.toString()),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Function to convert numbered direction to its corresponding string value.
///
/// Inputs:
/// 1) direction [num] - direction in double.
///
/// Return:
/// 1) [String].
String convertToDirection(num direction) {
  if (direction == 1.0)
    return 'North';
  else if (direction == 2.0)
    return 'South';
  else if (direction == 3.0)
    return 'East';
  else if (direction == 4.0)
    return 'West';
  else if (direction == 5.0)
    return 'North-East';
  else if (direction == 6.0)
    return 'South-East';
  else if (direction == 7.0)
    return 'South-West';
  else if (direction == 8.0)
    return 'North-West';
  else
    return "Error";
}
