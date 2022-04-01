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
  bool isCane = false;

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
    isCane = false;
  }

  void _connect() {
    widget.connect(_knownUuid);
    isCane = true;
  }

  String _display() {
    if (!widget.sensorScannerState.scanIsInProgress) {
      if (!widget.onSight.connectionState) {
        return 'Tap "Localise" to begin localisation.\n\nTap "Cane" to connect to cane.\n';
      } else {
        return 'Tap "Localise" to begin localisation.';
      }
    } else {
      if (isCane) {
        return 'Searching for cane...\n';
      } else {
        return 'Performing localisation...\n';
      }
    }
  }

  List<DiscoveredDevice> _displayBluetoothDevice() {
    List<DiscoveredDevice> result = [];
    widget.sensorScannerState.discoveredDevices.forEach((mac, data) {
      result.add(data.last);
    });
    result.sort((prev, next) => next.rssi.compareTo(prev.rssi));
    return result;
  }

  ListView _displayBleDiscoveryState() {
    if (isCane) {
      return ListView(
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
      );
    } else {
      return ListView(
        children: _displayBluetoothDevice()
            .map(
              (device) => ListTile(
                title: Text(device.name),
                subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                leading: const BluetoothIcon(),
              ),
            )
            .toList(),
      );
    }
  }

  String _displayDeviceLength() {
    if (isCane) {
      return 'Devices found: ${widget.sensorScannerState.connectDiscoveredDevices.length}';
    } else {
      return 'Devices found: ${widget.sensorScannerState.discoveredDevices.length}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Localisation',
          style: TextStyle(
            fontSize: 40,
            color: Color(0xFFFFFF00),
          ),
        ),
        backgroundColor: Color(0xFF702963),
      ),
      backgroundColor: Color(0xFF301934),
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
                      child: Text(_display()),
                    ),
                    if (widget.sensorScannerState.scanIsInProgress)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 18.0),
                        child: Text(_displayDeviceLength()),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // For discovery
          Flexible(child: _displayBleDiscoveryState()),

          // For magnetometer
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Expanded(
          //       child: Text('Magnetometer'),
          //     ),
          //   ],
          // ),
          // Flexible(
          //   child: !isCane
          //       ? ListView(
          //           children: widget.sensorScannerState.magnetometer
          //               .map(
          //                 (sensorValue) => ListTile(
          //                   title: Text(sensorValue.name),
          //                   subtitle: Text(sensorValue.value.toString()),
          //                 ),
          //               )
          //               .toList(),
          //         )
          //       : ListView(),
          // ),

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
