import 'package:decimal/decimal.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

// Reference: https://github.com/agilord/aws_client/issues/83
// Reference: https://pub.dev/documentation/aws_dynamodb_api/latest/dynamodb-2012-08-10/dynamodb-2012-08-10-library.html

class WrapperDynamoDB {
  late DynamoDB _service;

  String _tableName = '';
  String _primaryKey = '';
  String _venue = '';
  List<String> _knownUuid = ['FDD1BB34-B18E-5F7A-7019-3A5F3FD15957', '73F07E64-901F-7A5C-BDF3-A30752F5A05F', '641508E6-7E97-1BCE-0317-652200C4DD86', '438ED97B-C158-71D4-D5E6-B10136FDCE75', '3B55A5F1-FD5D-8198-63C9-B7D91E8BBE0D ']; //2nd and 5th beacon are the spoilt ones
  List<String> _knownMACAddress = ['60:C0:BF:26:E0:DE', '60:C0:BF:26:E0:00', '60:C0:BF:26:E0:8A', '60:C0:BF:26:DF:63', '60:C0:BF:26:E0:A5']; //2nd and 5th beacon are the spoilt ones
  Map<String, List<double>> _knownBeacons = {};

  // Private Methods
  /// Constructor
  ///
  /// Inputs:
  /// 1) region [String] - AWS region.
  /// 2) endPointUrl [String] - AWS DynamoDB end point url.
  /// 3) tableName [String] - AWS tablename.
  /// 4) primaryKey [String] - AWS primary key.
  /// 5) venue [String] - location of contention.
  WrapperDynamoDB(String region, String endPointUrl, String tableName,
      String primaryKey, String venue) {
    _tableName = tableName;
    _primaryKey = primaryKey;
    _venue = venue;

    _service = DynamoDB(region: region, endpointUrl: endPointUrl);
  }

  /// Queries all data in the specified tableName based on the primaryKey.
  ///
  /// Input:
  /// 1) tableName [String] - Name of table.
  /// 2) primaryKey [String] - Partition or Primary Key.
  /// 3) venue [String] - Location venue.
  ///
  /// Returns:
  /// 1) None
  Future _queryAllData(
      String tableName, String primaryKey, String venue) async {
    QueryOutput outcome = await _service.query(
        returnConsumedCapacity: ReturnConsumedCapacity.total,
        tableName: tableName,
        keyConditionExpression: '$primaryKey = :m',
        expressionAttributeValues: {':m': AttributeValue(s: venue)});

    for (var item in outcome.items ?? []) {
      String tempUuid = item['uuid'].s;
      // Store uuid in known uuid
      _knownUuid.add(tempUuid);

      // Store positions in _knownBeacons
      _knownBeacons[tempUuid] = [
        // Float is stored as a Decimal datatype as Python API does not support
        // storing of float numbers.
        (Decimal.parse(item['x_coordinate'].s)).toDouble(),
        (Decimal.parse(item['y_coordinate'].s)).toDouble()
      ];
    }
  }

  // Public Methods
  /// Connect to DynamoDB and initialise all data into its respective
  /// containers.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) None.
  Future init() async {
    await _queryAllData(_tableName, _primaryKey, _venue);
  }

  /// Retrieve all known UUIDs.
  ///
  /// Inputs:
  /// 1) None.
  ///
  /// Returns:
  /// 1) _knownUuid [List<String>]
  List<String> getKnownUuid() {
    return _knownUuid;
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
}
