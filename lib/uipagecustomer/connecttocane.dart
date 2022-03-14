import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:on_sight/cane_connection_necessities/cane_connection_device_detail_screen.dart';
import 'package:on_sight/services/onsight.dart';
import 'package:on_sight/constants.dart';
import 'package:on_sight/components/iconcontent.dart';
import 'package:on_sight/components/reuseablecard.dart';
import 'package:on_sight/setuppages/Vegetarianism.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:on_sight/services/reactive_packages/ble_scanner.dart';
import 'package:provider/provider.dart';
import 'package:on_sight/services/reactive_packages/widgets.dart';




class ConnectToCane extends StatefulWidget {
  ConnectToCane({
    Key? key,
    required this.onSight,
  }) : super(key: key);

  final OnSight onSight;

  @override
  _ConnectToCanePageState createState() => _ConnectToCanePageState(
        onSight: onSight,
      );
}

class _ConnectToCanePageState extends State<ConnectToCane> {
  _ConnectToCanePageState({
    required this.onSight,
  });

  final OnSight onSight;

  @override
  Widget build(BuildContext context) => Consumer2<BleScanner, BleScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) => _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          onSight: onSight,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList(
      {required this.scannerState,
      required this.startScan,
      required this.stopScan,
      required this.onSight});

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;

  final OnSight onSight;

  @override
  _DeviceListState createState() => _DeviceListState(
        onSight: onSight,
      );
}

class _DeviceListState extends State<_DeviceList> {
  _DeviceListState({
    required this.onSight,
  });

  late TextEditingController _uuidController;

  final OnSight onSight;

  @override
  void initState() {
    super.initState();
    _uuidController = TextEditingController()
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.stopScan();
    _uuidController.dispose();
    super.dispose();
  }

  bool _isValidUuidInput() {
    final uuidText = _uuidController.text;
    if (uuidText.isEmpty) {
      return true;
    } else {
      try {
        Uuid.parse(uuidText);
        return true;
      } on Exception {
        return false;
      }
    }
  }

  void _startScanning() {
    final text = _uuidController.text;
    widget.startScan(text.isEmpty ? [] : [Uuid.parse(_uuidController.text)]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('CONNECT TO CANE'),
        ),
        body: Column(
          children: [
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
                        child: const Text('Scan'),
                        onPressed: !widget.scannerState.scanIsInProgress &&
                                _isValidUuidInput()
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
                            ? 'Tap Scan to begin scanning'
                            : 'Tap a device to connect to it'),
                      ),
                      if (widget.scannerState.scanIsInProgress ||
                          widget.scannerState.discoveredDevices.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 18.0),
                          child: Text(
                              'count: ${widget.scannerState.discoveredDevices.length}'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                children: widget.scannerState.discoveredDevices
                    .map(
                      (device) => ListTile(
                        title: Text(device.name),
                        subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                        leading: const BluetoothIcon(),
                        onTap: () async {
                          await Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      CaneConnectionDeviceDetailScreen(device: device, onSight: onSight)));
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => VegetarianPage(
            //                   onSight: onSight,
            //                 )));
            //   },
            //   child: Container(
            //     child: Center(
            //       child: Text(
            //         'CONTINUE',
            //         style: kBottomButtonTextStyle,
            //       ),
            //     ),
            //     color: kBottomContainerColour,
            //     margin: EdgeInsets.only(top: 10.0),
            //     padding: EdgeInsets.only(bottom: 20.0),
            //     width: double.infinity,
            //     height: kBottomContainerHeight,
            //   ),
            // ),
            //KIV if the gesture detector above is needed. If not, delete. Commented out first (lines 186-208)
          ],
        ),
      );
}


