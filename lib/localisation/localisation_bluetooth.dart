import 'package:flutter_blue/flutter_blue.dart';
import 'localisation_dynamodb.dart';

class Bluetooth {
  late FlutterBlue _fb;

  List<String> knownUuid = [];

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
