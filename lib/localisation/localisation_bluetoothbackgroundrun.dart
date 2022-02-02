import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';
import 'dart:isolate';

//Current implementation. To be verified once the RPis arrive since the beacons are not working
Isolate? isolate;
FlutterBlue flutterBlue = FlutterBlue.instance;
List<String> knownUuid = [
  '60:C0:BF:26:E0:DE',
  '60:C0:BF:26:E0:8A',
  '60:C0:BF:26:DF:63',
  '60:C0:BF:26:E0:A5',
  '60:C0:BF:26:E0:00'
];
Map<String, int> topFour = {};

class IsolateTest extends StatefulWidget {
  @override
  _IsolateTestState createState() => _IsolateTestState();
}

class _IsolateTestState extends State<IsolateTest> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  void initState() {
    /// Start background task
    _asyncInit();
    super.initState();
    flutterBlue.startScan(timeout: Duration(days: 4));
    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // sort results from least negative to most negative
      for (ScanResult r in results) {
        results.sort(
            (a, b) => ((b.rssi).toDouble()).compareTo((a.rssi).toDouble()));
        if (topFour.length == 5) {
          print(topFour);
          break;
        }
        for (String uuid in knownUuid) {
          print('uuid = $uuid, scanned = ${r.device.id}');
          if (uuid == r.device.id.toString()) {
            topFour[uuid] = r.rssi;
            print(topFour);
          }
        }
      }
    });

    flutterBlue.stopScan();
  }

  _asyncInit() async {
    ReceivePort receivePort = ReceivePort();
    isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);

    receivePort.listen((dynamic data) {
      if (data is SendPort) {
        if (mounted) {
          data.send({
            /// Map data using key-value pair
            /// i.e. 'key' : String
            //knownUuid : r.rssi;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            /// Update data here as needed
          });
        }
      }
    });
  }

  static _isolateEntry(dynamic d) async {
    final ReceivePort receivePort = ReceivePort();
    d.send(receivePort.sendPort);

    /// config contains the key-value pair from _asyncInit()
    final config = await receivePort.first;

    /// send bluetooth data you received
    d.send(topFour);
  }

  @override
  void dispose() {
    /// Determine when to terminate the Isolate
    if (isolate != null) {
      isolate?.kill();
    }
    super.dispose();
  }
}
// class _IsolateTestState extends State<IsolateTest> {
//
//   @override
//   void initState() {
//     super.initState();
//     createIsolate();
//   }
//
//   Future createIsolate() async {
//     ReceivePort receivePort = ReceivePort();
//     SendPort childSendPort = receivePort.first as SendPort;
//
//     ReceivePort responsePort = ReceivePort();
//     childSendPort.send(["rssi", responsePort.sendPort]);
//
//     Isolate.spawn((SendPort mainSendPort) async {
//       ReceivePort childReceivePort = ReceivePort();
//       mainSendPort.send(childReceivePort.sendPort);
//
//       await for (topFour in childReceivePort) {
//         // Start scanning
//         flutterBlue.startScan(timeout: Duration(seconds: 4));
//         // Listen to scan results
//         var subscription = flutterBlue.scanResults.listen((results) {
//           // sort results from least negative to most negative
//           for (ScanResult r in results) {
//             if (topFour.length == 5) {
//               break;
//             }
//             for (String uuid in knownUuid) {
//               if (uuid == r.device.id.toString()) {
//                 topFour[uuid] = r.rssi;
//                 results.sort((a, b) =>
//                     ((b.rssi).toDouble()).compareTo((a.rssi).toDouble()));
//               }
//             }
//           }
//         });
//       }
//     }, receivePort.sendPort);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }
