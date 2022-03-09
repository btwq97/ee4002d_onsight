import 'dart:async';
import 'dart:io';
import 'dart:collection';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:on_sight/services/onsight.dart';

class Mqtt {
  late MqttServerClient _client;

  String _username = '';
  String _password = '';

  // ==== Private Methods ====
  /// Constructor.
  ///
  /// Inputs:
  /// 1) host [String].
  /// 2) username [String].
  /// 3) password [String].
  Mqtt({
    required String host,
    required String username,
    required String password,
  }) {
    _username = username;
    _password = password;
    _client = MqttServerClient(host, 'flutter_client');
  }

  /// Converts input hashMap to json payload.
  ///
  /// Inputs:
  /// 1) hashMap [LinkedHashMap<String,dynamic>] - examples of raw payload.
  /// e.g. {
  ///         "rssi": {
  ///               "9d9214f8-8870-43dd-a496-401765bf7866": -61.6888,
  ///               "40409a6a-ec8b-4d24-b496-9bd2e78c044f": -73.5868,
  ///               "87ccf436-0f86-4dfe-80f9-9ff731033620": -75.7231
  ///         },
  ///         "accelerometer": [-33.57, 86.31, 12.2],
  ///         "magnetometer": [-33.57, 86.31, 12.2],
  ///         "x_coordinate": -53.600680425231964,
  ///         "y_coordinate": 200.09818188520637,
  ///         "direction":"North"
  ///      }
  /// 2) mode [Mode]:
  ///    - 0x1: 'fyp/test/datapipeline'
  ///    - 0x2: 'fyp/test/sc'
  ///
  /// Returns:
  /// 1) result [String].
  String _mapToString(LinkedHashMap<String, dynamic> hashMap,
      {required Mode mode}) {
    String result = '{'; // initial json string

    switch (mode) {
      case Mode.DATA_PIPELINE:
        hashMap.forEach((key, value) {
          switch (key) {
            case 'time':
              result += '\"$key\":\"$value\",';
              break;
            case 'rssi':
              LinkedHashMap<String, num> allRssi = value;
              int count = allRssi.length;

              result += '\"$key\":{';
              value.forEach((rssiKey, rssiValue) {
                result += '\"$rssiKey\":$rssiValue';
                if (count == 1) {
                  result += '},';
                } else {
                  result += ',';
                }
                count -= 1;
              });
              break;
            case 'accelerometer':
              result += '\"$key\":[${value[0]}, ${value[1]}, ${value[2]}],';
              break;
            case 'magnetometer':
              result += '\"$key\":[${value[0]}, ${value[1]}, ${value[2]}],';
              break;
            case 'x_coordinate':
              result += '\"$key\":${value},';
              break;
            case 'y_coordinate':
              result += '\"$key\":${value},';
              break;
            case 'direction':
              Map<String, String> direction = value;
              direction.forEach((dkey, dvalue) {
                result += '\"$dkey\":\"${dvalue}\",';
              });
              result = result.substring(
                0,
                result.length - 1,
              ); // to remove last comma
              break;
            default:
              break;
          }
        });
        break;

      case Mode.SYSTEM_TESTING:
        int count = hashMap.length;
        hashMap.forEach((key, value) {
          switch (key) {
            case 'time':
              result += '\"$key\":\"$value\"';
              break;
            default:
              result += '\"$key\":$value';
              break;
          }
          if (count != 1) {
            result += ',';
          }
          count -= 1;
        });
        break;

      default:
        break;
    }

    result += '}';
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
  /// 1) payload [LinkedHashMap<String,dynamic>] - example of a raw payload.
  /// e.g. {
  ///         "rssi": {
  ///               "9d9214f8-8870-43dd-a496-401765bf7866": -61.6888,
  ///               "40409a6a-ec8b-4d24-b496-9bd2e78c044f": -73.5868,
  ///               "87ccf436-0f86-4dfe-80f9-9ff731033620": -75.7231
  ///         },
  ///         "accelerometer": [-33.57, 86.31, 12.2],
  ///         "magnetometer": [-33.57, 86.31, 12.2],
  ///         "x_coordinate": -53.600680425231964,
  ///         "y_coordinate": 200.09818188520637,
  ///         "direction":"North"
  ///      }
  /// 2) topic [String] - default is 'fyp/test/datapipeline'.
  /// 3) mode [int]:
  ///    - 0x1: 'fyp/test/datapipeline'
  ///    - 0x2: 'fyp/test/sc'
  ///
  /// Return:
  /// 1) None
  void publish(
    LinkedHashMap<String, dynamic> payload, {
    String topic = 'fyp/test/datapipeline',
    required Mode mode,
  }) {
    MqttClientPayloadBuilder _builder = MqttClientPayloadBuilder();
    _builder.addString(_mapToString(payload, mode: mode));
    _client.publishMessage(topic, MqttQos.exactlyOnce, _builder.payload!);
  }

  /// Connect to MQTT server.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) None.
  void disconnnectFromMqttServer() {
    _client.disconnect();
  }
}
