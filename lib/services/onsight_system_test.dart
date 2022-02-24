import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'package:on_sight/services/reactive_packages/widgets.dart';
import 'package:on_sight/services/onsight_system_test_scanner.dart';
import 'package:on_sight/services/onsight.dart';

class OnsightSystemTestScreen extends StatelessWidget {
  OnsightSystemTestScreen({
    Key? key,
    required this.onSight,
  }) : super(key: key) {}

  final OnSight onSight;

  @override
  Widget build(BuildContext context) =>
      Consumer2<OnsightSystemTestScanner, OnsightSystemTestScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) =>
            _OnsightSystemTestDeviceList(
          onSight: onSight,
          scannerState: bleScannerState ??
              const OnsightSystemTestScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
        ),
      );
}

class _OnsightSystemTestDeviceList extends StatefulWidget {
  _OnsightSystemTestDeviceList(
      {required this.onSight,
      required this.scannerState,
      required this.startScan,
      required this.stopScan});

  final OnSight onSight;
  final OnsightSystemTestScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;

  @override
  _OnsightSystemTestDeviceListState createState() =>
      _OnsightSystemTestDeviceListState();
}

class _OnsightSystemTestDeviceListState
    extends State<_OnsightSystemTestDeviceList> {
  List<Uuid> knownUuid = [];

  @override
  void initState() {
    super.initState();
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
        title: const Text('System Characteristics Test'),
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
                          ? 'Tap start to begin scanning'
                          : 'Data collection in process...'),
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
        ],
      ),
    );
  }
}
