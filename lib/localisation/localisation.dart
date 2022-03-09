import 'dart:core';
import 'dart:math';
import 'dart:collection';

import 'package:on_sight/localisation/my_numdart.dart';
import 'package:on_sight/backend/database.dart';
import 'package:on_sight/error_handling/my_exceptions.dart';
import 'package:on_sight/navigations/compass.dart';

enum Zone {
  start,
  corner,
  end,
  stalls,
}

class Localisation {
  // ==== Private Methods ====
  /// constructor
  ///
  /// Inputs:
  /// 1) dbObj [MyDatabase] - database object.
  ///
  /// Returns:
  /// 1) None.
  Localisation({
    required MyDatabase dbObj,
  }) {
    _knownBeacons = dbObj.getKnownBeaconsPositions();

    _circleConditions = {
      'TANGENTIAL': 1,
      'OVERLAP': 2,
      'NO INTERCEPT': 3,
      'EXACT': 4,
    };
  }

  final MyNumDart _nd = MyNumDart();
  // for navigation
  bool hasTurned = false;
  Zone currZone = Zone.start;

  // TODO: update baseline RSSI as necessary
  static num BASELINERSSI = -55.0;

  /// Note: conditions here differs from the four cases that we have.
  /// Case 1: All three circles intercept at exactly one point.
  /// Case 2: All three circles overlap each other to form an area.
  /// Case 3: The two circles with the smallest radiuses intercept but the last
  ///         circle do not.
  /// Case 4: The two circles with the smallest radiuses do not intercept at all.
  /// Case 5: The two circles with the smallest radiuses are tangential to
  ///         each other.
  ///
  /// Conditions of different circles:
  /// 'TANGENTIAL': 1
  /// 'OVERLAP': 2,
  /// 'NO INTERCEPT': 3,
  /// 'EXACT': 4
  Map<String, num> _circleConditions = {};

  /// Known locations of beacons
  /// key: macAddr, value: [x_coordinate, y_coordinate]
  Map<String, List<num>> _knownBeacons = {};

  num prev_x = 0.0;
  num prev_y = 0.0;

  /// ========  For Navigations  ========
  /// To convert estimated position from localisation to zones.
  ///
  /// Inputs:
  /// 1) estPosition [List<num>] - (x_coor, y_coor).
  ///
  /// Returns:
  /// 1) [Zone]
  Zone _determineZone({required List<num> estPosition}) {
    num currX = estPosition[0];
    num currY = estPosition[1];

    if (!hasTurned) {
      if (currY >= 1200 && currX <= 900) {
        return Zone.corner;
      } else {
        return Zone.start;
      }
    } else {
      return Zone.end;
    }
  }

  String _zoneToString(Zone userZone) {
    if (userZone == Zone.start)
      return 'Start';
    else if (userZone == Zone.corner)
      return 'Corner';
    else if (userZone == Zone.end)
      return 'End';
    else
      return 'Stalls';
  }

  /// Retrieve the lower and upper limits of the heading
  num _retrieveHeadingAngleRange(Heading heading) {
    // precision to 4 d.p
    if (heading == Heading.NE) {
      return 45.0;
    } else if (heading == Heading.E) {
      return 90.0;
    } else if (heading == Heading.SE) {
      return 135.0;
    } else if (heading == Heading.S) {
      return 180;
    } else if (heading == Heading.SW) {
      return 225.0;
    } else if (heading == Heading.W) {
      return 270.0;
    } else if (heading == Heading.NW) {
      return 315.0;
    } else if (heading == Heading.N) {
      // special since North points from a negative range to a positive range (-22.5, 22.5)
      return 0.0;
    } else {
      throw NoPossibleSolution(
          errMsg:
              "[_retrieveHeadingAngleRange]: Unable to retrieve heading angle");
    }
  }

  /// Determines the direction for the user to move in.
  ///
  /// Inputs:
  /// 1) userZone [Zone] - current zone.
  /// 2) userBearing [Bearing] - current facing angle.
  ///
  /// Returns:
  /// 1) [String] - direction for the user to move.
  ///
  /// TODO: Logic is buggy. It can direct the user to a particular direction.
  ///       However, when the user is at the direct opposite direction,
  ///       the direction given keeps jumping back and forth.
  String determineDirection(Zone userZone, Bearing userBearing) {
    // TODO: Placeholder values for now. Change headings to actual headings.
    Map<Zone, Heading> FIXED_ROUTES_HEADING = {
      Zone.start: Heading.NW,
      Zone.corner: Heading.NE,
      Zone.end: Heading.NE,
    };

    Heading? intendedHeading = FIXED_ROUTES_HEADING[userZone];
    num intendedAngle = _retrieveHeadingAngleRange(userBearing.heading);
    num rightTurnAngle = userBearing.angle - intendedAngle;
    num leftTurnAngle = intendedAngle - userBearing.angle;

    rightTurnAngle =
        ((rightTurnAngle < 0) ? (rightTurnAngle + 360) : rightTurnAngle);
    leftTurnAngle =
        ((leftTurnAngle < 0) ? (leftTurnAngle + 360) : leftTurnAngle);

    if (userBearing.heading != intendedHeading) {
      if (rightTurnAngle < leftTurnAngle) {
        return 'Right';
      } else {
        return 'Left';
      }
    }
    // indicates correct orientation
    else {
      return 'Forward';
    }
  }

  /// ======== For Localisation ========
  /// Create estimate output.
  ///
  /// Inputs:
  /// 1) xCoor [num] - x coordinate.
  /// 2) yCoor [num] - y coordinate.
  ///
  /// Returns:
  /// 1) Map of estimated position [Map<String,dynamic>].
  Map<String, num> _formatEstimateOutput(
    num xCoor,
    num yCoor,
  ) {
    return {'x_coordinate': xCoor, 'y_coordinate': yCoor};
  }

  /// Retrieve details of circle coordinates and diameters and convert from Map
  /// to List.
  ///
  /// Input:
  /// 1) inputMap [Map<String, num>] - {key:macAddr, value:distances in meters}.
  ///
  /// Returns:
  /// 1) circles [List<List<num>>] (ascending order by radius).

  List<List<num>> _mapToList(Map<String, num> inputMap) {
    num metersToCentimeters = 100;
    num x1, x2, x3, y1, y2, y3, r1, r2, r3;
    List<String> macAddr = [];

    inputMap.forEach((key, value) {
      macAddr.add(key);
    });

    x1 = _knownBeacons[macAddr[0]]![0]; // Note: ! is for null checks
    y1 = _knownBeacons[macAddr[0]]![1];
    x2 = _knownBeacons[macAddr[1]]![0];
    y2 = _knownBeacons[macAddr[1]]![1];
    x3 = _knownBeacons[macAddr[2]]![0];
    y3 = _knownBeacons[macAddr[2]]![1];

    r1 = inputMap[macAddr[0]]! * metersToCentimeters;
    r2 = inputMap[macAddr[1]]! * metersToCentimeters;
    r3 = inputMap[macAddr[2]]! * metersToCentimeters;

    List<List<num>> circles = [
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
  /// 1) circleA [List<List<num>>] - details of circle e.g. X coordinate,
  ///                                   Y coordinate, and Radius.
  /// 2) circleB [List<List<num>>] - details of circle e.g. X coordinate,
  ///                                   Y coordinate, and Radius.
  ///
  /// Returns:
  /// 1) Statuses of circles [String] - 'TANGENTIAL', 'OVERLAP',
  ///                                   or 'NO INTERCEPT'.
  num _statusOfTwoCircles(List<num> circleA, List<num> circleB) {
    List<num> vectorA = [circleA[0], circleA[1]];
    List<num> vectorB = [circleB[0], circleB[1]];

    num radius = _nd.vectorAdd([circleA[2]], [circleB[2]])[0];

    List<num> vectorAB = _nd.vectorAdd(_nd.negateList(vectorA), vectorB);
    num magnitude = _nd.vectorMagnitude(vectorAB);

    if ((radius == magnitude) || _nd.isClose(radius, magnitude)) {
      return _circleConditions['TANGENTIAL'] ?? 1;
    } else if (radius > magnitude) {
      return _circleConditions['OVERLAP'] ?? 2;
    } else if (radius < magnitude) {
      return _circleConditions['NO INTERCEPT'] ?? 3;
    } else {
      throw NoPossibleSolution(
          errMsg: '[_statusOfTwoCircles]: No Possible Solution Possible.');
    }
  }

  /// Find the intercepts of two circles.
  ///
  /// Inputs:
  /// 1) circleA [List<num>] - details of circle e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  /// 1) circleB [List<num>] - details of circle e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  ///
  /// Returns:
  /// 1) intercepts [List<num>]
  List<List<num>> _interceptOfTwoCircles(
    List<num> circleA,
    List<num> circleB,
  ) {
    num x1 = circleA[0];
    num x2 = circleB[0];
    num y1 = circleA[1];
    num y2 = circleB[1];
    num r1 = circleA[2];
    num r2 = circleB[2];
    List<List<num>> intercepts = [[]];

    if (y1 == y2) {
      // solving for x
      num x = (pow(r1, 2).toDouble() -
              pow(r2, 2).toDouble() -
              pow(x1, 2).toDouble() +
              pow(x2, 2).toDouble()) /
          (-2 * x1 + 2 * x2);
      // solving quadratically for y
      num a = 1;
      num b = -2 * y1;
      num c = pow(y1, 2).toDouble() +
          pow(x, 2).toDouble() -
          2 * x1 * x +
          pow(x1, 2).toDouble() -
          pow(r1, 2).toDouble();

      List<num> yRoots = [];

      try {
        yRoots = _nd.vectorRoots(a, b, c);
      } on ZeroDivisionError catch (error) {
        throw ZeroDivisionError(errMsg: error.what());
      }

      intercepts = [
        [x, yRoots[0]],
        [x, yRoots[1]]
      ];
    } else if (x1 == x2) {
      // solving for y
      num y = (pow(r1, 2).toDouble() -
              pow(r2, 2).toDouble() -
              pow(y1, 2).toDouble() +
              pow(y2, 2).toDouble()) /
          (-2 * y1 + 2 * y2);
      // solving quadratically for x
      num a = 1;
      num b = -2 * x1;
      num c = pow(x1, 2).toDouble() +
          pow(y, 2).toDouble() -
          2 * y1 * y +
          pow(y1, 2).toDouble() -
          pow(r1, 2).toDouble();

      List<num> xRoots = [];
      try {
        xRoots = _nd.vectorRoots(a, b, c);
      } on ZeroDivisionError catch (error) {
        throw ZeroDivisionError(errMsg: error.what());
      }

      intercepts = [
        [xRoots[0], y],
        [xRoots[1], y]
      ];
    } else {
      num A = -2 * x1 + 2 * x2;
      num B = -2 * y1 + 2 * y2;
      num C = pow(y1, 2).toDouble() -
          pow(y2, 2).toDouble() +
          pow(x1, 2).toDouble() -
          pow(x2, 2).toDouble() -
          pow(r1, 2).toDouble() +
          pow(r2, 2).toDouble();

      // solving quadratically
      num a = pow(B, 2).toDouble() + pow(A, 2).toDouble();
      num b = -2 * x1 * pow(B, 2).toDouble() + 2 * A * C + 2 * y1 * B * A;
      num c = pow(B, 2).toDouble() * pow(x1, 2).toDouble() +
          pow(C, 2).toDouble() +
          2 * y1 * B * C +
          pow(B, 2).toDouble() * pow(y1, 2).toDouble() -
          pow(B, 2).toDouble() * pow(r1, 2).toDouble();

      List<num> xRoots = [];

      try {
        xRoots = _nd.vectorRoots(a, b, c);
      } on ZeroDivisionError catch (error) {
        throw ZeroDivisionError(errMsg: error.what());
      }

      List<num> yRoots = [];
      for (int i = 0; i < xRoots.length; i++) {
        num temp;
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
  /// 1) circleC [List<num>] - details of circle e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  /// 2) overlapIntercepts [List<List<num>>] - Used when two
  ///                                             circles with smallest two
  ///                                             radiuses overlaps with each other.
  /// 3) tangentialIntercepts [List<num>] - Used when two
  ///                                          circles with smallest two
  ///                                          radiuses is tangential to each other.
  /// Return:
  /// 1) Status [num] - 'OVERLAP', 'NO INTERCEPT', or 'EXACT'.
  num _statusOfThirdCircle(
    List<num> circleC, {
    required List<List<num>> overlapIntercepts,
    required List<num> tangentialIntercept,
  }) {
    // For overlap
    if ((overlapIntercepts.isNotEmpty) && (tangentialIntercept.isEmpty)) {
      List<num> vectorA = overlapIntercepts[0];
      List<num> vectorB = overlapIntercepts[1];
      List<num> vectorC = circleC.sublist(0, 2);
      num radiusC = circleC[2];

      List<num> vectorAC = _nd.vectorAdd(_nd.negateList(vectorA), vectorC);
      num magnitudeAC = _nd.vectorMagnitude(vectorAC);
      List<num> vectorBC = _nd.vectorAdd(_nd.negateList(vectorB), vectorC);
      num magnitudeBC = _nd.vectorMagnitude(vectorBC);

      if (_nd.isClose(magnitudeAC, radiusC) ||
          (magnitudeAC == radiusC) ||
          _nd.isClose(magnitudeBC, radiusC) ||
          (magnitudeBC == radiusC)) {
        return _circleConditions['EXACT'] ?? 4;
      } else if ((radiusC < magnitudeAC && radiusC > magnitudeBC) ||
          (radiusC < magnitudeBC && radiusC > magnitudeAC)) {
        return _circleConditions['OVERLAP'] ?? 2;
      } else {
        return _circleConditions['NO INTERCEPT'] ?? 3;
      }
    }

    // For tangential
    else if ((overlapIntercepts.isEmpty) && (tangentialIntercept.isNotEmpty)) {
      List<num> vectorC = circleC.sublist(0, 2);
      num radiusC = circleC[2];

      List<num> vectorAC =
          _nd.vectorAdd(_nd.negateList(tangentialIntercept), vectorC);
      num magnitudeAC = _nd.vectorMagnitude(vectorAC);

      if (_nd.isClose(magnitudeAC, radiusC) || (magnitudeAC == radiusC)) {
        return _circleConditions['EXACT'] ?? 4;
      } else if ((radiusC < magnitudeAC) || (radiusC > magnitudeAC)) {
        return _circleConditions['OVERLAP'] ?? 2;
      } else {
        return _circleConditions['NO INTERCEPT'] ?? 3;
      }
    } else {
      throw NoPossibleSolution(
          errMsg: '[_statusOfThirdCircle]: Status of third circle is unknown!');
    }
  }

  /// Solve for the exact intercection point between three circles.
  /// Reference:
  /// https://www.101computing.net/cell-phone-trilateration-algorithm/
  ///
  /// Input:
  /// 1) circles [List<List<num>>] - details of circles e.g. X coordinate,
  ///                                   Y coordinate, and Radius.
  ///
  /// Return:
  /// 1) estimate [Map<String, num>] - {'x_coordinate': X, 'y_coordinate': Y}
  Map<String, num> _exactInterceptWithThreeCircles(
      {required List<List<num>> circles}) {
    List<num> circleA = circles[0];
    List<num> circleB = circles[1];
    List<num> circleC = circles[2];

    num x1 = circleA[0];
    num y1 = circleA[1];
    num r1 = circleA[2];
    num x2 = circleB[0];
    num y2 = circleB[1];
    num r2 = circleB[2];
    num x3 = circleC[0];
    num y3 = circleC[1];
    num r3 = circleC[2];

    num A = -2 * x1 + 2 * x2;
    num B = -2 * y1 + 2 * y2;
    num C = pow(r1, 2).toDouble() -
        pow(r2, 2).toDouble() -
        pow(x1, 2).toDouble() +
        pow(x2, 2).toDouble() -
        pow(y1, 2).toDouble() +
        pow(y2, 2).toDouble();
    num D = -2 * x2 + 2 * x3;
    num E = -2 * y2 + 2 * y3;
    num F = pow(r2, 2).toDouble() -
        pow(r3, 2).toDouble() -
        pow(x2, 2).toDouble() +
        pow(x3, 2).toDouble() -
        pow(y2, 2).toDouble() +
        pow(y3, 2).toDouble();

    num X = (C * E - F * B) / (E * A - B * D);
    num Y = (C * D - A * F) / (B * D - A * E);

    return _formatEstimateOutput(X, Y);
  }

  /// Finding the most inner coordinate with respect to the center of circle
  /// directly across the coordinate.
  ///
  /// Inputs:
  /// 1) interceptA [List<num>].
  /// 2) interceptB [List<num>].
  /// 3) center [List<num>] - center of circle that is not related to
  ///                            interceptA and interceptB.
  ///
  /// Return:
  /// 1) innerCoor [List<num>].
  List<num> _innerIntersection(
    List<num> interceptA,
    List<num> interceptB,
    List<num> center,
  ) {
    List<num> vectorAC = _nd.vectorAdd(_nd.negateList(interceptA), center);
    List<num> vectorBC = _nd.vectorAdd(_nd.negateList(interceptB), center);

    num magAC = _nd.vectorMagnitude(vectorAC);
    num magBC = _nd.vectorMagnitude(vectorBC);

    if (magAC > magBC) {
      return interceptB;
    }
    return interceptA;
  }

  /// Approximate the intersection point when all three circles overlap each
  /// other and forms an area of triangle.
  ///
  /// Inputs:
  /// 1) circles [List<List<num>>] - details of circles e.g. X coordinate,
  ///                                   Y coordinate, and Radius.
  /// 2) interceptA [List<List<num>>] - intercepts between circleA and
  ///                                      circleB.
  ///
  /// Returns:
  /// 1) estimate [Map<String,num>] - {'x_coordinate': X, 'y_coordinate': Y}
  Map<String, num> _estimatedInterceptWhenThreeCirclesOverlap(
    List<List<num>> circle,
    List<List<num>> interceptA,
  ) {
    List<List<num>> interceptB = _interceptOfTwoCircles(circle[0], circle[2]);
    List<List<num>> interceptC = _interceptOfTwoCircles(circle[1], circle[2]);

    List<num> innerA = _innerIntersection(
        interceptA[0], interceptA[1], circle[2].sublist(0, 2));
    List<num> innerB = _innerIntersection(
        interceptB[0], interceptB[1], circle[1].sublist(0, 2));
    List<num> innerC = _innerIntersection(
        interceptC[0], interceptC[1], circle[0].sublist(0, 2));

    num X = (innerA[0] + innerB[0] + innerC[0]) / 3;
    num Y = (innerA[1] + innerB[1] + innerC[1]) / 3;

    return _formatEstimateOutput(X, Y);
  }

  /// Find the coordinate of the circle along its circumference that is closest
  /// to the center of the last circle.
  ///
  /// Input:
  /// 1) gradient [num] - gradient of line intersecting the two centers of
  ///                        two circles.
  /// 2) constant [num] - constant in Y = mX + C.
  /// 3) centerX [num] - x coordinate of center of circle.
  /// 4) circle [<List<num>] - details of circle e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  /// Return:
  /// 1) intercept [List<num>].
  List<num> _coordinateClosestToCircle(
    num gradient,
    num constant,
    num centerX,
    List<num> circle,
  ) {
    num X = circle[0];
    num Y = circle[1];
    num R = circle[2];

    num A = 1 + pow(gradient, 2).toDouble();
    num B = -2 * X + 2 * gradient * constant - 2 * Y * gradient;
    num C = pow(X, 2).toDouble() +
        pow(constant, 2).toDouble() -
        2 * Y * constant +
        pow(Y, 2).toDouble() -
        pow(R, 2).toDouble();
    List<num> xRoots = [];

    try {
      xRoots = _nd.vectorRoots(A, B, C);
    } on ZeroDivisionError catch (error) {
      throw ZeroDivisionError(errMsg: error.what());
    } on RangeError catch (error) {
      throw RangeError(error.message);
    }

    xRoots.sort((a, b) => b.compareTo(a)); // sort in descending order
    List<num> xRootsCopy = List.from(xRoots); // create a deep copy

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
  /// 1) circles [List<List<num>>] - details of circles e.g. X coordinate,
  ///                                   Y coordinate, and Radius.
  /// Return:
  /// 1) estimate [Map<String,num>] - {'x_coordinate': X, 'y_coordinate': Y}.
  Map<String, num> _estimatedPositionWhenTwoSmallestCirclesDoNotIntercept(
    List<List<num>> circles,
  ) {
    List<num> circleA = circles[0];
    List<num> circleB = circles[1];
    List<num> circleC = circles[2];

    num x1 = circleA[0];
    num y1 = circleA[1];
    num r1 = circleA[2];
    num x2 = circleB[0];
    num y2 = circleB[1];
    num r2 = circleB[2];
    num x3 = circleC[0];
    num y3 = circleC[1];
    num r3 = circleC[2];

    num gradient = (y1 - y2) / (x1 - x2);
    num constant = y1 - gradient * x1;

    // For circleA
    List<num> closestInterceptA = _coordinateClosestToCircle(
      gradient,
      constant,
      x2,
      circles[0],
    );
    // For circleB
    List<num> closestInterceptB = _coordinateClosestToCircle(
      gradient,
      constant,
      x1,
      circles[1],
    );
    // estimate AB
    List<num> vectorAB = [
      (r1 * closestInterceptB[0] + r2 * closestInterceptA[0]) / (r1 + r2),
      (r1 * closestInterceptB[1] + r2 * closestInterceptA[1]) / (r1 + r2)
    ];

    gradient = (vectorAB[1] - y3) / (vectorAB[0] - x3);
    constant = y3 - gradient * x3;

    // For circleC
    List<num> closestInterceptC = _coordinateClosestToCircle(
      gradient,
      constant,
      vectorAB[0],
      circles[2],
    );

    return _formatEstimateOutput(
        (r2 * closestInterceptC[0] + r3 * vectorAB[0]) / (r2 + r3),
        (r2 * closestInterceptC[1] + r3 * vectorAB[1]) / (r2 + r3));
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
  /// 1) intercepts [List<num>] - intercepts of the two circles with the
  ///                                smallest radiuses.
  /// 2) radiusA [num] - radius of circle A.
  /// 3) radiusB [num] - radius of circle B.
  /// 4) circleC [List<num>] - details of circles e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  ///
  /// Return:
  /// 1) estimate [Map<String,num>] - {'x_coordinate': X, 'y_coordinate': Y}.
  Map<String, num> _estimatedPositionWhenTwoCirclesInterceptButLastCircleDoNot(
    List<List<num>> intercepts,
    num radiusA,
    num radiusB,
    List<num> circleC,
  ) {
    List<num> interceptA = intercepts[0];
    List<num> interceptB = intercepts[1];
    num x3 = circleC[0];
    num y3 = circleC[1];
    num r3 = circleC[2];

    // Estimated position AB
    List<num> vectorAB = [
      (radiusA * interceptB[0] + radiusB * interceptA[0]) / (radiusA + radiusB),
      (radiusA * interceptB[1] + radiusB * interceptA[1]) / (radiusA + radiusB)
    ];

    // Finding best estimated position
    num gradient = (vectorAB[1] - y3) / (vectorAB[0] - x3);
    num constant = y3 - gradient * x3;

    List<num> closestCoord = _coordinateClosestToCircle(
      gradient,
      constant,
      vectorAB[0],
      circleC,
    );

    return _formatEstimateOutput(
        (radiusB * closestCoord[0] + r3 * vectorAB[0]) / (radiusB + r3),
        (radiusB * closestCoord[1] + r3 * vectorAB[1]) / (radiusB + r3));
  }

  /// Find the intercept of two tangential circles.
  ///
  /// Inputs:
  /// 1) circleA [List<num>].
  /// 1) circleB [List<num>].
  ///
  /// Returns:
  /// 1) intercept of circle A and B [List<num>].
  List<num> _interceptOfTwoTangentialCircles(
    List<num> circleA,
    List<num> circleB,
  ) {
    num radiusA = circleA[2];
    num radiusB = circleB[2];

    return [
      (radiusB * circleA[0] + radiusA * circleB[0]) / (radiusA + radiusB),
      (radiusB * circleA[1] + radiusA * circleB[1]) / (radiusA + radiusB)
    ];
  }

  /// Used when the two smallest circles are tangential to each other.
  ///
  /// Input:
  /// 1) interceptA [List<num>] - intercepts of the two circles with the
  ///                                smallest radiuses.
  /// 2) radiusA [num] - radius of the smallest circle A.
  /// 3) circleC [List<num>] - details of circles e.g. X coordinate,
  ///                             Y coordinate, and Radius.
  ///
  /// Return:
  /// 1) estimate [Map<String,num>] - {'x_coordinate': X, 'y_coordinate': Y}.
  Map<String, num> _estimatedPositionWhenSmallestTwoCirclesAreTangential(
    List<num> interceptA,
    num radiusA,
    List<num> circleC,
  ) {
    num x3 = circleC[0];
    num y3 = circleC[1];
    num r3 = circleC[2];

    // Finding best estimated position
    num gradient = (interceptA[1] - y3) / (interceptA[0] - x3);
    num constant = y3 - gradient * x3;

    List<num> closestCoord =
        _coordinateClosestToCircle(gradient, constant, interceptA[0], circleC);

    return _formatEstimateOutput(
        (radiusA * closestCoord[0] + r3 * interceptA[0]) / (radiusA + r3),
        (radiusA * closestCoord[1] + r3 * interceptA[1]) / (radiusA + r3));
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
  /// 1) rssi [num]
  ///
  /// Returns:
  /// 1) estDistance [num] - estimated diatances converted from RSSI in meters.
  num _rssiToDistance(num rssi) {
    num RSSId0 =
        (BASELINERSSI).abs(); // #TODO: maybe can modify this in RUNTIME.
    num n = 3;
    num d0 = 1;
    num x = 0;
    num exponent = (rssi.abs() - RSSId0 - x) / (10 * n);
    num distance = (d0 * (pow(10, exponent))).toDouble();

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
  /// 1) distance [num] - distance in meters.
  ///
  /// Returns:
  /// 1) estRssi [num] - estimated diatances converted from RSSI.
  num _distanceToRssi(num distance) {
    num RSSId0 =
        (BASELINERSSI).abs(); // #TODO: maybe can modify this in RUNTIME.
    num n = 3;
    num d0 = 1;
    num x = 0;

    // Note: log10(0) = undefined
    num estRssi = -(RSSId0 + 10 * n * _nd.logBase(distance / d0, 10) + x);

    return estRssi;
  }

  /// Trilateration
  ///
  /// Input:
  /// 1) distances [Map<String,num>] - {key:macAddr, value: radius distances in meters}.
  ///
  /// Returns:
  /// 1) estimate [Map<String, num>] - {'x_coordinate':<>, 'y_coordinate':<>}
  Map<String, num> _trilateration(Map<String, num> distances) {
    Map<String, num> estimate = {}; // final estimate
    List<List<num>> circles = _mapToList(distances);

    // Case: circles with the two smallest radiuses overlaps
    num statusOfTwoSmallestCircles =
        _statusOfTwoCircles(circles[0], circles[1]);
    if (statusOfTwoSmallestCircles == (_circleConditions['OVERLAP'] ?? 2)) {
      List<List<num>> interceptA = _interceptOfTwoCircles(
        circles[0],
        circles[1],
      );

      // Case: last circle overlaps exactly with interceptA
      num statusOfLastCircles = _statusOfThirdCircle(
        circles[2],
        overlapIntercepts: interceptA,
        tangentialIntercept: [],
      );
      if (statusOfLastCircles == (_circleConditions['EXACT'] ?? 4)) {
        // print('Performing Case 1: Three circles intercept exactly.');
        estimate = _exactInterceptWithThreeCircles(circles: circles);
      }
      // Case: last circle overlaps with the other two smaller circles
      else if (statusOfLastCircles == (_circleConditions['OVERLAP'] ?? 2)) {
        // print('Performing Case 2: Three circles overlaps each other.');
        estimate = _estimatedInterceptWhenThreeCirclesOverlap(
          circles,
          interceptA,
        );
      }
      // Case: last circle do not overlap or intercept at all
      else {
        // print(
        //     'Performing Case 3: Only the two smallest circles intercept but the last do not.');
        estimate = _estimatedPositionWhenTwoCirclesInterceptButLastCircleDoNot(
          interceptA,
          circles[0][2],
          circles[1][2],
          circles[2],
        );
      }
    }

    // Case: circles with the two smallest radiuses do not overlap
    else if (statusOfTwoSmallestCircles ==
        (_circleConditions['NO INTERCEPT'] ?? 3)) {
      // print('Performing Case 4: Two smallest circles do not intercept.');
      estimate =
          _estimatedPositionWhenTwoSmallestCirclesDoNotIntercept(circles);
    }

    // Case: Circles with two smallest circles are tangential to each other
    else {
      // print(
      //     'Performing Case 5: Two smallest circles are tangential to each other.');

      List<num> interceptA = _interceptOfTwoTangentialCircles(
        circles[0],
        circles[1],
      );
      num statusOfLastCircle = _statusOfThirdCircle(
        circles[2],
        overlapIntercepts: [],
        tangentialIntercept: interceptA,
      );

      // Case: Circles with two smallest circles are tangential to each other
      //       and the last circle intercept exactly at interceptA.
      if (_circleConditions[statusOfLastCircle] ==
          (_circleConditions['EXACT'] ?? 4)) {
        estimate = _exactInterceptWithThreeCircles(circles: circles);
      }
      // Case: Circles with two smallest circles are tangential to each other
      //       and the last circle do not intercept at interceptA.
      else {
        estimate = _estimatedPositionWhenSmallestTwoCirclesAreTangential(
          interceptA,
          circles[0][2],
          circles[2],
        );
      }
    }
    try {
      return estimate;
    } on RangeError {
      return {
        'x_coordinate': prev_x,
        'y_coordinate': prev_y,
      };
    } on ZeroDivisionError {
      return {
        'x_coordinate': prev_x,
        'y_coordinate': prev_y,
      };
    }
  }

  //==== Public Methods ====
  /// Wrapper for trilateration
  ///
  /// Inputs:
  /// 1) rawData [LinkedHashMap<String,dynamic] - keys include 'rssi', 'accelerometer',
  ///                                             and 'magnetometer'.
  ///
  /// Returns:
  /// 1) result [LinkedHashMap<String,dynamic>] - {'x_coordinate': X, 'y_coordinate': Y,
  ///                                             'direction':direction}
  LinkedHashMap<String, dynamic> localisation(
    LinkedHashMap<String, dynamic> rawData,
  ) {
    LinkedHashMap<String, dynamic> result = LinkedHashMap();
    LinkedHashMap<String, num> distances = LinkedHashMap();

    rawData.forEach((key, value) {
      if (key == 'rssi') {
        LinkedHashMap<String, num> rssiData = rawData[key];
        rssiData.forEach((macAddr, rssi) {
          distances[macAddr] = _rssiToDistance(rssi.toDouble());
        });

        try {
          Map<String, num> tmpResult = _trilateration(distances);
          // storing of prev values
          prev_x = tmpResult['x_coordinate'] ?? -1.0;
          prev_y = tmpResult['y_coordinate'] ?? -1.0;
          result.addEntries(tmpResult.entries);
        } on ZeroDivisionError {
          // TODO: Uncomment for debug purposes
          // Map<String, num> rssi = rawData['rssi'];
          // List<String> uuid = rssi.keys.toList();
          // print(
          //     '[ZeroDivisionError] mosquitto_pub -h localhost -t "test/sub" -u "mqtt-server" -P "onsight!" -m "{\\"rssi\\":{\\"${uuid[0]}\\":${rssi[uuid[0]]}, \\"${uuid[1]}\\":${rssi[uuid[1]]}, \\"${uuid[2]}\\":${rssi[uuid[2]]}}, \\"accelerometer\\":5, \\"magnetometer\\":[-33.57, 86.31]}"');

          // display prev values on error
          result.addEntries({
            'x_coordinate': prev_x,
            'y_coordinate': prev_y,
          }.entries);
        } on RangeError {
          // TODO: Uncomment for debug purposes
          // Map<String, num> rssi = rawData['rssi'];
          // List<String> uuid = rssi.keys.toList();
          // print(
          //     '[RangeError] mosquitto_pub -h localhost -t "test/sub" -u "mqtt-server" -P "onsight!" -m "{\\"rssi\\":{\\"${uuid[0]}\\":${rssi[uuid[0]]}, \\"${uuid[1]}\\":${rssi[uuid[1]]}, \\"${uuid[2]}\\":${rssi[uuid[2]]}}, \\"accelerometer\\":5, \\"magnetometer\\":[-33.57, 86.31]}"');

          // display prev values on error
          result.addEntries({
            'x_coordinate': prev_x,
            'y_coordinate': prev_y,
          }.entries);
        }
      } else if (key == 'magnetometer') {
        // initialise hashmap
        Map<String, String> tempDirection = {
          'zone': '',
          'angle': '',
          'compass_heading': '',
          'suggested_direction': '',
        };

        // using zones to determine direction
        Zone currZone = _determineZone(estPosition: [
          result['x_coordinate'],
          result['y_coordinate'],
        ]);

        // compass prototype
        List<num> currMagneto = value;
        Compass compass = Compass(
          magx: currMagneto[0],
          magy: currMagneto[1],
        );

        // store result
        tempDirection['zone'] = _zoneToString(currZone);
        tempDirection['angle'] = compass.getBearing().getAngleString();
        tempDirection['compass_heading'] =
            compass.getBearing().getHeadingString();
        tempDirection['suggested_direction'] =
            determineDirection(currZone, compass.getBearing());
        result['direction'] = tempDirection;
      } else {
        // Do nothing
      }
    });

    return result;
  }
}
