import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'package:on_sight/services/onsight_scanner.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/services/onsight_cane_device_detail_screen.dart';

class BluetoothIcon extends StatelessWidget {
  const BluetoothIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 64,
        height: 64,
        child: Align(alignment: Alignment.center, child: Icon(Icons.bluetooth)),
      );
}

class OnsightLocalisationScreen extends StatelessWidget {
  OnsightLocalisationScreen({
    Key? key,
    required this.onSight,
  }) : super(key: key) {}

  final OnSight onSight;

  @override
  Widget build(BuildContext context) =>
      Consumer2<OnsightLocalisationScanner, SensorScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) => _DeviceList(
          onSight: onSight,
          sensorScannerState: bleScannerState ??
              const SensorScannerState(
                discoveredDevices: {},
                result: [],
                magnetometer: [],
                scanIsInProgress: false,
                connectDiscoveredDevices: [],
              ),
          startLocalisation: bleScanner.startLocalisation,
          stopScan: bleScanner.stopScan,
          connect: bleScanner.connect,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  _DeviceList({
    required this.onSight,
    required this.sensorScannerState,
    required this.startLocalisation,
    required this.stopScan,
    required this.connect,
  });

  final OnSight onSight;
  final SensorScannerState sensorScannerState;
  final void Function(List<Uuid>) startLocalisation;
  final VoidCallback stopScan;
  final void Function(List<Uuid>) connect;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  List<Uuid> _knownUuid = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    widget.stopScan();
  }

  void _startLocalising() {
    widget.startLocalisation(_knownUuid);
  }

  void _connect() {
    widget.connect(_knownUuid);
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
                      child: const Text('Localise'),
                      onPressed: !widget.sensorScannerState.scanIsInProgress
                          ? _startLocalising
                          : null,
                    ),
                    ElevatedButton(
                      child: const Text('Cane'),
                      onPressed: (!widget.sensorScannerState.scanIsInProgress &&
                              !widget.onSight.connectionState)
                          ? _connect
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
                    if (widget.sensorScannerState.scanIsInProgress)
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
              children: widget.sensorScannerState.connectDiscoveredDevices
                  .map(
                    (device) => ListTile(
                      title: Text(device.name),
                      subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                      leading: const BluetoothIcon(),
                      onTap: () async {
                        widget.stopScan();
                        await Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DeviceDetailScreen(
                                      onSight: widget.onSight,
                                      device: device,
                                    )));
                      },
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
              if (widget.sensorScannerState.scanIsInProgress)
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
                      subtitle: Text(result.value.toString()),
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
