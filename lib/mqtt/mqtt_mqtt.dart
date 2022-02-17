import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Mqtt {
  late MqttServerClient _client;

  String _username = '';
  String _password = '';
  int _attempt = -1;

  // ==== Private Methods ====
  /// Constructor.
  ///
  /// Inputs:
  /// 1) host [String].
  /// 2) username [String].
  /// 3) password [String].
  Mqtt(String host, String username, String password) {
    _username = username;
    _password = password;
    _attempt = 0;
    _client = MqttServerClient(host, 'flutter_client');
  }

  /// Converts input map to json payload.
  ///
  /// Inputs:
  /// 1) map [Map<String,dynamic>] - examples of raw payload.
  /// result mode
  /// e.g. {
  ///         "x_coordinate": -53.600680425231964,
  ///         "y_coordinate": 200.09818188520637,
  ///         "direction":"North"
  ///      }
  ///
  /// rssi mode
  /// e.g. {
  ///         "rssi": {
  ///               "9d9214f8-8870-43dd-a496-401765bf7866": -61.6888,
  ///               "40409a6a-ec8b-4d24-b496-9bd2e78c044f": -73.5868,
  ///               "87ccf436-0f86-4dfe-80f9-9ff731033620": -75.7231
  ///         },
  ///         'accelerometer': 5,
  ///         'magnetometer': [-33.57, 86.31]
  ///      }
  ///
  /// Returns:
  /// 1) result [String].
  String _mapToString(Map<String, dynamic> map, String mode) {
    String result = '';
    if (mode == 'rssi') {
      Map<String, double> temp = map["rssi"];

      // start of string builder
      result = '{"mode":"$mode","attempt":$_attempt,"rssi":{';
      int count = 0; // counter to track key items
      temp.forEach((uuid, rssi) {
        if (count != 2) {
          result += '"${uuid.toString()}":$rssi,';
        } else {
          // end off with } to close the json string
          result += '"${uuid.toString()}":$rssi}';
        }
        count++;
      });
      result += '}';
    } else if (mode == 'result') {
      result = '{"mode":"$mode","attempt":$_attempt,"result":{';
      int count = 0; // counter to track key items
      map.forEach((coor, pos) {
        if (coor == 'direction') {
          // skip direction
        } else {
          if (count != 1) {
            result += '"$coor":$pos,';
          } else {
            // end off with } to close the json string
            result += '"$coor":$pos}';
          }
        }
        count++;
      });
      result += '}';
      _attempt++; // '_attempt' updates itself after both rssi and results comes in
    }
    return result;
  }

  // ==== Public Methods ====
  /// Initialise connection to MQTT server.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) None.
  Future init() async {
    try {
      await _client.connect(_username, _password);
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      print('EXAMPLE::client exception - $e');
      _client.disconnect();
    } on SocketException catch (e) {
      // Raised by the socket layer
      print('EXAMPLE::socket exception - $e');
      _client.disconnect();
    }
  }

  /// Publish payload to specified topic.
  ///
  /// Input:
  /// 1) rawData [Map<String,dynamic>] - examples of raw payload.
  /// e.g. {
  ///         "x_coordinate": -53.600680425231964,
  ///         "y_coordinate": 200.09818188520637,
  ///         "direction":"North"
  ///      }
  /// or   {
  ///         "rssi": {
  ///               "9d9214f8-8870-43dd-a496-401765bf7866": -61.6888,
  ///               "40409a6a-ec8b-4d24-b496-9bd2e78c044f": -73.5868,
  ///               "87ccf436-0f86-4dfe-80f9-9ff731033620": -75.7231
  ///         },
  ///         'accelerometer': 5,
  ///         'magnetometer': [-33.57, 86.31]
  ///      }
  /// 2) mode [String] - either 'rssi' or 'result'.
  /// 3) topic [String] - default is 'test/pub'.
  ///
  /// Return:
  /// 1) None
  void publish(Map<String, dynamic> rawData, String mode,
      {String topic = 'test/pub'}) {
    MqttClientPayloadBuilder _builder = MqttClientPayloadBuilder();
    _builder.addString(_mapToString(rawData, mode));
    _client.publishMessage(topic, MqttQos.exactlyOnce, _builder.payload!);
  }

  /// Disconnects from MQTT server.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) None.
  Future disconnnect() async {
    await MqttUtilities.asyncSleep(1);
    _client.disconnect();
    await MqttUtilities.asyncSleep(1);
    exit(-1);
  }
}
