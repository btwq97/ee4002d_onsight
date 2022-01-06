import 'package:flutter_blue/flutter_blue.dart';
import 'localisation_dynamodb.dart';
import 'package:on_sight/connectivity/bluetooth_widgets.dart';
import 'package:flutter/material.dart';

class BluetoothLocalisationPage extends StatefulWidget {
  @override
  _BluetoothLocalisationPageState createState() => _BluetoothLocalisationPageState();
}

class _BluetoothLocalisationPageState extends State<BluetoothLocalisationPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return Scaffold(
              );
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle1
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}


class Bluetooth {
  late FlutterBlue _fb;

  List<String> knownUuid = ['60:C0:BF:26:E0:DE', '60:C0:BF:26:E0:00', '60:C0:BF:26:E0:8A', '60:C0:BF:26:DF:63', '60:C0:BF:26:E0:A5']; //"60:C0:BF:26:E0:00" stuck at -17dbm

  Bluetooth(WrapperDynamoDB dbObj) {
    _fb = FlutterBlue.instance;
    knownUuid = dbObj.getKnownUuid();
  }

  // Private Methods

  // Public Methods
  Map<String, double> scanForever() {
    Map<String, double> bestThreeRssi = {};

    // Start scanning
    _fb.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    _fb.scanResults.listen((results) {
      // Sorts results in descending order
      results
          .sort((a, b) => ((b.rssi).toDouble()).compareTo((a.rssi).toDouble()));
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
      print(results);
      // TODO: store rssi into bestThreeRssi
    });

    return bestThreeRssi;
  }
}
