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
    required this.ble,
  }) : super(key: key) {}

  final OnSight onSight;
  final FlutterReactiveBle ble;

  @override
  Widget build(BuildContext context) =>
      Consumer2<OnsightServicesScanner, ServicesScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) => _DeviceList(
          onSight: onSight,
          ble: ble,
          scannerState: bleScannerState ??
              const ServicesScannerState(
                discoveredDevices: [],
                acceleration: [],
                magnetometer: [],
                result: [],
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
      required this.ble,
      required this.scannerState,
      required this.startScan,
      required this.stopScan});

  final OnSight onSight;
  final FlutterReactiveBle ble;
  final ServicesScannerState scannerState;
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

    // Example of how to subscribe to a stream
    // _streamSubscriptions.add(
    //     widget.ble.scanForDevices(withServices: knownUuid).listen((update) {
    //   setState(() {
    //     String currUuid = update.id;
    //     if (_discoveredDevices.containsKey(currUuid)) {
    //       int tempRssi = _discoveredDevices[currUuid] ?? 0;
    //       _discoveredDevices[currUuid] = (tempRssi + update.rssi) ~/ 2;
    //     } else {
    //       _discoveredDevices[currUuid] = update.rssi;
    //     }
    //     print("discovered = ${_discoveredDevices}");
    //     // print("from ble = ${widget.scannerState.discoveredDevices}");
    //   });
    // }));
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
                      onPressed: !widget.scannerState.scanIsInProgress
                          ? _startScanning
                          : null,
                    ),
                    ElevatedButton(
                      child: const Text('Stop'),
                      onPressed: widget.scannerState.scanIsInProgress
                          ? widget.stopScan
                          : null,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(!widget.scannerState.scanIsInProgress
                          ? 'Tap start to begin localisation'
                          : 'Localisation in process...'),
                    ),
                    if (widget.scannerState.scanIsInProgress &&
                        widget.scannerState.discoveredDevices.isNotEmpty)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 18.0),
                        child: Text(
                            'Devices found: ${widget.scannerState.discoveredDevices.length}'),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // For discovery
          Flexible(
            child: ListView(
              children: widget.scannerState.discoveredDevices
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
              children: widget.scannerState.acceleration
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
              children: widget.scannerState.magnetometer
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
              if (widget.scannerState.scanIsInProgress &&
                  widget.scannerState.discoveredDevices.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 18.0),
                  child: Text('Processing...'),
                ),
            ],
          ),
          Flexible(
            child: ListView(
              children: widget.scannerState.result
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
/// 1) direction [double] - direction in double.
///
/// Return:
/// 1) [String].
String convertToDirection(double direction) {
  if (direction == 1.0)
    return 'North';
  else if (direction == 2.0)
    return 'South';
  else if (direction == 3.0)
    return 'East';
  else if (direction == 4.0)
    return 'West';
  else if (direction == 5.0)
    return 'NorthEast';
  else if (direction == 6.0)
    return 'SouthEast';
  else if (direction == 7.0)
    return 'SouthWest';
  else // NorthWest
    return 'NorthWest';
}
