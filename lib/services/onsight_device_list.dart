import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'package:on_sight/services/reactive_packages/widgets.dart';
import 'package:on_sight/services/onsight_scanner.dart';
import 'package:on_sight/services/onsight.dart';

class DeviceListScreen extends StatelessWidget {
  DeviceListScreen({
    Key? key,
    required this.onSight,
    required this.ble,
  }) : super(key: key);

  final OnSight onSight;
  final FlutterReactiveBle ble;

  @override
  Widget build(BuildContext context) =>
      Consumer2<ServicesScanner, ServicesScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) => _DeviceList(
          onSight: onSight,
          ble: ble,
          scannerState: bleScannerState ??
              const ServicesScannerState(
                discoveredDevices: [],
                acceleration: [],
                magnetometer: [],
                result: {},
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
    knownUuid = widget.onSight.getKnownUuid(); // pull known uuid from database
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
    widget.stopScan();
    super.dispose();
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
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
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              children: widget.scannerState.discoveredDevices
                  .map(
                    (device) => ListTile(
                        title: Text(device.name),
                        subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                        leading: const BluetoothIcon()),
                  )
                  .toList(),
            ),
          ),

          // For accelerometer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Expanded(child: Text('Accelerometer'))],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("acc_x = ${widget.scannerState.acceleration[0]}")
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("acc_y = ${widget.scannerState.acceleration[1]}")
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("acc_z = ${widget.scannerState.acceleration[2]}")
              ],
            ),
          ),

          // For magnetometer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Expanded(child: Text('Magnetometer'))],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("mag_x = ${widget.scannerState.magnetometer[0]}")
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("mag_y = ${widget.scannerState.magnetometer[1]}")
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("mag_z = ${widget.scannerState.magnetometer[2]}")
              ],
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("est_x = ${widget.scannerState.result['x_coordinate']}")
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("est_y = ${widget.scannerState.result['y_coordinate']}")
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("direction = ${widget.scannerState.result['direction']}")
              ],
            ),
          ),
        ],
      ),
    );
  }
}
