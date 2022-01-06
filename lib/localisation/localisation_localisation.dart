import 'dart:core';
import 'dart:math';
import 'localisation_my_numdart.dart';
import 'localisation_dynamodb.dart';

class Localisation {
  late MyNumDart _nd;

  /// Note: conditions here differs from the four cases that we have.
  /// Case 1: All three circles intercept at exactly one point.
  /// Case 2: All three circles overlap each other to form an area.
  /// Case 3: The two circles with the smallest radiuses intercept but the last
  ///         circle do not.
  /// Case 4: The two circles with the smallest radiuses do not intercept at all.
  ///
  /// Conditions of different circles:
  /// 'TANGENTIAL': 1
  /// 'OVERLAP': 2,
  /// 'NO INTERCEPT': 3,
  /// 'EXACT': 4
  Map<String, int> _circleConditions = {};

  /// Known locations of beacons
  /// key: uuid, value: [x_coordinate, y_coordinate]
  Map<String, List<double>> _knownBeacons = {
    '60:C0:BF:26:E0:DE' : [-482.5, 287.5],
    '60:C0:BF:26:E0:8A' : [482.5, 487.5],
    '60:C0:BF:26:DF:63' : [0.0, 0.0],
    '60:C0:BF:26:E0:A5' : [482.5, -487.5]
  };

  // ==== Private Methods ====
  // Localisation(WrapperDynamoDB dbObj) {
  Localisation() {
    _nd = MyNumDart();
    // _knownBeacons = dbObj.getKnownBeaconsPositions();
    _circleConditions = {
      'TANGENTIAL': 1,
      'OVERLAP': 2,
      'NO INTERCEPT': 3,
      'EXACT': 4
    };
  }

  /// Retrieve details of circle coordinates and diameters and convert from Map
  /// to List.
  ///
  /// Input:
  /// 1) inputMap [Map<String, double>] - {key:uuid, value:distances in meters}.
  ///
  /// Returns:
  /// 1) circles [List<List<double>>] (ascending order by radius).

  List<List<double>> _mapToList(Map<String, double> inputMap) {
    int metersToCentimeters = 100;
    double x1, x2, x3, y1, y2, y3, r1, r2, r3;
    List<String> uuid = [];

    inputMap.forEach((key, value) {
      uuid.add(key);
    });

    x1 = _knownBeacons[uuid[0]]![0]; // Note: ! is for null checks
    y1 = _knownBeacons[uuid[0]]![1];
    x2 = _knownBeacons[uuid[1]]![0];
    y2 = _knownBeacons[uuid[1]]![1];
    x3 = _knownBeacons[uuid[2]]![0];
    y3 = _knownBeacons[uuid[2]]![1];

    r1 = inputMap[uuid[0]]! * metersToCentimeters;
    r2 = inputMap[uuid[1]]! * metersToCentimeters;
    r3 = inputMap[uuid[2]]! * metersToCentimeters;

    List<List<double>> circles = [
      [x1, y1, r1],
      [x2, y2, r2],
      [x3, y3, r3]
    ];

    // sorts by radius
    circles.sort((a, b) => a[2].compareTo(b[2]));

    return circles;
  }

  /// Determine if the two circles are tangential, overlaps (intercept at 2
  /// points), or has no intercept at all.
  ///
  /// Input:
  /// 1) circleA [List<List<double>>] - details of circle e.g. X coordinate,
  ///                                   Y coordinate, and Radius.
  /// 2) circleB [List<List<double>>] - details of circle e.g. X coordinate,
  ///                                   Y coordinate, and Radius.
  ///
  /// Returns:
  /// 1) Statuses of circles [String] - 'TANGENTIAL', 'OVERLAP',
  ///                                   or 'NO INTERCEPT'.
  int _statusOfTwoCircles(List<double> circleA, List<double> circleB) {
    List<double> vectorA = [circleA[0], circleA[1]];
    List<double> vectorB = [circleB[0], circleB[1]];

    double radius = _nd.vectorAdd([circleA[2]], [circleB[2]])[0];

    List<double> vectorAB = _nd.vectorAdd(_nd.negateList(vectorA), vectorB);
    double magnitude = _nd.vectorMagnitude(vectorAB);

    if (radius == magnitude) {
      return _circleConditions['TANGENTIAL'] ?? 1;
    } else if (radius > magnitude) {
      return _circleConditions['OVERLAP'] ?? 2;
    } else if (radius < magnitude) {
      return _circleConditions['NO INTERCEPT'] ?? 3;
    } else {
      return -1; // TODO: replace placeholder with throw statement.
    }
  }

  /// Find the intercepts of two circles.
  ///
  /// Inputs:
  /// 1) circleA [List<double>] - details of circle e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  /// 1) circleB [List<double>] - details of circle e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  ///
  /// Returns:
  /// 1) intercepts [List<double>]
  List<List<double>> _interceptOfTwoCircles(
      List<double> circleA, List<double> circleB) {
    double x1 = circleA[0];
    double x2 = circleB[0];
    double y1 = circleA[1];
    double y2 = circleB[1];
    double r1 = circleA[2];
    double r2 = circleB[2];
    List<List<double>> intercepts = [[]];

    if (y1 == y2) {
      // solving for x
      double x = (pow(r1, 2).toDouble() -
          pow(r2, 2).toDouble() -
          pow(x1, 2).toDouble() +
          pow(x2, 2).toDouble()) /
          (-2 * x1 + 2 * x2);
      // solving quadratically for y
      double a = 1;
      double b = -2 * y1;
      double c = pow(y1, 2).toDouble() +
          pow(x, 2).toDouble() -
          2 * x1 * x +
          pow(x1, 2).toDouble() -
          pow(r1, 2).toDouble();

      List<double> yRoots = _nd.vectorRoots(a, b, c);

      intercepts = [
        [x, yRoots[0]],
        [x, yRoots[1]]
      ];
    } else if (x1 == x2) {
      // solving for y
      double y = (pow(r1, 2).toDouble() -
          pow(r2, 2).toDouble() -
          pow(y1, 2).toDouble() +
          pow(y2, 2).toDouble()) /
          (-2 * y1 + 2 * y2);
      // solving quadratically for x
      double a = 1;
      double b = -2 * x1;
      double c = pow(x1, 2).toDouble() +
          pow(y, 2).toDouble() -
          2 * y1 * y +
          pow(y1, 2).toDouble() -
          pow(r1, 2).toDouble();

      List<double> xRoots = _nd.vectorRoots(a, b, c);

      intercepts = [
        [xRoots[0], y],
        [xRoots[1], y]
      ];
    } else {
      double A = -2 * x1 + 2 * x2;
      double B = -2 * y1 + 2 * y2;
      double C = pow(y1, 2).toDouble() -
          pow(y2, 2).toDouble() +
          pow(x1, 2).toDouble() -
          pow(x2, 2).toDouble() -
          pow(r1, 2).toDouble() +
          pow(r2, 2).toDouble();

      // solving quadratically
      double a = pow(B, 2).toDouble() + pow(A, 2).toDouble();
      double b = -2 * x1 * pow(B, 2).toDouble() + 2 * A * C + 2 * y1 * B * A;
      double c = pow(B, 2).toDouble() * pow(x1, 2).toDouble() +
          pow(C, 2).toDouble() +
          2 * y1 * B * C +
          pow(B, 2).toDouble() * pow(y1, 2).toDouble() -
          pow(B, 2).toDouble() * pow(r1, 2).toDouble();

      List<double> xRoots = _nd.vectorRoots(a, b, c);
      List<double> yRoots = [];
      for (int i = 0; i < xRoots.length; i++) {
        double temp;
        temp = (-C - (A * xRoots[i])) / B;
        yRoots.add(temp);
      }

      // sort by x coordinate
      intercepts = [
        [xRoots[0], yRoots[0]],
        [xRoots[1], yRoots[1]]
      ];
    }

    intercepts.sort((a, b) => a[0].compareTo(b[0]));

    return intercepts;
  }

  /// Determines if the third circle falls within the intercection of the two
  /// intial circles.
  ///
  /// Input:
  /// 1) intercepts [List<double>].
  /// 2) circleC [List<double>] - details of circle e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  ///
  /// Return:
  /// 1) Status [int] - 'OVERLAP', 'NO INTERCEPT', or 'EXACT'.
  int _statusOfThirdCircle(
      List<List<double>> intercepts, List<double> circleC) {
    List<double> vectorA = intercepts[0];
    List<double> vectorB = intercepts[1];
    List<double> vectorC = circleC.sublist(0, 2);
    double radiusC = circleC[2];

    List<double> vectorAC = _nd.vectorAdd(_nd.negateList(vectorA), vectorC);
    double magnitudeAC = _nd.vectorMagnitude(vectorAC);
    List<double> vectorBC = _nd.vectorAdd(_nd.negateList(vectorB), vectorC);
    double magnitudeBC = _nd.vectorMagnitude(vectorBC);

    if (_nd.isClose(magnitudeAC, radiusC) ||
        (magnitudeAC == radiusC) ||
        _nd.isClose(magnitudeBC, radiusC) ||
        (magnitudeBC == radiusC)) {
      return _circleConditions['EXACT'] ?? 4;
    }

    if ((radiusC < magnitudeAC && radiusC > magnitudeBC) ||
        (radiusC < magnitudeBC && radiusC > magnitudeAC)) {
      return _circleConditions['OVERLAP'] ?? 2;
    } else {
      return _circleConditions['NO INTERCEPT'] ?? 3;
    }
  }

  /// Solve for the exact intercection point between three circles.
  /// Reference:
  /// https://www.101computing.net/cell-phone-trilateration-algorithm/
  ///
  /// Input:
  /// 1) circles [List<List<double>>] - details of circles e.g. X coordinate,
  ///                                   Y coordinate, and Radius.
  ///
  /// Return:
  /// 1) estimate [Map<String, dynamic>] - {'x_coordinate': X, 'y_coordinate': Y}
  Map<String, dynamic> _exactInterceptWithThreeCircles(circles) {
    List<double> circleA = circles[0];
    List<double> circleB = circles[1];
    List<double> circleC = circles[2];

    double x1 = circleA[0];
    double y1 = circleA[1];
    double r1 = circleA[2];
    double x2 = circleB[0];
    double y2 = circleB[1];
    double r2 = circleB[2];
    double x3 = circleC[0];
    double y3 = circleC[1];
    double r3 = circleC[2];

    double A = -2 * x1 + 2 * x2;
    double B = -2 * y1 + 2 * y2;
    double C = pow(r1, 2).toDouble() -
        pow(r2, 2).toDouble() -
        pow(x1, 2).toDouble() +
        pow(x2, 2).toDouble() -
        pow(y1, 2).toDouble() +
        pow(y2, 2).toDouble();
    double D = -2 * x2 + 2 * x3;
    double E = -2 * y2 + 2 * y3;
    double F = pow(r2, 2).toDouble() -
        pow(r3, 2).toDouble() -
        pow(x2, 2).toDouble() +
        pow(x3, 2).toDouble() -
        pow(y2, 2).toDouble() +
        pow(y3, 2).toDouble();

    double X = (C * E - F * B) / (E * A - B * D);
    double Y = (C * D - A * F) / (B * D - A * E);

    Map<String, dynamic> estimate = {'x_coordinate': X, 'y_coordinate': Y};

    return estimate;
  }

  /// Finding the most inner coordinate with respect to the center of circle
  /// directly across the coordinate.
  ///
  /// Inputs:
  /// 1) interceptA [List<double>].
  /// 2) interceptB [List<double>].
  /// 3) center [List<double>] - center of circle that is not related to
  ///                            interceptA and interceptB.
  ///
  /// Return:
  /// 1) innerCoor [List<double>].
  List<double> _innerIntersection(
      List<double> interceptA, List<double> interceptB, List<double> center) {
    List<double> vectorAC = _nd.vectorAdd(_nd.negateList(interceptA), center);
    List<double> vectorBC = _nd.vectorAdd(_nd.negateList(interceptB), center);

    double magAC = _nd.vectorMagnitude(vectorAC);
    double magBC = _nd.vectorMagnitude(vectorBC);

    if (magAC > magBC) {
      return interceptB;
    }
    return interceptA;
  }

  /// Approximate the intersection point when all three circles overlap each
  /// other and forms an area of triangle.
  ///
  /// Inputs:
  /// 1) circles [List<List<double>>] - details of circles e.g. X coordinate,
  ///                                   Y coordinate, and Radius.
  /// 2) interceptA [List<List<double>>] - intercepts between circleA and
  ///                                      circleB.
  ///
  /// Returns:
  /// 1) estimate [Map<String,dynamic>] - {'x_coordinate': X, 'y_coordinate': Y}
  Map<String, dynamic> _estimatedInterceptWhenThreeCirclesOverlap(
      List<List<double>> circle, List<List<double>> interceptA) {
    List<List<double>> interceptB =
    _interceptOfTwoCircles(circle[0], circle[2]);
    List<List<double>> interceptC =
    _interceptOfTwoCircles(circle[1], circle[2]);

    List<double> innerA = _innerIntersection(
        interceptA[0], interceptA[1], circle[2].sublist(0, 2));
    List<double> innerB = _innerIntersection(
        interceptB[0], interceptB[1], circle[1].sublist(0, 2));
    List<double> innerC = _innerIntersection(
        interceptC[0], interceptC[1], circle[0].sublist(0, 2));

    double X = (innerA[0] + innerB[0] + innerC[0]) / 3;
    double Y = (innerA[1] + innerB[1] + innerC[1]) / 3;

    Map<String, dynamic> estimate = {'x_coordinate': X, 'y_coordinate': Y};

    return estimate;
  }

  /// Find the coordinate of the circle along its circumference that is closest
  /// to the center of the last circle.
  ///
  /// Input:
  /// 1) gradient [double] - gradient of line intersecting the two centers of
  ///                        two circles.
  /// 2) constant [double] - constant in Y = mX + C.
  /// 3) centerX [double] - x coordinate of center of circle.
  /// 4) circle [<List<double>] - details of circle e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  /// Return:
  /// 1) intercept [List<double>].
  List<double> _coordinateClosestToCircle(
      double gradient, double constant, double centerX, List<double> circle) {
    double X = circle[0];
    double Y = circle[1];
    double R = circle[2];

    double A = 1 + pow(gradient, 2).toDouble();
    double B = -2 * X + 2 * gradient * constant - 2 * Y * gradient;
    double C = pow(X, 2).toDouble() +
        pow(constant, 2).toDouble() -
        2 * Y * constant +
        pow(Y, 2).toDouble() -
        pow(R, 2).toDouble();

    List<double> xRoots = _nd.vectorRoots(A, B, C);
    xRoots.sort((a, b) => b.compareTo(a)); // sort in descending order
    List<double> xRootsCopy = List.from(xRoots); // create a deep copy

    for (int i = 0; i < xRootsCopy.length; i++) {
      xRootsCopy[i] = pow(xRootsCopy[i] - centerX, 2).toDouble();
    }

    int index = xRootsCopy.indexOf(
        xRootsCopy.reduce(min)); // returning the index of the smallest x root

    return [xRoots[index], (gradient * xRoots[index]) + constant];
  }

  /// Used when the two circles with the smallest radiuses do not intersect
  /// each other. We first obtain the best estimate between the two circles
  /// using weights based on their radius. We call the estimate, AB.
  ///
  /// Once we obtained AB, we find the best estimate between the estimate and
  /// the closest point of the last circle along its circumference.
  ///
  /// The last estimate would be the estimated location.
  ///
  /// Input:
  /// 1) circles [List<List<double>>] - details of circles e.g. X coordinate,
  ///                                   Y coordinate, and Radius.
  /// Return:
  /// 1) estimate [Map<String,dynamic>] - {'x_coordinate': X, 'y_coordinate': Y}.
  Map<String, dynamic> _estimatedPositionWhenTwoSmallestCirclesDoNotIntercept(
      List<List<double>> circles) {
    List<double> circleA = circles[0];
    List<double> circleB = circles[1];
    List<double> circleC = circles[2];

    double x1 = circleA[0];
    double y1 = circleA[1];
    double r1 = circleA[2];
    double x2 = circleB[0];
    double y2 = circleB[1];
    double r2 = circleB[2];
    double x3 = circleC[0];
    double y3 = circleC[1];
    double r3 = circleC[2];

    double gradient = (y1 - y2) / (x1 - x2);
    double constant = y1 - gradient * x1;

    // For circleA
    List<double> closestInterceptA =
    _coordinateClosestToCircle(gradient, constant, x2, circles[0]);
    // For circleB
    List<double> closestInterceptB =
    _coordinateClosestToCircle(gradient, constant, x1, circles[1]);
    // estimate AB
    List<double> vectorAB = [
      (r1 * closestInterceptB[0] + r2 * closestInterceptA[0]) / (r1 + r2),
      (r1 * closestInterceptB[1] + r2 * closestInterceptA[1]) / (r1 + r2)
    ];

    gradient = (vectorAB[1] - y3) / (vectorAB[0] - x3);
    constant = y3 - gradient * x3;

    // For circleC
    List<double> closestInterceptC =
    _coordinateClosestToCircle(gradient, constant, vectorAB[0], circles[2]);

    return {
      'x_coordinate':
      (r2 * closestInterceptC[0] + r3 * vectorAB[0]) / (r2 + r3),
      'y_coordinate': (r2 * closestInterceptC[1] + r3 * vectorAB[1]) / (r2 + r3)
    };
  }

  /// Used when the two circles with the smallest radiuses intercepts but the
  /// last circle do not.
  ///
  /// We first find the estimated position of the intersection points between
  /// two circles with the smallest radiuses. We call the point AB.
  ///
  /// Next, we draw an imaginary line to the center of the last circle, taking
  /// the value closest to point AB. We find the estimated position from AB to
  /// the closest value.
  ///
  /// Input:
  /// 1) intercepts [List<double>] - intercepts of the two circles with the
  ///                                smallest radiuses.
  /// 2) radiusA [double] - radius of circle A.
  /// 3) radiusB [double] - radius of circle B.
  /// 4) circleC [List<double>] - details of circles e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  ///
  /// Return:
  /// 1) estimate [Map<String,dynamic>] - {'x_coordinate': X, 'y_coordinate': Y}.
  Map<String, dynamic>
  _estimatedPositionWhenTwoCirclesInterceptButLastCircleDoNot(
      List<List<double>> intercepts,
      double radiusA,
      double radiusB,
      List<double> circleC) {
    List<double> interceptA = intercepts[0];
    List<double> interceptB = intercepts[1];
    double x3 = circleC[0];
    double y3 = circleC[1];
    double r3 = circleC[2];

    // Estimated position AB
    List<double> vectorAB = [
      (radiusA * interceptB[0] + radiusB * interceptA[0]) / (radiusA + radiusB),
      (radiusA * interceptB[1] + radiusB * interceptA[1]) / (radiusA + radiusB)
    ];

    // Finding best estimated position
    double gradient = (vectorAB[1] - y3) / (vectorAB[0] - x3);
    double constant = y3 - gradient * x3;

    List<double> closestCoord =
    _coordinateClosestToCircle(gradient, constant, vectorAB[0], circleC);

    return {
      'x_coordinate':
      (radiusB * closestCoord[0] + r3 * vectorAB[0]) / (radiusB + r3),
      'y_coordinate':
      (radiusB * closestCoord[1] + r3 * vectorAB[1]) / (radiusB + r3)
    };
  }

  /// Log Distance Path Loss Model
  ///
  /// RSSI = RSSd0 - 10*n*log(d/d0) + X
  /// Hence, estDistance, d = d0 * 10^((RSSI - RSSd0 - X)/10*n)
  /// where,
  /// d - distance.
  /// d0 - measured RSSI at distance d0 meters.
  /// RSSId0 - RSSI measured at d0 meters away. This is the baseline.
  /// x - mitigation loss [default=0].
  /// n - path loss exponent [default=3].

  /// References:
  /// 1) https://journals.sagepub.com/doi/full/10.1155/2014/371350
  /// 2) https://mdpi-res.com/d_attachment/sensors/sensors-17-02927/article_deploy/sensors-17-02927-v2.pdf
  ///
  /// Input:
  /// 1) rssi [double]
  ///
  /// Returns:
  /// 1) estDistance [double] - estimated diatances converted from RSSI in meters.
  double _rssiToDistance(double rssi) {
    double RSSId0 = (-62.2).abs(); // #TODO: maybe can modify this in RUNTIME.
    int n = 3;
    int d0 = 1;
    int x = -10;
    double exponent = (rssi.abs() - RSSId0 - x) / (10 * n);
    double distance = (d0 * (pow(10, exponent))).toDouble();

    return distance;
  }

  /// Log Distance Path Loss Model
  ///
  /// RSSI = RSSd0 - 10*n*log(d/d0) + X
  /// Hence, estDistance, d = d0 * 10^((RSSI - RSSd0 - X)/10*n)
  /// where,
  /// d - distance.
  /// d0 - measured RSSI at distance d0 meters.
  /// RSSId0 - RSSI measured at d0 meters away. This is the baseline.
  /// x - mitigation loss [default=0].
  /// n - path loss exponent [default=3].

  /// References:
  /// 1) https://journals.sagepub.com/doi/full/10.1155/2014/371350
  /// 2) https://mdpi-res.com/d_attachment/sensors/sensors-17-02927/article_deploy/sensors-17-02927-v2.pdf
  ///
  /// Input:
  /// 1) distance [double] - distance in meters.
  ///
  /// Returns:
  /// 1) estRssi [double] - estimated diatances converted from RSSI.
  double _distanceToRssi(double distance) {
    double RSSId0 = (-62.2).abs(); // #TODO: maybe can modify this in RUNTIME.
    int n = 3;
    int d0 = 1;
    int x = -10;

    // Note: log10(0) = undefined
    double estRssi = -(RSSId0 + 10 * n * _nd.logBase(distance / d0, 10) + x);

    return estRssi;
  }

  /// Trilateration
  ///
  /// Input:
  /// 1) distances [Map<String,double>] - {key:uuid, value: radius distances in meters}.
  ///
  /// Returns:
  /// 1) estimate [Map<String, dynamic>] - {'x_coordinate':<>, 'y_coordinate':<>}
  Map<String, dynamic> _trilateration(Map<String, double> distances) {
    Map<String, dynamic> estimate = {}; // final estimate
    List<List<double>> circles = _mapToList(distances);
    // // Case: circles with the two smallest radiuses overlaps
    int statusOfTwoSmallestCircles =
    _statusOfTwoCircles(circles[0], circles[1]);
    if (statusOfTwoSmallestCircles == (_circleConditions['OVERLAP'] ?? 2)) {
      List<List<double>> interceptA =
      _interceptOfTwoCircles(circles[0], circles[1]);

      // Case: last circle overlaps exactly with interceptA
      int statusOfLastCircles = _statusOfThirdCircle(interceptA, circles[2]);
      if (statusOfLastCircles == (_circleConditions['EXACT'] ?? 4)) {
        print('Performing Case 1: Three circles intercept exactly.');
        estimate = _exactInterceptWithThreeCircles(circles);
      }
      // Case: last circle overlaps with the other two smaller circles
      else if (statusOfLastCircles == (_circleConditions['OVERLAP'] ?? 2)) {
        print('Performing Case 2: Three circles overlaps each other.');
        estimate =
            _estimatedInterceptWhenThreeCirclesOverlap(circles, interceptA);
      }
      // Case: last circle do not overlap or intercept at all
      else {
        print(
            'Performing Case 3: Only the two smallest circles intercept but the last do not.');
        estimate = _estimatedPositionWhenTwoCirclesInterceptButLastCircleDoNot(
            interceptA, circles[0][2], circles[1][2], circles[2]);
      }
    }
    // Case: circles with the two smallest radiuses do not overlap
    else if (statusOfTwoSmallestCircles ==
        (_circleConditions['NO INTERCEPT'] ?? 3)) {
      print('Performing Case 4: Two smallest circles do not intercept.');
      estimate =
          _estimatedPositionWhenTwoSmallestCirclesDoNotIntercept(circles);
    }
    // Case: Circles with two smallest circles are tangential to each other
    // TODO: write case for tangential

    return estimate;
  }

  //==== Public Methods ====
  /// Wrapper for trilateration
  ///
  /// Inputs:
  /// 1) rawData [Map<String,dynamic] - keys include 'rssi', 'accelerometer',
  ///                                   and 'magnetometer'.
  ///
  /// Returns:
  /// 1) result [Map<String,dynamic>] - {'x_coordinate': X, 'y_coordinate': Y,
  ///                                   'direction':direction}
  Map<String, dynamic> localisation(Map<String, dynamic> rawData) {
    Map<String, double> distances = {};

    rawData.forEach((key, value) {
      if (key == 'rssi') {
        rawData['rssi'].forEach((uuid, rssi) {
          distances[uuid] = _rssiToDistance(rssi);
        });
      }
      // TODO: add in additional features
      else if (key == 'magnetometer') {
      } else if (key == 'accelerometer') {
      } else {}
    });

    Map<String, dynamic> result = {};
    result = _trilateration(distances);
    result['direction'] = 'North';

    return result;
  }
}
