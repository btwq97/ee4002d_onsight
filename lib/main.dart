import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:on_sight/setuppages/CustomerOrStoreownerPage.dart';
import 'package:on_sight/services/onsight.dart';

// for reactive ble
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:on_sight/services/reactive_packages/ble_device_connector.dart';
import 'package:on_sight/services/reactive_packages/onsight_ble_device_interactor.dart';
import 'package:on_sight/services/onsight_scanner.dart';
import 'package:on_sight/services/reactive_packages/ble_status_monitor.dart';
import 'package:on_sight/services/reactive_packages/ble_status_screen.dart';
import 'package:on_sight/services/reactive_packages/ble_logger.dart';
import 'package:on_sight/services/onsight_system_test_scanner.dart';

const _themeColor = Color(0xFF301934);

void main() async {
  // init OnSight program
  OnSight onSight = OnSight();
  await onSight.start();

  // For flutter reactive ble
  WidgetsFlutterBinding.ensureInitialized();
  final _bleLogger = BleLogger();
  final _ble = FlutterReactiveBle();
  final _onsightLocalisationScanner = OnsightLocalisationScanner(
    ble: _ble,
    onSight: onSight,
    logMessage: _bleLogger.addToLog,
  );
  final _systemTestScanner = OnsightSystemTestScanner(
    ble: _ble,
    onSight: onSight,
  );
  final _monitor = BleStatusMonitor(_ble);
  final _connector = BleDeviceConnector(
    onSight: onSight,
    ble: _ble,
    logMessage: _bleLogger.addToLog,
  );
  final _caneServiceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: _ble.discoverServices,
    readCharacteristic: _ble.readCharacteristic,
    writeWithResponse: _ble.writeCharacteristicWithResponse,
    writeWithOutResponse: _ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: _ble.subscribeToCharacteristic,
    logMessage: _bleLogger.addToLog,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: _onsightLocalisationScanner),
        Provider.value(value: _systemTestScanner),
        // Provider.value(value: _espScanner),
        Provider.value(value: _monitor),
        Provider.value(value: _connector),
        Provider.value(value: _caneServiceDiscoverer),
        Provider.value(value: _bleLogger),
        StreamProvider<SensorScannerState?>(
          create: (_) => _onsightLocalisationScanner.state,
          initialData: const SensorScannerState(
            discoveredDevices: {},
            result: [],
            magnetometer: [],
            scanIsInProgress: false,
            connectDiscoveredDevices: [],
          ),
        ),
        StreamProvider<OnsightSystemTestScannerState?>(
          create: (_) => _systemTestScanner.state,
          initialData: const OnsightSystemTestScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => _monitor.state,
          initialData: BleStatus.unknown,
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => _connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Permission Safeguard Check',
        color: _themeColor,
        theme: ThemeData.dark().copyWith(
          primaryColor: _themeColor,
          scaffoldBackgroundColor: _themeColor,
        ),
        home: HomePage(
          onSight: onSight,
          ble: _ble,
        ),
      ),
    ),
  );

  return;
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
    required this.onSight,
    required this.ble,
  }) : super(key: key);

  final OnSight onSight;
  final FlutterReactiveBle ble;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.dark().copyWith(
          primaryColor: _themeColor,
          scaffoldBackgroundColor: _themeColor,
        ),
        initialRoute: '/Safeguard Check',
        routes: {
          '/Safeguard Check': (context) =>
              Consumer<BleStatus?>(builder: (_, status, __) {
                if (status == BleStatus.ready) {
                  return CustomerOrStoreOwnerPage(
                    onSight: onSight,
                  );
                } else {
                  return BleStatusScreen(status: status ?? BleStatus.unknown);
                }
              })
        });
  }
}
