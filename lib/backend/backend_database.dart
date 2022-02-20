import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_aws_api/shared.dart' as _s;

// Reference: https://github.com/agilord/aws_client/issues/83
// Reference: https://pub.dev/documentation/aws_dynamodb_api/latest/dynamodb-2012-08-10/dynamodb-2012-08-10-library.html
// Reference: https://docs.amplify.aws/cli/usage/mock/ (Just the part on "And configure the DynamoDB client with:")

class MyDatabase {
  late DynamoDB _service;
  final List<Uuid> _knownUuid = [];
  final List<String> _knownMac = [];
  final Map<String, List<double>> _knownBeacons = {};
  late List<Map<String, AttributeValue>> _mapData = [];

  // ==== Private Methods ====
  /// Constructor
  ///
  /// Inputs:
  /// 1) region [String] - AWS region.
  /// 2) endPointUrl [String] - AWS DynamoDB end point url.
  ///
  /// Returns:
  /// 1) None.
  MyDatabase({required String region, required String endPointUrl}) {
    _service = DynamoDB(
        region: region,
        endpointUrl: endPointUrl,
        credentials: _s.AwsClientCredentials(
            accessKey: 'FAKE_ACCESS_KEY', secretKey: 'FAKE_SECRET_KEY'));
  }

  /// Queries all beacon data in the specified tableName based on the primaryKey.
  ///
  /// Input:
  /// 1) tableName [String] - Name of table.
  /// 2) primaryKey [String] - Partition or Primary Key.
  /// 3) venue [String] - Location venue.
  ///
  /// Returns:
  /// 1) None
  Future _queryBeaconData(
    String tableName,
    String primaryKey,
    String venue,
  ) async {
    QueryOutput outcome = await _service.query(
        returnConsumedCapacity: ReturnConsumedCapacity.total,
        tableName: tableName,
        keyConditionExpression: '$primaryKey = :m',
        expressionAttributeValues: {':m': AttributeValue(s: venue)});

    for (var item in outcome.items ?? []) {
      // Store known UUID
      _knownUuid.add(Uuid.parse(item['uuid'].s));

      // Store known MAC address
      String tempMac = item['mac'].s;
      _knownMac.add(tempMac);

      // Store positions in _knownBeacons
      _knownBeacons.addEntries([
        MapEntry(tempMac, [
          // convert string to double
          double.parse(item['x_coordinate'].n),
          double.parse(item['y_coordinate'].n),
        ])
      ]);
    }
  }

  /// Queries all map data in the specified tableName based on the primaryKey.
  ///
  /// Input:
  /// 1) tableName [String] - Name of table.
  /// 2) primaryKey [String] - Partition or Primary Key.
  /// 3) venue [String] - Location venue.
  ///
  /// Returns:
  /// 1) None
  Future _queryMapData(
    String tableName,
    String primaryKey,
    String venue,
  ) async {
    QueryOutput outcome = await _service.query(
        returnConsumedCapacity: ReturnConsumedCapacity.total,
        tableName: tableName,
        keyConditionExpression: '$primaryKey = :m',
        expressionAttributeValues: {':m': AttributeValue(s: venue)});

    _mapData = outcome.items ?? [];
  }

  // ==== Public Methods ====
  /// Connect to DynamoDB and initialise all data into its respective
  /// containers.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) None.
  Future init() async {
    await _queryBeaconData('Locations', 'venue', 'TechnoEdge');
    await _queryMapData('Map', 'venue', 'TechnoEdge');
  }

  /// Retrieve all known UUIDs.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) _knownUuid [List<Uuid>]
  List<Uuid> getKnownUuid() {
    return _knownUuid;
  }

  List<String> getKnownMac() {
    return _knownMac;
  }

  /// Retrieve all known beacon positions.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) _knownBeacons [Map<String, List<double>>].
  Map<String, List<double>> getKnownBeaconsPositions() {
    return _knownBeacons;
  }

  /// Retrieve map positions.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) _knownBeacons [List<Map<String, AttributeValue>>].
  List<Map<String, AttributeValue>> getMapData() {
    return _mapData;
  }
}
